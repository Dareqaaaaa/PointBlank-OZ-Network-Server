#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
sampler2D	g_tex1;
sampler2D	g_tex2;


//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
float2 vecSampleOffsets[16];
float  fElapsedTime;      // Time in seconds since the last calculation

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
	float fAdaptedLum = tex2D( g_tex1, float2(0.5f, 0.5f));
    float fCurrentLum = tex2D( g_tex2, float2(0.5f, 0.5f));
    
    // The user's adapted luminance level is simulated by closing the gap between
    // adapted luminance and current luminance by 2% every frame, based on a
    // 30 fps rate. This is not an accurate model of human adaptation, which can
    // take longer than half an hour.
    float fNewAdaptation = fAdaptedLum + (fCurrentLum - fAdaptedLum) * ( 1 - pow( 0.98f, 40 * fElapsedTime ) );

    return float4( fNewAdaptation, fNewAdaptation, fNewAdaptation, 1.0f);
}
