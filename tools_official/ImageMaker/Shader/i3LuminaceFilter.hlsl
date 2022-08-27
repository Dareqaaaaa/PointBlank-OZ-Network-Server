#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//////////////////////////////////////////////////////
struct VS_OUTPUT_LUMINACE_FILTER
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};
	
VS_OUTPUT_LUMINACE_FILTER VS_Def( in float4 iPos : POSITION,
								  in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_LUMINACE_FILTER o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

float4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR
{	
	float4 inTex = tex2D(g_texDiffuse, iTex0);
	return float4(inTex.x, inTex.y, inTex.z, inTex.w);
}