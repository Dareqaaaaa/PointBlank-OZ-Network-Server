#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//////////////////////////////////////////////////////
struct VS_OUTPUT_BIT
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};

sampler2D		g_texInputBase;
sampler2D		g_texInputBlend;
float4			g_blend;
	
VS_OUTPUT_BIT VS_Def( in float4 iPos : POSITION,
							in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_BIT o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

half4 PS_Def(	in float2 iTex0 : TEXCOORD0) : COLOR
{	
	half3 o1, o2;
	half a;

	o1 = tex2D( g_texInputBase, iTex0).rgb;
	o2 = tex2D( g_texInputBlend, iTex0).rgb * g_blend.rgb;

	a = g_blend.a;

	half3 blend = (o1.rgb * (1 - a)) + (o2 * a);

	//blend *= 1.0 / (1.0 + g_blend.a);
		
	return half4( blend, 1.0f);
}
