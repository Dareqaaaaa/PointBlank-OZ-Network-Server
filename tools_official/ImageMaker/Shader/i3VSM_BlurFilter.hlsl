#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

#define TAP_COUNT		25

float4 g_Params[TAP_COUNT];

//////////////////////////////////////////////////////
struct VS_OUTPUT_GAUSSIANBLUR
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};
	
VS_OUTPUT_GAUSSIANBLUR VS_Def( in float4 iPos : POSITION,
							 in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_GAUSSIANBLUR o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

float4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR0 
{	
	float4 c = 0;

	// Combine a number of weighted image filter taps.
	for (int i = 0; i < TAP_COUNT; i++)
	{
		float m = tex2D(g_texDiffuse, iTex0 + g_Params[i].xy).r;
		
		c += float4( m, m * m, 0.0f, 0.0f) * g_Params[i].z;
	}
	
	return c;
}
