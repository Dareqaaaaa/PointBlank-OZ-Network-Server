#if defined( I3L_PPL)

float4 PS_Def( PS_INPUT i) : COLOR
{	
	half4 specColor, diffColor, oColor;
	float3 luxColor;
	float3 iN, sColor, iR;
	float litted, shadow = 1.0f;
		
	#if defined( I3L_DIFFUSE_MAP)
		diffColor = tex2D( g_texDiffuse, i.Tex0);
	#else
		#if defined( I3L_LIGHTING)
			diffColor = 1.0;
		#else
			#if defined( I3_VERTEX_COLOR)
				diffColor = i.Color;
			#else
				diffColor = 1.0f;
			#endif
		#endif
	#endif
	
		#if defined( I3L_LUX_MAP)		
			luxColor = _LuxMap( diffColor, i.Tex1);
			diffColor.rgb *= luxColor;
		#endif
	
	// Calculate Normal vector.
	//
	// case 1 :		use original iNormal
	// case 2 :		read from Normal Map.
	// case 3 :		provided from the user.
	#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
		#if defined( I3L_NORMAL_MAP)
			_getNormalMap( iN, i.Tex0, i.Normal, i.Tangent, i.Binormal);
		#else
			iN = i.Normal;
		#endif
	#endif
	
	#if defined( I3L_LIGHTING)
		// If one of two light is not LuxMap, Normals and Speculars are needed.
		#if defined( I3L_SPECULAR_MAP)
			specColor = tex2D( g_texSpecular, i.Tex0) * float4( 2, 2, 2, 255);
		#else
			specColor = g_vLightSpecular0;
		#endif
				
		// 1st Light
		#if (I3L_LIGHTMODEL != I3L_LIGHTMODEL_NONE) && (I3L_LIGHTTYPE_0 != I3L_LIGHTTYPE_NONE)
		
			#if (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
				////////////////////////////////////////
				// Directional Light
				litted = _Directional( iN, g_vLightDir0);
								
			#elif (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_POINT)
				////////////////////////////////////////
				// Point Light
				litted = _Point( iN, i.CSPos, g_vLightFactor0, g_vLightPos0);
											
			#elif (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_SPOT)
				////////////////////////////////////////
				// Spot Light
				litted = _Spot( iN, i.CSPos, g_vLightFactor0, g_vLightDir0, g_vLightPos0);
			#endif
			
			#if defined( I3L_LUX_MAP) && (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
				#if (I3L_SHADOW_0 != I3L_SHADOW_SHADOWMAP)
					oColor.rgb = diffColor.rgb;
				#else
					if( litted > 0.01f)
					{
						#if !defined( SCREENSPACE_SHADOW)
							_getShadow( shadow, i.LSPos0, g_vShadowMapFactor0, g_texShadow0, 1.0f);
						#else
							_getShadow( shadow, i.SSPos, g_vShadowMapFactor0, g_texShadow0, 1.0f, g_mShadowMap0);
						#endif
					}

					oColor.rgb = diffColor.rgb - (diffColor.rgb * (1.0f - shadow) * (1.0f - g_vAmbient.r));
				#endif
				
				#if defined( I3L_NORMAL_MAP) || defined( I3L_SPECULAR_MAP)
					oColor.rgb += _getSpecular_Dir( iN, i.CSPos, specColor.rgb, specColor.a, g_vLightDir0);
				#endif
			#else
				#if ( I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
				if( litted > 0.01f)
				{
					#if !defined( SCREENSPACE_SHADOW)
						_getShadow( shadow, i.LSPos0, g_vShadowMapFactor0, g_texShadow0, 1.0f);
					#else
						_getShadow( shadow, i.SSPos, g_vShadowMapFactor0, g_texShadow0, 1.0f, g_mShadowMap0);
					#endif
					
					litted *= shadow;
				}
				#endif
				
				#if (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
					oColor.rgb = GetLighingColor_Dir(	g_vLightDiffuse0, g_vLightSpecular0,
											diffColor, specColor.rgb, specColor.a, iN, i.CSPos, g_vLightDir0,
											litted) + ( diffColor * g_vAmbient);
				#else
					oColor.rgb = GetLighingColor(	g_vLightDiffuse0, g_vLightSpecular0,
											diffColor, specColor.rgb, specColor.a, iN, i.CSPos, g_vLightPos0, 
											litted) + ( diffColor * g_vAmbient);
				#endif
				
				#if ( I3L_SHADOW_0 == I3L_SHADOW_SHADOWMAP)
					//oColor.rgb = shadow;
				#endif
			#endif
		#else
			// The lighting is turning on, but there is not any light.
			oColor.rgb = diffColor * g_vAmbient;
		#endif
		
		// 2nd Light
		#if (I3L_LIGHTMODEL != I3L_LIGHTMODEL_NONE) && (I3L_LIGHTTYPE_1 != I3L_LIGHTTYPE_NONE)
		
			#if (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_DIRECTIONAL)
				////////////////////////////////////////
				// Directional Light
				litted = _Directional( iN, g_vLightDir1);
				
			#elif (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_POINT)
				////////////////////////////////////////
				// Point Light
				litted = _Point( iN, i.CSPos, g_vLightFactor1, g_vLightPos1);
							
			#elif (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_SPOT)
				////////////////////////////////////////
				// Spot Light
				litted = _Spot( iN, i.CSPos, g_vLightFactor1, g_vLightDir1, g_vLightPos1);
				
			#endif
			
			#if ( I3L_SHADOW_1 == I3L_SHADOW_SHADOWMAP)
			if( litted > 0.01f)
			{
				#if !defined( SCREENSPACE_SHADOW)
					_getShadow( shadow, i.LSPos1, g_vShadowMapFactor1, g_texShadow1, 1.0f);
				#else
					_getShadow( shadow, i.SSPos, g_vShadowMapFactor1, g_texShadow1, 1.0f, g_mShadowMap1);
				#endif
				
				litted *= shadow;
			}
			#endif
			
			#if !defined( I3L_SPECULAR_MAP)
				specColor = g_vLightSpecular1;
			#endif
			
			#if (I3L_LIGHTTYPE_1 == I3L_LIGHTTYPE_DIRECTIONAL)
				oColor.rgb += GetLightingColor_Dir(	g_vLightDiffuse1, g_vLightSpecular1,
										diffColor, specColor.rgb, specColor.a, iN, i.CSPos, g_vLightDir1, 
										litted);
			#else
				oColor.rgb += GetLightingColor(	g_vLightDiffuse1, g_vLightSpecular1,
									diffColor, specColor.rgb, specColor.a, iN, i.CSPos, g_vLightPos1, 
									litted);
			#endif
		#endif
		
		#if (I3L_LIGHTMODEL != I3L_LIGHTMODEL_NONE)
			oColor.a = diffColor.a * g_vLightDiffuse0.a;
		#else
			oColor.a = diffColor.a;
		#endif
	#else
		#if defined( I3L_LUX_MAP)
			oColor = diffColor;
		#else
			oColor = diffColor * g_vColor
			
					#if defined( I3L_VERTEX_COLOR)
						* i.Color
					#endif
					;
		#endif
	#endif
	
	// Reflection
	float3 reflectColor;
	
	#if defined( I3L_REFLECT_MAP)
		reflectColor = _getReflectMap( iN, i.CSPos);
		
		#if defined( I3L_REFLECT_MASK_MAP)
			float4 mask = tex2D( g_texReflectMask, i.Tex0);
			
			oColor.rgb += reflectColor * mask.rgb;
		#else
			oColor.rgb += reflectColor;
		#endif
	#endif
	
	#if defined( I3L_FRESNEL) && defined( I3L_LIGHTING)
		#if defined( I3L_REFLECT_MAP)
		
			#if defined( I3L_REFLECT_MASK_MAP)
				reflectColor = lerp( diffColor, reflectColor, mask.b);
			#endif
			
			oColor.rgb += _getFresnelTerm( iN, i.CSPos) * reflectColor * g_FresnelColor;
		#else
			reflectColor = _getReflectMap( iN, i.CSPos);
			
			reflectColor = lerp( diffColor, reflectColor, specColor.b);
			
			oColor.rgb += _getFresnelTerm( iN, i.CSPos) * reflectColor * g_FresnelColor;
		#endif
	#endif
	
	return oColor;
}

#endif
