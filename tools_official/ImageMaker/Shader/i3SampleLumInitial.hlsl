#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_txScaled;
sampler2D	g_texScaled;

//-----------------------------------------------------------------------------
// Global constants
//-----------------------------------------------------------------------------
// The per-color weighting to be used for luminance calculations in RGB order.
static const float3 LUMINANCE_VECTOR  = float3(0.2125f, 0.7154f, 0.0721f);
//static const float3 LUMINANCE_VECTOR  = float3(0.3086f, 0.6094f, 0.0820f);


//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
float2 g_vOffsets[16];


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
float4 PS_Def( in float2 iTex : TEXCOORD0) : COLOR
{	
	float3 vSample;
	float  fLogLumSum = 0.0f;

	for(int iSample = 0; iSample < 9; iSample++)
	{
		// Compute the sum of log(luminance) throughout the sample points
		vSample = tex2D( g_texScaled, iTex + g_vOffsets[iSample]);

		float lum = dot(vSample, LUMINANCE_VECTOR);

		fLogLumSum += log( lum + 0.0001f);
	}

	// Divide the sum to complete the average
	fLogLumSum *= 1.0 / 9.0;

	return float4(fLogLumSum, fLogLumSum, fLogLumSum, 1.0f);
}
