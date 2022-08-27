#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

struct VS_INPUT_UI
{
	float3		Pos			: POSITION;
	float2		VtxTex		: TEXCOORD0;
	float3		LeftTop		: TEXCOORD1;
	float3		Size		: TEXCOORD2;
	float4		Tex0		: TEXCOORD3;
	float4		TexRange	: TEXCOORD4;
	float4		Color		: COLOR;
};

//////////////////////////////////////////////////////
struct VS_OUTPUT_UI
{
    float4  oPos            : POSITION;
	float2	oVtxTex			: TEXCOORD0;
	float4	oTex0			: TEXCOORD1;
	float4	oTexRange		: TEXCOORD2;
	float4	oColor			: COLOR;
};

float4x4		g_mUIProj;

sampler2D		g_texCache;
sampler2D		g_texRedirect;
sampler2D		g_texFont0;
sampler2D		g_texFont1;

float4			g_vFontFactor;
float4			g_vRedirFactor;			// Redirect texture		{ w, h, 1/w. 1/h }
float4			g_vCache;				// Cache Texture		{ w, h, 1/w, 1/h }
float4			g_vCacheTexel;			// Cache Texture		{ w, h, 1/w, 1/h } * Tile Size

//////////////////////////////////////////////////////////////////////
	
VS_OUTPUT_UI VS_Def( VS_INPUT_UI i)
{
	VS_OUTPUT_UI o;
	float4 pos;
		
	pos = float4( (i.Pos * i.Size) + i.LeftTop, 1);

	o.oPos		= mul( pos, g_mUIProj);
	o.oVtxTex	= i.VtxTex;
	o.oTex0		= i.Tex0;
	o.oTexRange	= i.TexRange;
	o.oColor	= i.Color;

	return o;
}

float2	ResolveVTexCoord( in float2 Tex0)
{
	float2 txlCoord, txlFrac, txlInt;

	txlCoord	= Tex0 * g_vRedirFactor.xy;
	txlFrac		= frac( txlCoord) * g_vRedirFactor.zw;			// Cache Tile 내에서의 Offset 계산을 위해...
	txlInt		= Tex0 - txlFrac;								// 정수화한 좌표

	float4	 RedirInfo = tex2D( g_texRedirect, txlInt + (0.5 * g_vRedirFactor.zw));

	float2	vScale = RedirInfo.zz;
	float2	vTileOrigin = RedirInfo.xy;

	float2	vWithinTile = frac( txlCoord * vScale);

	return vTileOrigin + (vWithinTile * g_vCacheTexel.zw);// - (0.5 * g_vCache.zw);
}

float4 PS_Def(in float2 VtxTex : TEXCOORD0,
			  in float4	TexScaleOffset : TEXCOORD1,
			  in float4 TexRange : TEXCOORD2,
			  in float4	Color : COLOR) : COLOR0
{
	float2 uv, tex0;
	float4 o;

	if( TexRange.x < 0)
	{
		tex0 = (VtxTex * TexScaleOffset.xy) + TexScaleOffset.zw;
		uv = (tex0 + 0.5) * g_vFontFactor.zw;

		o.rgb = (TexRange.y - tex2D( g_texFont0, uv)) * TexRange.z * Color.rgb;

		if( TexRange.w >= 2)
		{
			// Thick shadow
			float3 border[8], b;
			float2 d = g_vFontFactor.zw;

			border[0] = tex2D( g_texFont0, uv + -d);
			border[1] = tex2D( g_texFont0, uv + float2( -d.x, d.y));
			border[2] = tex2D( g_texFont0, uv + float2( d.x, -d.y));
			border[3] = tex2D( g_texFont0, uv + d);

			border[4] = tex2D( g_texFont0, uv + float2( -d.x, 0.0));
			border[5] = tex2D( g_texFont0, uv + float2( d.x, 0.0));
			border[6] = tex2D( g_texFont0, uv + float2( 0.0, -d.y));
			border[7] = tex2D( g_texFont0, uv + float2( 0.0, d.y));

			b = border[0] + border[1] + border[2] + border[3];
			b = b + border[4] + border[5] + border[6] + border[7];

			o.a = any( b + o.r) * Color.a;
		}
		else if( TexRange.w >= 1)
		{
			// right-bottom shadow
			float3 b;
			float2 d = g_vFontFactor.zw;

			b = tex2D( g_texFont0, uv + -d);

			o.a = any( b + o.r) * Color.a;
		}
		else
		{
			// no shadow
			o.a = any( o.rgb) * Color.a;
		}
	}
	else
	{
		tex0 = (VtxTex * TexScaleOffset.xy) + TexScaleOffset.zw;
		uv = ResolveVTexCoord( tex0);

		o = tex2D( g_texCache, uv) * Color;
	}

	return o;
}