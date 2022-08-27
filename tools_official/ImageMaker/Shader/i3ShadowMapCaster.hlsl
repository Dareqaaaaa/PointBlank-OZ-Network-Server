#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

float	g_DepthBais;
float	g_DepthSlope;

//////////////////////////////////////////////////////
struct VS_OUTPUT
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
    float4	oShadow			: TEXCOORD1;
};

//-----------------------------------------------------------------------------
// Vertex Shader: VertScene
// Desc: Process vertex for scene
//-----------------------------------------------------------------------------
#if !defined( I3L_VERTEX_BLEND)
	VS_OUTPUT VS_Def( in float4 iPos : POSITION,
						in float2 iTex : TEXCOORD0)
	{
		VS_OUTPUT o;
				
		o.oPos = mul( iPos, g_mWVP );
		o.oShadow = o.oPos;
		o.oTex0	 = iTex;
	    
		return o;
	}
#else

	struct VS_INPUT2
	{
		float4  Pos             : POSITION;
		float4  BlendWeights    : BLENDWEIGHT;
		float4  BlendIndices    : BLENDINDICES;
		float3  Tex0            : TEXCOORD0;
	};
	
	#define WEIGHT(idx)				i.BlendWeights[(idx)]
	#define	INDEX(idx)				i.BlendIndices[(idx)]

	//-----------------------------------------------------------------------------
	// Vertex Shader: VertScene
	// Desc: Process vertex for scene
	//-----------------------------------------------------------------------------
	VS_OUTPUT VS_Def( VS_INPUT2 i)
	{
		VS_OUTPUT o;
		float       LastWeight = 0.0f;
		float3		Pos = 0.0f;
		    
		#if (NUM_BONES > 1)
			LastWeight = LastWeight + WEIGHT(0);			
			Pos					+= mul( i.Pos,		g_mBone[ INDEX(0)]) * WEIGHT(0);
		#endif
		
		#if (NUM_BONES > 2)
			LastWeight = LastWeight + WEIGHT(1);
			Pos					+= mul( i.Pos,		g_mBone[ INDEX(1)]) * WEIGHT(1);
		#endif
		
		#if (NUM_BONES > 3)
			LastWeight = LastWeight + WEIGHT(2);			
			Pos					+= mul( i.Pos,		g_mBone[ INDEX(2)]) * WEIGHT(2);
		#endif
		
		{
			LastWeight = 1.0f - LastWeight;
			
			Pos			+= mul( i.Pos,		g_mBone[ INDEX( NUM_BONES-1)]) * LastWeight;
		}
	    
		o.oPos = mul( float4( Pos, 1.0f), g_mProj);
		o.oShadow = o.oPos;
		o.oTex0 = i.Tex0;
		
		return o;
	}
#endif

float4 PS_Def(	in float2 iTex0 : TEXCOORD0,
				in float4 iShadow : TEXCOORD1) : COLOR
{	
	float4 o;
	float z;
	
	z = (iShadow.z / iShadow.w);
	
	#if defined( I3L_ESM)
	z = exp( 50.0f * z);
	#endif
	
	o.rgb = z;
	
	o.a = tex2D( g_texDiffuse, iTex0).a;
	
	#if defined( I3L_VSM)
		float dx = ddx( o.x);
		float dy = ddy( o.x);
		
		o.y = o.x * o.x; // + (0.25f * ((dx * dx) + (dy * dy)));
	#endif
	
	#if defined( I3L_SAVSM)
		o = (o - 0.5f) * 2.0f;
	#endif
	
	return o;
}

