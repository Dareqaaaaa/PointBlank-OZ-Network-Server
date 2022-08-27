#if !defined( I3L_PPL)

void _vertexLighting( float3 iN, float3 CSPos, out float4 Diffuse, out float3 Specular)
{
	float4 specColor;
	float litted;
	
	// If one of two lights is not LuxMap, normal and specular vectors are needed.
	specColor = g_vLightSpecular0;
			
	// 1st Light
	#if (I3L_LIGHTTYPE_0 != I3L_LIGHTTYPE_NONE)
			
		#if (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
			////////////////////////////////////////
			// Directional Light
			#if !defined( I3L_LUX_MAP)
				// Ignore directional light even is exist, if Luxmap is appled.
				litted = _Directional( iN, g_vLightDir0);
			#else
				litted = 1.0f;
			#endif
			
		#elif (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_POINT)
			////////////////////////////////////////
			// Point Light
			litted = _Point( iN, CSPos, g_vLightFactor0, g_vLightPos0);
									
		#elif (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_SPOT)
			////////////////////////////////////////
			// Spot Light
			litted = _Spot( iN, CSPos, g_vLightFactor0, g_vLightDir0, g_vLightPos0);
		#endif
		
		#if defined( I3L_LUX_MAP) && (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
			Diffuse.rgb = 1.0f;
			Specular = 0.0f;
		#else
			Diffuse.rgb = g_vLightDiffuse0 *litted;
			Specular	= _getSpecular( iN, CSPos, specColor.rgb, specColor.a, g_vLightPos0);
		#endif
	#else
			// The lighting is turning on, without any light.
			Diffuse.rgb = 0.0f;
			Specular = 0;
	#endif
	
	// 2nd Light
	#if(I3L_LIGHTTYPE_1 != I3L_LIGHTTYPE_NONE)
		
		#if (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_DIRECTIONAL)
			////////////////////////////////////////
			// Directional Light
			#if !defined( I3L_LUX_MAP)
				litted = _Directional( iN, g_vLightDir1);
			#else
				litted = 1.0f;
			#endif
			
		#elif (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_POINT)
			////////////////////////////////////////
			// Point Light
			litted = _Point( iN, CSPos, g_vLightFactor1, g_vLightPos1);
						
		#elif (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_SPOT)
			////////////////////////////////////////
			// Spot Light
			litted = _Spot( iN, CSPos, g_vLightFactor1, g_vLightDir1, g_vLightPos1);
			
		#endif
		
		specColor = g_vLightSpecular1;
		
		Diffuse.rgb += g_vLightDiffuse1 *litted;
		Specular	+= _getSpecular( iN, CSPos, specColor.rgb, specColor.a, g_vLightPos1);
	#endif
	
	Diffuse.a = g_vLightDiffuse0.a;
}

#if !defined( I3L_VERTEX_BLEND)
	VS_OUTPUT VS_Def( VS_INPUT i)
	{
		VS_OUTPUT o;
		float3 iN, CSPos;
		
		o.Pos = float4( mul( i.Pos, g_mWorldView), 1.0f);
		
		#if defined( I3L_DIFFUSE_MAP) || defined( I3L_NORMAL_MAP) || defined( I3L_SPECULAR_MAP) || defined( I3L_EMISSIVE_MAP) || defined( I3L_REFLECT_MASK_MAP)
			#if defined( I3L_TEXCOORD_TRANSFORM)
				o.Tex0 = mul( float4( i.Tex0, 1.0f, 1.0f), g_mTex);
			#else
				o.Tex0 = i.Tex0;
			#endif
		#endif
		
		// LuxMap
		#if defined( I3L_LUX_MAP)
			o.Tex1 = i.Tex1;
		#endif
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
		
			iN = normalize( mul( i.Normal, (float3x3) g_mWorldView));
			
			#if (I3L_LIGHTTYPE_0 != I3L_LIGHTTYPE_NONE) || (I3L_LIGHTTYPE_1 != I3L_LIGHTTYPE_NONE) || defined( I3L_REFLECT_MAP)
				CSPos =  o.Pos.xyz;
			#endif
			
			#if defined( I3L_REFLECT_MAP)
				float3 WSNormal = normalize( mul( iN, (float3x3) g_mInvView));
				float3 WSEye = -normalize( CSPos);
				WSEye = mul( WSEye, (float3x3) g_mInvView);
	
				o.Reflect = reflect( WSNormal, WSEye);
			#endif
					
			#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
				o.LSPos0	= mul( o.Pos, g_mShadowMap0);
			#endif
			
			#if (I3L_SHADOW_1 == I3L_SHADOW_SHADOWMAP)
				o.LSPos1	= mul( o.Pos, g_mShadowMap1);
			#endif
			
			_vertexLighting( iN, CSPos, o.Color, o.Specular);
		#else
			#if defined( I3L_VERTEX_COLOR)
				o.Color = i.Color * g_vColor;
			#else
				o.Color = g_vColor;
			#endif
		#endif
		
		o.Pos = mul( o.Pos, g_mProj );  
		        
		return o;
	}
