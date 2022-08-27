
float _Spot( float3 Normal, float3 csPos, float4 lightFactor, float3 spotDir, float3 lightPos)
{
	float litted, Dfactor, Dv, Ispot;
	float3 lightDir;

	lightDir = lightPos - csPos;
	
	Dv = dot( lightDir, lightDir);		// Square of distance (L-V)
	Dfactor = max( 1 - (Dv * lightFactor.x), 0.0f);
	
	lightDir = normalize( lightDir);
	
	Ispot = max( dot( spotDir, lightDir) - lightFactor.y, 0.0f) * lightFactor.z;
	
	return saturate( dot( lightDir, Normal)) * Dfactor * Ispot;
}
