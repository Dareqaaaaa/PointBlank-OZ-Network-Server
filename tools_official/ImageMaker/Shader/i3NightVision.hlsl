#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

float g_fNVMixRate;

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
texture		g_txInput;
sampler2D	g_texInput =
sampler_state
{
    Texture = <g_txInput>;
};

texture		g_txMask;
sampler2D	g_texMask =
sampler_state
{
	Texture = <g_txMask>;
};


//////////////////////////////////////////////////////
struct VS_OUTPUT_NIGHTVISION
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
    float2  oTex1           : TEXCOORD1;
};

//////////////////////////////////////////////////////////////////////
	
VS_OUTPUT_NIGHTVISION VS_Def( in float4 iPos : POSITION,
							 in float2 iTex : TEXCOORD0,
							 in float2 iTex1 : TEXCOORD1)
{
	VS_OUTPUT_NIGHTVISION o;
		
	o.oPos		= iPos;
	o.oTex0		= iTex;
	o.oTex1		= iTex1;

	return o;
}

float4 PS_Def( in float2 iTex0 : TEXCOORD0, in float2 iTex1 : TEXCOORD1) : COLOR0
{
	float4 c = tex2D( g_texInput,iTex0);			//this takes our sampler and turns the rgba into floats between 0 and 1

	float4 aa = tex2D( g_texMask, iTex1);
	float3 rgb = dot( c.rgb, float3( 1.0f, 1.0f, 1.0f)) * aa.rgb * aa.a;

	c.rgb = c.rgb*g_fNVMixRate + rgb * (1.0f - g_fNVMixRate);
		
	return c;
}