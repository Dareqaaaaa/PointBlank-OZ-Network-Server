#if !defined( I3L_BINARY_SHADER)
#include "i3Common.hlsl"
#endif

//-----------------------------------------------------------------------------
// Texture samplers
//-----------------------------------------------------------------------------
sampler2D	g_tex1;
sampler2D	g_tex2;

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
// x : The middle gray key value
// y : Smallest Luminance that will be mapped to pure white ^ 2
float2  g_ToneMapCoeff;       


//-----------------------------------------------------------------------------
struct VS_OUTPUT_DOWNSCALE
{
    float4  oPos            : POSITION;
    float2  oTex0           : TEXCOORD0;
};
	
VS_OUTPUT_DOWNSCALE VS_Def( in float4 iPos : POSITION,
							in float2 iTex : TEXCOORD0)
{
	VS_OUTPUT_DOWNSCALE o;
		
	o.oPos = iPos;
	o.oTex0	 = iTex;
	
	return o;
}

static const float3 LUMINANCE_VECTOR  = float3(0.2125f, 0.7154f, 0.0721f);
static const float	s_MiddleGray = g_ToneMapCoeff.x;
static const float	s_LwhiteSQ = g_ToneMapCoeff.y;

//-----------------------------------------------------------------------------
// Name: SampleLumInitial
// Type: Pixel shader                                      
// Desc: Sample the luminance of the source image using a kernal of sample
//       points, and return a scaled image containing the log() of averages
//-----------------------------------------------------------------------------
float4 PS_Def( in float2 iTex : TEXCOORD0) : COLOR
{	
	float4 color = tex2D( g_tex1, iTex);

	float fAdaptedLum = tex2D(g_tex2, float2(0.5f, 0.5f));

	// RGB -> XYZ conversion
	const float3x3 RGB2XYZ ={ 0.5141364, 0.3238786,  0.16036376,
							  0.265068,  0.67023428, 0.06409157,
							  0.0241188, 0.1228178,  0.84442666};				                    
	float3 XYZ = mul( RGB2XYZ, color.rgb);

	// XYZ -> Yxy conversion
	float3 Yxy;
	Yxy.r = XYZ.g;                            // copy luminance Y
	Yxy.g = XYZ.r / (XYZ.r + XYZ.g + XYZ.b ); // x = X / (X + Y + Z)
	Yxy.b = XYZ.g / (XYZ.r + XYZ.g + XYZ.b ); // y = Y / (X + Y + Z)

	// (Lp) Map average luminance to the middlegrey zone by scaling pixel luminance
	float Lp = Yxy.r * s_MiddleGray / fAdaptedLum;                       
	// (Ld) Scale all luminance within a displayable range of 0 to 1
	Yxy.r = (Lp * (1.0f + Lp / s_LwhiteSQ))/(1.0f + Lp);

	// Yxy -> XYZ conversion
	XYZ.r = Yxy.r * Yxy.g / Yxy. b;               // X = Y * x / y
	XYZ.g = Yxy.r;                                // copy luminance Y
	XYZ.b = Yxy.r * (1 - Yxy.g - Yxy.b) / Yxy.b;  // Z = Y * (1-x-y) / y

	// XYZ -> RGB conversion
	const float3x3 XYZ2RGB  = { 2.5651,-1.1665,-0.3986,
							  -1.0217, 1.9777, 0.0439, 
							   0.0753, -0.2543, 1.1892};
	color.rgb = mul(XYZ2RGB, XYZ);


	//float3 LinearColor = pow( color.rgb, 2.2f);
	//color.rgb = pow( saturate( LinearColor), 1.0f/2.2f);

	return color;
}
