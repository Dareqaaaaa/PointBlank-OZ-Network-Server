
float _Directional( float3 Normal, float3 lightDir)
{
	return saturate( dot( lightDir, Normal));
}