#else
//-----------------------------------------------------------------------------
// Vertex Shader: VertScene
// Desc: Process vertex for scene
//-----------------------------------------------------------------------------

#define WEIGHT(idx)				i.Weights[(idx)]
#define	INDEX(idx)				i.Indices[(idx)]
	
VS_OUTPUT VS_Def( VS_INPUT i)
{
	VS_OUTPUT o;
	float       LastWeight = 0.0f;
	float3		Pos = 0.0f;
	float3		Normal = 0.0f;
	float3		Tangent = 0.0f;
	float3		Binormal = 0.0f;
	
	// Compensate for lack of UBYTE4 on Geforce3
    //int4 IndexVector = D3DCOLORtoUBYTE4(i.Indices);
    
    // cast the vectors to arrays for use in the for loop below
    //float BlendWeightsArray[4] = (float[4])i.Weights;
    
    #if (NUM_BONES > 1)
		LastWeight = LastWeight + WEIGHT(0);
		
		Pos					+= mul( i.Pos,		g_mBone[ INDEX(0)]) * WEIGHT(0);
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal			+= mul( i.Normal,	(float3x3)g_mBone[ INDEX(0)]) * WEIGHT(0);
		#endif
	#endif
	
	#if (NUM_BONES > 2)
		LastWeight = LastWeight + WEIGHT(1);
		
		Pos					+= mul( i.Pos,		g_mBone[ INDEX(1)]) * WEIGHT(1);
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal			+= mul( i.Normal,	(float3x3)g_mBone[ INDEX(1)]) * WEIGHT(1);
		#endif
	#endif
	
	#if (NUM_BONES > 3)
		LastWeight = LastWeight + WEIGHT(2);
		
		Pos					+= mul( i.Pos,		g_mBone[ INDEX(2)]) * WEIGHT(2);
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal			+= mul( i.Normal,	(float3x3)g_mBone[ INDEX(2)]) * WEIGHT(2);
		#endif
	#endif
	
	{
		LastWeight = 1.0f - LastWeight;
		
		Pos			+= mul( i.Pos,		g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal		+= mul( i.Normal,		g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
		#endif
	}

	#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
	
		float3 iN;
	
		iN = normalize( Normal);
		
		#if defined( I3L_REFLECT_MAP)
			float3 WSNormal = normalize( mul( i.Normal, (float3x3) g_mInvView));
			float3 WSEye = -normalize( Pos);
			WSEye = mul( WSEye, (float3x3) g_mInvView);

			o.Reflect = reflect( WSNormal, WSEye);
		#endif
		
		#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
			o.LSPos0	= mul( float4( Pos, 1.0f), g_mShadowMap0);
		#endif
		
		#if (I3L_SHADOW_1 == I3L_SHADOW_SHADOWMAP)
			o.LSPos1	= mul( float4( Pos, 1.0f), g_mShadowMap1);
		#endif
		
		_vertexLighting( iN, Pos, o.Color, o.Specular);
	#else
		#if defined( I3L_VERTEX_COLOR)
			o.Color = i.Color * g_vColor;
		#else
			o.Color = g_vColor;
		#endif
	#endif
    
    o.Pos = mul( float4( Pos, 1.0f), g_mProj);
    
    #if defined( I3L_DIFFUSE_MAP) || defined( I3L_NORMAL_MAP) || defined( I3L_SPECULAR_MAP) || defined( I3L_EMISSIVE_MAP) || defined( I3L_REFLECT_MASK_MAP)
		#if defined( I3L_TEXCOORD_TRANSFORM)
			o.Tex0 = mul( float4( i.Tex0, 1.0f, 1.0f), g_mTex);
		#else
			o.Tex0 = i.Tex0;
		#endif
	#endif
	
	#if defined( I3L_LUX_MAP)
		 o.Tex1 = i.Tex1;
	#endif
	
    return o;
}
#endif
#endif
