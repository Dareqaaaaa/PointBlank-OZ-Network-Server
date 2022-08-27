
float _Point( float3 Normal, float3 csPos, float4 lightFactor, float3 lightPos)
{
	float Dfactor, Dv, rDrange;
	float3 lightDir;

	lightDir = lightPos - csPos;
	
	Dv = dot( lightDir, lightDir);		// Square of distance (L-V)
	rDrange = lightFactor.x;
	Dfactor = max( 1 - (Dv * rDrange), 0.0f);
	
	return saturate( dot( normalize(lightDir), Normal)) * Dfactor;
}
