half3 _getReflectMap( float3 CSNormal, float3 CSPos)
{
	float3 WSNormal = mul( CSNormal, (float3x3) g_mInvView);
	float3 WSEye = -normalize( CSPos);
	WSEye = mul( WSEye, (float3x3) g_mInvView);
	
	float3 ref = reflect( WSNormal, WSEye);
	
	return texCUBE( g_texReflect, ref);
}

half3 _getReflectMap_PVL( float3 ref)
{	
	return texCUBE( g_texReflect, ref);
}

float _getFresnelTerm( float3 camSpaceNormal, float3 CSPos)
{
	float fresnel, sine;
	
	float R0 = pow( (g_FresnelIOR - 1.0f) / ( g_FresnelIOR + 1.0f), 2.0f);

	//sine = 1.0f - saturate( dot( float3( 0, 0, 1), camSpaceNormal));
	sine = 1.0f - saturate( dot( normalize( -CSPos), camSpaceNormal));
	
	fresnel = pow( sine, 5);
	
	//fresnel = R0 + (1.0f - R0) * fresnel;
	fresnel = (1.0f - R0) * fresnel;

	return fresnel;
}

