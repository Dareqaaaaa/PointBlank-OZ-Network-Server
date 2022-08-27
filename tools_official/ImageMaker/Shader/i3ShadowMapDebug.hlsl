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
	
	o.oPos = mul( float4( mul( iPos, g_mWorldView), 1.0f), g_mProj );
	o.oTex0	 = iTex;
	
	return o;
}

float4 PS_Def( in float2 iTex0 : TEXCOORD0) : COLOR
{	
	float4 o;
	
	o = float4( tex2D( g_texDiffuse, iTex0).rg, 0.0f, 1.0f);
	
	if( o.r > 1.0)
	{
		o.b = o.r;
		o.r = 0.0f;
	}
		
	return o;
}

