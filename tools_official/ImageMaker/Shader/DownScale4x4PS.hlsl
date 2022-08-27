#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_txInput;
sampler2D	g_texInput;

//-----------------------------------------------------------------------------
// Global constants
//-----------------------------------------------------------------------------
static const int    MAX_SAMPLES            = 16;    // Maximum texture grabs


//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
float2 vecSampleOffsets[MAX_SAMPLES];


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
// Name: DownScale4x4PS
// Type: Pixel shader                                      
// Desc: Scale the source texture down to 1/16 scale
//-----------------------------------------------------------------------------
float4 PS_Def( in float2 vScreenPosition : TEXCOORD0) : COLOR
{	
    float4 sample = 0.0f;

	for( int i=0; i < 16; i++ )
	{
		sample += tex2D( g_texInput, vScreenPosition + vecSampleOffsets[i] );
	}
    
	return sample / 16;
}
