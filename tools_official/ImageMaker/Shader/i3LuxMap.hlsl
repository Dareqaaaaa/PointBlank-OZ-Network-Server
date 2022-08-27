
float3 _LuxMap( in float3 diffColor, in float2 tex1)
{
	float3 sColor;
	float3 lux;

	lux = tex2D( g_texLux, tex1);
	sColor = 1.0f + ((diffColor + lux) * 0.3f);

	return (sColor * lux * 2);
}
