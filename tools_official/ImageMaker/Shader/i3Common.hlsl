
#define I3L_LIGHTMODEL_NONE			0
#define	I3L_LIGHTMODEL_PHONG		1
#define	I3L_LIGHTMODEL_CUSTOM		2
#define I3L_LIGHTMODEL_HSL			3
#define I3L_LIGHTMODEL_GI1			4

#define I3L_LIGHTTYPE_NONE			0
#define I3L_LIGHTTYPE_DIRECTIONAL	1
#define	I3L_LIGHTTYPE_POINT			2
#define I3L_LIGHTTYPE_SPOT			3

#define	I3L_SHADOW_NONE				0
#define	I3L_SHADOW_SHADOWMAP		1

//#define I3L_ESM
//#define I3L_VSM
//#define I3L_SAVSM
//#define SCREENSPACE_SHADOW

static const int	MAX_BONE = 20;
static const int	MAX_LIGHT = 2;

float4x3	g_mWorld;						// World Matrix
float4x3	g_mView;						// View Matrix
float4x3	g_mInvView;						// Inverse of View Matrix
float4x3	g_mWorldView;					// World * View Matrix
float4x4	g_mViewProj;					// View * Project Matrix
float4x4	g_mProj;						// Project Matrix
float4x4	g_mWVP;							// World * View * Project Matrix

float4x4	g_mShadowMap0;					// View -> Light Space Matrix (for ShadowMap)
float4x4	g_mShadowMap1;				// View -> Light Space Matrix (for ShadowMap)

float4x3	g_mBone[MAX_BONE];				// Skinning Bone Matrix Array

float4x4	g_mTex;

float4		g_vAmbient;
float4		g_vColor;

float3		g_vCamPos;
float3		g_vCamDir;

float4		g_vLightDir0;					// Light Direction
float4		g_vLightPos0;					// Light Position
float4		g_vLightDiffuse0;				// Light Diffuse
float4		g_vLightSpecular0;
float4		g_vLightFactor0;				// x:1/Range^2  y:cos(InnerAngle)   z:cos(OuterAngle)   w:0.0f

float4		g_vLightDir1;					// Light Direction
float4		g_vLightPos1;					// Light Position
float4		g_vLightDiffuse1;				// Light Diffuse
float4		g_vLightSpecular1;
float4		g_vLightFactor1;

float4		g_vMtlEmissive;

float		g_BoneCount;
float		g_FresnelIOR;
float3		g_FresnelColor;

float4		g_SecondaryColor;
float4		g_TetraColor;

//////////////////////////////////////////////////////////////////////
// Diffuse Map 
// Diffuse Map은 항상 Stage 0를 차지하도록 한다.
	texture		g_txDiffuse;
	sampler2D	g_texDiffuse =
	sampler_state
	{
		Texture = <g_txDiffuse>;
	};
	
//////////////////////////////////////////////////////////////////////
// Specular Map 관련
texture		g_txSpecular;
sampler2D	g_texSpecular =
sampler_state
{
	Texture = <g_txSpecular>;
};

//////////////////////////////////////////////////////////////////////
// Emissive Map 관련
texture		g_txEmissive;
sampler2D	g_texEmissive =
sampler_state
{
	Texture = <g_txEmissive>;
};

//////////////////////////////////////////////////////////////////////
// Reflect Cube Map 관련
texture		g_txReflect;
samplerCUBE	g_texReflect =
sampler_state
{
	Texture = <g_txReflect>;
};

//////////////////////////////////////////////////////////////////////
// Reflect Mask Map 관련
texture		g_txReflectMask;
sampler2D	g_texReflectMask =
sampler_state
{
	Texture = <g_txReflectMask>;
};

//////////////////////////////////////////////////////////////////////
// Normal Map 관련
texture		g_txNormal;
sampler2D	g_texNormal =
sampler_state
{
	Texture = <g_txNormal>;
};

//////////////////////////////////////////////////////////////////////
// Lux Map 관련
texture		g_txLux;
sampler2D	g_texLux =
sampler_state
{
	Texture = <g_txLux>;
};

//////////////////////////////////////////////////////////////////////
// Custom Lighting 관련
texture		g_txLightProbe;
samplerCUBE	g_texLightProbe =
sampler_state
{
	Texture = <g_txLightProbe>;
};


//////////////////////////////////////////////////////////////////////
// EarlyZ 관련
texture		g_txEarlyZ;
sampler2D	g_texEarlyZ =
sampler_state
{
	Texture = <g_txEarlyZ>;
};
		
float3 _getSpecular( float3 Normal, float3 csPos, float3 specColor, float specPow, float3 lightPos)
{	
	float3 vReflection   = reflect( normalize( csPos - lightPos), Normal);
	float  fPhongValue   = saturate( dot(vReflection, normalize(-csPos)));

	return pow( fPhongValue, specPow) * specColor;
	//return max( 0.0f, pow( fPhongValue, specPow)) * specColor * litted;
}

float3 _getSpecular_Dir( float3 Normal, float3 csPos, float3 specColor, float specPow, float3 lightDir)
{	
	float3 vReflection   = reflect( -lightDir, Normal);
	float  fPhongValue   = saturate( dot(vReflection, normalize(-csPos)));

	return pow( fPhongValue, specPow) * specColor;
}

void _getNormalMap( out float3 outN, in float2 tex0, in float3 TN, in float3 TT, in float3 TB)
{
	float3 N;
	
	N.xy	= (tex2D( g_texNormal, tex0).xy * 2.0f) - 1.0f;
	N.z		= sqrt( 1.0f - dot( N.xy, N.xy));
	
	outN = normalize( (N.x * TT) - (N.y * TB) + (N.z * TN));
}

float _getPrevZ( in float2 ssPos)
{
	return tex2D( g_texEarlyZ, ssPos).r;
}

half3 _highlight( float3 diffColor, float litted)
{
	return 1.0f + ((diffColor + litted) * 0.3f);
}

half3 _highlight3( float3 diffColor, float3 litted)
{
	return 1.0f + ((diffColor + litted) * 0.3f);
}

//////////////////////////////////////////////

struct VS_INPUT
{
	float4 Pos			: POSITION;
	
	#if defined( I3L_DIFFUSE_MAP) || defined( I3L_NORMAL_MAP) || defined( I3L_SPECULAR_MAP) || defined( I3L_EMISSIVE_MAP) || defined( I3L_REFLECT_MASK_MAP)
		float2 Tex0			: TEXCOORD0;
	#endif
	
	#if defined( I3L_LUX_MAP)
		float2 Tex1			: TEXCOORD1;
	#endif

	#if defined( I3L_VERTEX_BLEND)
		float4 Weights		: BLENDWEIGHT;
		float4 Indices		: BLENDINDICES;
	#endif
	
	#if defined( I3L_LIGHTING) || defined( I3L_REFLECT_MAP)
		float3 Normal		: NORMAL;
		
		#if defined( I3L_NORMAL_MAP)
			float3 Tangent		: TANGENT;
			float3 Binormal		: BINORMAL;
		#endif
	#else
		#if defined( I3L_VERTEX_COLOR)
			float4 Color		: COLOR;
		#endif
	#endif
};

