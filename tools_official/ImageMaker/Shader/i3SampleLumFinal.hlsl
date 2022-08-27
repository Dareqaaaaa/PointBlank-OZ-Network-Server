#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_tx;
sampler2D	g_tex;

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
float2 vecSampleOffsets[16];


//-----------------------------------------------------------------------------
struct VS_OUTPUT_DOWNSCALE
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};
	
VS_OUTPUT_DOWNSCALE VS_Def( in float4 iPos : POSITION,
							in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_DOWNSCALE o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}


//-----------------------------------------------------------------------------
// Name: SampleLumInitial
// Type: Pixel shader                                      
// Desc: Sample the luminance of the source image using a kernal of sample
//       points, and return a scaled image containing the log() of averages
//-----------------------------------------------------------------------------
float4 PS_Def( in float2 vScreenPosition : TEXCOORD0) : COLOR
{	
	float fResampleSum = 0.0f;

	for(int iSample = 0; iSample < 16; iSample++)
	{
		// Compute the sum of luminance throughout the sample points
		fResampleSum += tex2D(g_tex, vScreenPosition + vecSampleOffsets[iSample]);
	}

	// Divide the sum to complete the average, and perform an exp() to complete
	// the average luminance calculation
	fResampleSum = exp( fResampleSum / 16);

	return float4(fResampleSum, fResampleSum, fResampleSum, 1.0f);
}
