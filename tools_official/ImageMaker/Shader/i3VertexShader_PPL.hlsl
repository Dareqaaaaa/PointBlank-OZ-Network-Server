#if defined( I3L_PPL)

#if !defined( I3L_VERTEX_BLEND)
	VS_OUTPUT VS_Def( VS_INPUT i)
	{
		VS_OUTPUT o;
		
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
		
			o.Normal = normalize( mul( i.Normal, (float3x3) g_mWorldView));
			
			#if (I3L_LIGHTTYPE_0 != I3L_LIGHTTYPE_NONE) || (I3L_LIGHTTYPE_1 != I3L_LIGHTTYPE_NONE) || defined( I3L_REFLECT_MAP)
				o.CSPos =  o.Pos.xyz;
			#endif
			
			#if defined( I3L_NORMAL_MAP)
			o.Tangent = normalize( mul( i.Tangent, (float3x3) g_mWorldView));
			o.Binormal = normalize( mul( i.Binormal, (float3x3) g_mWorldView));
			#endif
		
			#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
				o.LSPos0	= mul( o.Pos, g_mShadowMap0);
			#endif
			
			#if (I3L_SHADOW_1 == I3L_SHADOW_SHADOWMAP)
				o.LSPos1	= mul( o.Pos, g_mShadowMap1);
			#endif
		#else
			#if defined( I3L_VERTEX_COLOR)
				o.Color = i.Color;
			#endif
		#endif
		
		o.Pos = mul( o.Pos, g_mProj );  
		
		#if defined( SCREENSPACE_SHADOW)
			#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
				o.SSPos	= o.Pos;
			#endif
		#endif
				        
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
			#if defined( I3L_NORMAL_MAP)		
				Binormal	+= mul( i.Binormal,	(float3x3)g_mBone[ INDEX(0)]) * WEIGHT(0);
				Tangent		+= mul( i.Tangent,	(float3x3)g_mBone[ INDEX(0)]) * WEIGHT(0);
			#endif
		#endif
	#endif
	
	#if (NUM_BONES > 2)
		LastWeight = LastWeight + WEIGHT(1);
		
		Pos					+= mul( i.Pos,		g_mBone[ INDEX(1)]) * WEIGHT(1);
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal			+= mul( i.Normal,	(float3x3)g_mBone[ INDEX(1)]) * WEIGHT(1);
			#if defined( I3L_NORMAL_MAP)
				Binormal	+= mul( i.Binormal,	(float3x3)g_mBone[ INDEX(1)]) * WEIGHT(1);
				Tangent		+= mul( i.Tangent,	(float3x3)g_mBone[ INDEX(1)]) * WEIGHT(1);
			#endif
		#endif
	#endif
	
	#if (NUM_BONES > 3)
		LastWeight = LastWeight + WEIGHT(2);
		
		Pos					+= mul( i.Pos,		g_mBone[ INDEX(2)]) * WEIGHT(2);
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal			+= mul( i.Normal,	(float3x3)g_mBone[ INDEX(2)]) * WEIGHT(2);
			#if defined( I3L_NORMAL_MAP)
				Binormal	+= mul( i.Binormal,	(float3x3)g_mBone[ INDEX(2)]) * WEIGHT(2);
				Tangent		+= mul( i.Tangent,	(float3x3)g_mBone[ INDEX(2)]) * WEIGHT(2);
			#endif
		#endif
	#endif
	
	{
		LastWeight = 1.0f - LastWeight;
		
		Pos			+= mul( i.Pos,		g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
		
		#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
			Normal		+= mul( i.Normal,		g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
			#if defined( I3L_NORMAL_MAP)
				Binormal	+= mul( i.Binormal,	g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
				Tangent		+= mul( i.Tangent,	g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
			#endif
		#endif
	}

	#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
	
		#if (I3L_LIGHTTYPE_0 != I3L_LIGHTTYPE_NONE) || (I3L_LIGHTTYPE_1 != I3L_LIGHTTYPE_NONE) || defined( I3L_REFLECT_MAP)
			o.CSPos = Pos;
		#endif
	
		o.Normal = normalize( Normal);
		#if defined( I3L_NORMAL_MAP)
			o.Tangent = normalize( Tangent);
			o.Binormal = normalize( Binormal);
		#endif
		
		#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
			o.LSPos0	= mul( float4( Pos, 1.0f), g_mShadowMap0);
		#endif
		
		#if (I3L_SHADOW_1 == I3L_SHADOW_SHADOWMAP)
			o.LSPos1	= mul( float4( Pos, 1.0f), g_mShadowMap1);
		#endif
	#else
		#if defined( I3L_VERTEX_COLOR)
			o.Color = i.Color;
		#endif
	#endif
    
    o.Pos = mul( float4( Pos, 1.0f), g_mProj);
    
    #if defined( SCREENSPACE_SHADOW)
		#if (I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
			o.SSPos = o.Pos;
		#endif
	#endif
	    
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
