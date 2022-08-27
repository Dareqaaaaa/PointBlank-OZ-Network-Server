
//////////////////////////////////////////////////////////////////////
// Shadow Map
float4		g_vShadowMapFactor0;				// [ ShadowMapSize, 1 / ShadowMapSize, Cutoff, Zrange]
float4		g_vShadowMapFactor1;				// [ ShadowMapSize, 1 / ShadowMapSize, Cutoff, Zrange]

sampler2D	g_texShadow0;
sampler2D	g_texShadow1;

#define DEPTH_BIAS		1.0

float CalcVisibility( float SceneDepth, float ShadowmapDepth)
{
	return saturate((ShadowmapDepth - SceneDepth) * (DEPTH_BIAS * 100) + 1);
}


void _getShadow( out float litFactor, in float4 lsPos, in float4 shadowFactor, in sampler2D texShadowMap, float defLit)
{
	float2 uv;
	float z, px;
	half ssm[4];
	float3 coords;
	
	uv = ((0.5 * lsPos.xy / lsPos.w) + float2(0.5f, 0.5f));
	uv.y = 1.0f - uv.y; 
	
	z = saturate( lsPos.z / lsPos.w);
	px = shadowFactor.y;

	float4 Depths;

	Depths = float4(
		tex2D( texShadowMap, uv.xy).r,
		tex2D( texShadowMap, uv.xy + float2(  px,  0)).r,
		tex2D( texShadowMap, uv.xy + float2(  0,  px)).r,
		tex2D( texShadowMap, uv.xy + float2(  px,  px)).r);

	float vis[4];

	// transform to texel space
	float2 texelpos = shadowFactor.x * uv.xy;
        
    // Determine the lerp amounts           
	float2 lerps = frac( texelpos );

	vis[0] = CalcVisibility( z, Depths.x);
	vis[1] = CalcVisibility( z, Depths.y);
	vis[2] = CalcVisibility( z, Depths.z);
	vis[3] = CalcVisibility( z, Depths.w);

	// lerp between the shadow values to calculate our light amount
	litFactor = lerp( lerp( vis[0], vis[1], lerps.x ),
                        lerp( vis[2], vis[3], lerps.x ),
                                  lerps.y );
	
	/*

	if( (uv.x > 0.0f) && (uv.x < 1.0f) && (uv.y > 0.0f) && (uv.y < 1.0f))
	{
		#if defined( I3L_ESM)
			float litZ = tex2D( texShadowMap, uv).r;
			
			litFactor = saturate( litZ * exp( -50.0f * z));
		#else
			float2 lerps = frac( uv * shadowFactor.x);
			
			ssm[0] = (tex2D( texShadowMap, uv).r					+ SHADOW_EPSILON)	> (z) ? PCF_FILTER : 0.0f;
			ssm[1] = (tex2D( texShadowMap, uv + float2( px,	0)).r	+ SHADOW_EPSILON)	> (z) ? PCF_FILTER : 0.0f;
			ssm[2] = (tex2D( texShadowMap, uv + float2( 0,	px)).r	+ SHADOW_EPSILON)	> (z) ? PCF_FILTER : 0.0f;
			ssm[3] = (tex2D( texShadowMap, uv + float2( px,	px)).r	+ SHADOW_EPSILON)	> (z) ? PCF_FILTER : 0.0f;

			litFactor = lerp(	lerp( ssm[0], ssm[1], lerps.x ),	lerp( ssm[2], ssm[3], lerps.x ), lerps.y );
			
		#endif
	}
	else
	{
		litFactor = defLit;
	}
	*/
}
