#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

float g_BloomIntensity;
float g_BaseIntensity;
float g_BloomSaturation;
float g_BaseSaturation;

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_txOriginal;
sampler2D	g_texOriginal =
sampler_state
{
    Texture = <g_txOriginal>;
};

texture		g_txBloom;
sampler2D	g_texBloom =
sampler_state
{
    Texture = <g_txBloom>;
};

//////////////////////////////////////////////////////
struct VS_OUTPUT_BLOOMCOMBINE
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};

float4 AdjustSaturation(float4 color, float saturation)
{
    // The constants 0.3, 0.59, and 0.11 are chosen because the
    // human eye is more sensitive to green light, and less to blue.
    float grey = dot(color, float3(0.3, 0.59, 0.11));

    return lerp(grey, color, saturation);
}
	
VS_OUTPUT_BLOOMCOMBINE VS_Def( in float4 iPos : POSITION,
							   in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_BLOOMCOMBINE o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

float4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR0 
{	
	float4 bloomColor = tex2D(g_texBloom, iTex0);
	float4 baseColor = tex2D(g_texOriginal, iTex0);
		
	// Adjust color saturation and intensity.
	bloomColor = AdjustSaturation(bloomColor, g_BloomSaturation) * g_BloomIntensity;
	baseColor = AdjustSaturation(baseColor, g_BaseSaturation) * g_BaseIntensity;

	// Darken down the base image in areas where there is a lot of bloom,
	// to prevent things looking excessively burned-out.
	baseColor *= (1 - saturate(bloomColor));

	// Combine the two images.
	return baseColor + bloomColor;
}
