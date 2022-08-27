#if !defined( I3G_BINARY_SHADER)
#include "i3Decl.hlsl"
#include "i3Common.hlsl"
#include "i3ShadowMap.hlsl"
#include "i3DirectionalLight.hlsl"
#include "i3PointLight.hlsl"
#include "i3SpotLight.hlsl"
#include "i3LuxMap.hlsl"
#include "i3Reflection.hlsl"
#include "i3Phong_LightModel.hlsl"
#include "i3HSL_LightModel.hlsl"
#include "i3GI1_LightModel.hlsl"
#include "i3Custom_LightModel.hlsl"

#if defined( I3L_PPL)
	#include "i3VertexShader_PPL.hlsl"
	#include "i3PixelShader_PPL.hlsl"
#else
	#include "i3VertexShader_PVL.hlsl"
	#include "i3PixelShader_PVL.hlsl"
#endif


#endif
