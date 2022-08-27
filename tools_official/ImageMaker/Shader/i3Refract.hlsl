#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//float4 g_RefractiveIndex;
//////////////////////////////////////////////////////
struct VS_OUTPUT_REFRACTION
{
    float4  oPos            : POSITION;
    float3  oTex0           : TEXCOORD0;
};
	
float3 __refract( float3 E, float3 N, float a)
{
	return (-(a - 1) * (dot(N, E) * N)) - E;
}

VS_OUTPUT_REFRACTION VS_Def( in float4 iPos : POSITION,
							 in float2 iTex : TEXCOORD0,
							 in float3 iNormal: NORMAL,
							 in float4 iColor: COLOR)
{
	VS_OUTPUT_REFRACTION o;
	
	float3 WSNormal	= normalize( mul(iNormal, g_mWorldView));
	float3 WSEye	= - normalize( mul( iPos, g_mWorldView));

	float3 ref = __refract( WSEye, WSNormal, 1.333333f);
	ref = ref * 0.5f + 0.5f;
	ref.y = - ref.y;
	
	o.oPos		= mul( iPos, g_mWVP);
	o.oTex0.xy	= ref.xy;
	o.oTex0.z	= iColor.a;
		
	return o;
}


float4 PS_Def( in float3 iTex0 : TEXCOORD0) : COLOR
{
	float4 col = float4( 0.0f, 0.0f, 0.0f, 0.0f);
	if( iTex0.z > 0.01f)
	{
		col = tex2D( g_texDiffuse, iTex0);
	}	
	
	return col;
}