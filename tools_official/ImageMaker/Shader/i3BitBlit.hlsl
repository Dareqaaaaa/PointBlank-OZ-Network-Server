#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//////////////////////////////////////////////////////
struct VS_OUTPUT_BIT
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};

sampler2D	g_texInput;

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
	half4 o;

	o = tex2D( g_texInput, iTex0);	
		
	return o;	
}
