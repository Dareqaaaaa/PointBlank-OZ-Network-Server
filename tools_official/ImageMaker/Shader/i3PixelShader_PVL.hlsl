#if !defined( I3L_PPL)

float4 PS_Def( PS_INPUT i) : COLOR
{	
	float4 specColor, diffColor, oColor, sColor;
	float3 luxColor;
	float3 iN, iR;
	float litted, shadow;
	
	#if defined( I3L_DIFFUSE_MAP)
		diffColor = tex2D( g_texDiffuse, i.Tex0);
	#else
		diffColor = 1.0;
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
	#if defined( I3L_LIGHTING)
		
		#if defined( I3L_LUX_MAP) && (I3L_LIGHTTYPE_0 == I3L_LIGHTTYPE_DIRECTIONAL)
			#if (I3L_SHADOW_0 != I3L_SHADOW_SHADOWMAP)
				oColor = diffColor;
			#else
				#if !defined( SCREENSPACE_SHADOW)
					_getShadow( shadow, i.LSPos0, g_vShadowMapFactor0, g_texShadow0, 1.0f);
				#else
					_getShadow( shadow, i.SSPos, g_vShadowMapFactor1, g_texShadow0, 1.0f, g_mShadowMap0);
				#endif
				
				oColor.rgb = diffColor.rgb - (diffColor.rgb * (1.0f - shadow) * (1.0f - g_vAmbient.r));
				oColor.a = diffColor.a;
			#endif
		#else
			#if defined( I3L_SPECULAR_MAP)
				specColor = tex2D( g_texSpecular, i.Tex0) * float4( 2, 2, 2, 0);
				specColor.rgb *= i.Specular.rgb;
			#else
				specColor = float4( i.Specular.rgb, 0.0f);
			#endif
			
			sColor = float4( _highlight3( diffColor, i.Color), 1.0f);
			
			oColor = (((diffColor * sColor) + specColor) * i.Color) + float4( (diffColor.rgb * g_vAmbient.rgb), 0.0f);
		#endif
	#else
		oColor = diffColor * i.Color;
	#endif
	
	// Reflection
	float3 reflectColor;
	
	#if defined( I3L_REFLECT_MAP)
		reflectColor = _getReflectMap_PVL( i.Reflect);
		
		#if defined( I3L_REFLECT_MASK_MAP)
			float4 mask = tex2D( g_texReflectMask, i.Tex0);
			
			oColor.rgb += reflectColor * mask.rgb;
		#else
			oColor.rgb += reflectColor;
		#endif
	#endif
	
	return oColor;
}

#endif
