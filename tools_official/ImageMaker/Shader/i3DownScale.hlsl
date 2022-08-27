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

//////////////////////////////////////////////////////
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

float4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR
{	
	float4 o;

	o = tex2D( g_texInput, iTex0);	
		
	return o;	
}