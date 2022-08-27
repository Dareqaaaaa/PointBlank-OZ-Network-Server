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

float	g_threshold;

//////////////////////////////////////////////////////
struct VS_OUTPUT_BRIGHTPATH
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};
	
VS_OUTPUT_BRIGHTPATH VS_Def( in float4 iPos : POSITION,
							 in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_BRIGHTPATH o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

float4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR0 
{	
	// Look up the original image color.
    float4 c = tex2D(g_texInput, iTex0);
	
    // Adjust it to keep only values brighter than the specified threshold.
    return saturate((c - g_threshold) / (1.0f - g_threshold));        
}
