#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//////////////////////////////////////////////////////
struct VS_OUTPUT
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};

//-----------------------------------------------------------------------------
// Vertex Shader: VertScene
// Desc: Process vertex for scene
//-----------------------------------------------------------------------------

VS_OUTPUT VS_Def( in float4 iPos : POSITION,
					in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT o;
	
	o.oPos = iPos;
	o.oTex0	 = iTex;

	return o;
}

float	g_Step;
float2	g_Texel;

float4 PS_Def( in float2 iTex0 : TEXCOORD0) : COLOR
{	
	float3 a = tex2D( g_texDiffuse, iTex0).rgb;
	float3 b = tex2D( g_texDiffuse, iTex0 - (g_Step * g_Texel)).rgb;
	
	return  float4( a + b, 1.0f);
}

