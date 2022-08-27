#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_txInput;
sampler2D	g_texInput =
sampler_state
{
    Texture = <g_txInput>;
};


#define SAMPLE_MAX_COUNT 9

float sampleCount;
float2 SampleOffsets[SAMPLE_MAX_COUNT];
float SampleWeights[SAMPLE_MAX_COUNT];

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
	for (int i = 0; i < sampleCount; i++)
	{
		c += tex2D(g_texInput, iTex0 + SampleOffsets[i]) * SampleWeights[i];
	}

	return c;
}
