// Rewrite unchanged result:
var(spec[nothing ], Texture2D<:float4 :>, iChannel0 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel0_sampler )register(s0 );
var(spec[nothing ], Texture2D<:float4 :>, iChannel1 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel1_sampler )register(s0 );
var(spec[nothing ], TextureCube<:float4 :>, iChannel2 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel2_sampler )register(s0 );
var(spec[nothing ], Texture2D<:float4 :>, iChannel3 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel3_sampler )register(s0 );
var(spec[static, nothing ], float4, outColor );
var(spec[static, nothing ], float2, inCoord );
struct(SPIRV_Cross_Input )
{
	field(spec[nothing ], float2, inCoord )semantic(TEXCOORD2 );
};
struct(SPIRV_Cross_Output )
{
	field(spec[nothing ], float4, outColor )semantic(SV_Target0 );
};
var(spec[static, nothing ], float4, iMouse );
var(spec[static, nothing ], float3, iResolution );
var(spec[static, nothing ], float, tt );
var(spec[static, nothing ], float3, glv );
var(spec[static, nothing ], float, iTime );
var(spec[static, nothing ], float, iTimeDelta );
var(spec[static, nothing ], float, iFrameRate );
var(spec[static, nothing ], int, iFrame );
var(spec[static, nothing ], float, iChannelTime[4 ] );
var(spec[static, nothing ], float3, iChannelResolution[4 ] );
var(spec[static, nothing ], float4, iDate );
var(spec[static, nothing ], float, iSampleRate );
func(spec[nothing ], float, mod )
params(var(spec[nothing ], float, x ), var(spec[nothing ], float, y ) )
{
	return <- x - y * floor(x / y );
};
func(spec[nothing ], float2, mod )
params(var(spec[nothing ], float2, x ), var(spec[nothing ], float2, y ) )
{
	return <- x - y * floor(x / y );
};
func(spec[nothing ], float3, mod )
params(var(spec[nothing ], float3, x ), var(spec[nothing ], float3, y ) )
{
	return <- x - y * floor(x / y );
};
func(spec[nothing ], float4, mod )
params(var(spec[nothing ], float4, x ), var(spec[nothing ], float4, y ) )
{
	return <- x - y * floor(x / y );
};
func(spec[nothing ], float3, lattice )
params(var(spec[inout, nothing ], float3, p ), var(spec[nothing ], int, iter ) )
{
	block
	{
		var(spec[nothing ], int, i ) = 0;
		if(0 < iter )
		{
			var(spec[nothing ], float3, _282 ) = p;
			var(spec[nothing ], float2, _284 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282.xy  );
			p.x  = _284.x ;
			p.y  = _284.y ;
			var(spec[nothing ], float3, _289 ) = p;
			var(spec[nothing ], float2, _291 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289.xz  );
			p.x  = _291.x ;
			p.z  = _291.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303 ) = p;
			var(spec[nothing ], float2, _305 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303.xy  );
			p.x  = _305.x ;
			p.y  = _305.y ;
			var(spec[nothing ], float3, _310 ) = p;
			var(spec[nothing ], float2, _312 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310.xz  );
			p.x  = _312.x ;
			p.z  = _312.y ;
		};
		i ++ ;
		if(1 < iter )
		{
			var(spec[nothing ], float3, _282_77 ) = p;
			var(spec[nothing ], float2, _284_77 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_77.xy  );
			p.x  = _284_77.x ;
			p.y  = _284_77.y ;
			var(spec[nothing ], float3, _289_77 ) = p;
			var(spec[nothing ], float2, _291_77 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_77.xz  );
			p.x  = _291_77.x ;
			p.z  = _291_77.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_77 ) = p;
			var(spec[nothing ], float2, _305_77 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_77.xy  );
			p.x  = _305_77.x ;
			p.y  = _305_77.y ;
			var(spec[nothing ], float3, _310_77 ) = p;
			var(spec[nothing ], float2, _312_77 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_77.xz  );
			p.x  = _312_77.x ;
			p.z  = _312_77.y ;
		};
		i ++ ;
		if(2 < iter )
		{
			var(spec[nothing ], float3, _282_78 ) = p;
			var(spec[nothing ], float2, _284_78 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_78.xy  );
			p.x  = _284_78.x ;
			p.y  = _284_78.y ;
			var(spec[nothing ], float3, _289_78 ) = p;
			var(spec[nothing ], float2, _291_78 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_78.xz  );
			p.x  = _291_78.x ;
			p.z  = _291_78.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_78 ) = p;
			var(spec[nothing ], float2, _305_78 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_78.xy  );
			p.x  = _305_78.x ;
			p.y  = _305_78.y ;
			var(spec[nothing ], float3, _310_78 ) = p;
			var(spec[nothing ], float2, _312_78 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_78.xz  );
			p.x  = _312_78.x ;
			p.z  = _312_78.y ;
		};
		i ++ ;
		if(3 < iter )
		{
			var(spec[nothing ], float3, _282_79 ) = p;
			var(spec[nothing ], float2, _284_79 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_79.xy  );
			p.x  = _284_79.x ;
			p.y  = _284_79.y ;
			var(spec[nothing ], float3, _289_79 ) = p;
			var(spec[nothing ], float2, _291_79 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_79.xz  );
			p.x  = _291_79.x ;
			p.z  = _291_79.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_79 ) = p;
			var(spec[nothing ], float2, _305_79 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_79.xy  );
			p.x  = _305_79.x ;
			p.y  = _305_79.y ;
			var(spec[nothing ], float3, _310_79 ) = p;
			var(spec[nothing ], float2, _312_79 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_79.xz  );
			p.x  = _312_79.x ;
			p.z  = _312_79.y ;
		};
		i ++ ;
		if(4 < iter )
		{
			var(spec[nothing ], float3, _282_80 ) = p;
			var(spec[nothing ], float2, _284_80 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_80.xy  );
			p.x  = _284_80.x ;
			p.y  = _284_80.y ;
			var(spec[nothing ], float3, _289_80 ) = p;
			var(spec[nothing ], float2, _291_80 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_80.xz  );
			p.x  = _291_80.x ;
			p.z  = _291_80.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_80 ) = p;
			var(spec[nothing ], float2, _305_80 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_80.xy  );
			p.x  = _305_80.x ;
			p.y  = _305_80.y ;
			var(spec[nothing ], float3, _310_80 ) = p;
			var(spec[nothing ], float2, _312_80 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_80.xz  );
			p.x  = _312_80.x ;
			p.z  = _312_80.y ;
		};
		i ++ ;
		if(5 < iter )
		{
			var(spec[nothing ], float3, _282_81 ) = p;
			var(spec[nothing ], float2, _284_81 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_81.xy  );
			p.x  = _284_81.x ;
			p.y  = _284_81.y ;
			var(spec[nothing ], float3, _289_81 ) = p;
			var(spec[nothing ], float2, _291_81 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_81.xz  );
			p.x  = _291_81.x ;
			p.z  = _291_81.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_81 ) = p;
			var(spec[nothing ], float2, _305_81 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_81.xy  );
			p.x  = _305_81.x ;
			p.y  = _305_81.y ;
			var(spec[nothing ], float3, _310_81 ) = p;
			var(spec[nothing ], float2, _312_81 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_81.xz  );
			p.x  = _312_81.x ;
			p.z  = _312_81.y ;
		};
		i ++ ;
		if(6 < iter )
		{
			var(spec[nothing ], float3, _282_82 ) = p;
			var(spec[nothing ], float2, _284_82 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_82.xy  );
			p.x  = _284_82.x ;
			p.y  = _284_82.y ;
			var(spec[nothing ], float3, _289_82 ) = p;
			var(spec[nothing ], float2, _291_82 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_82.xz  );
			p.x  = _291_82.x ;
			p.z  = _291_82.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_82 ) = p;
			var(spec[nothing ], float2, _305_82 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_82.xy  );
			p.x  = _305_82.x ;
			p.y  = _305_82.y ;
			var(spec[nothing ], float3, _310_82 ) = p;
			var(spec[nothing ], float2, _312_82 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_82.xz  );
			p.x  = _312_82.x ;
			p.z  = _312_82.y ;
		};
		i ++ ;
		if(7 < iter )
		{
			var(spec[nothing ], float3, _282_83 ) = p;
			var(spec[nothing ], float2, _284_83 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_83.xy  );
			p.x  = _284_83.x ;
			p.y  = _284_83.y ;
			var(spec[nothing ], float3, _289_83 ) = p;
			var(spec[nothing ], float2, _291_83 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_83.xz  );
			p.x  = _291_83.x ;
			p.z  = _291_83.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_83 ) = p;
			var(spec[nothing ], float2, _305_83 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_83.xy  );
			p.x  = _305_83.x ;
			p.y  = _305_83.y ;
			var(spec[nothing ], float3, _310_83 ) = p;
			var(spec[nothing ], float2, _312_83 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_83.xz  );
			p.x  = _312_83.x ;
			p.z  = _312_83.y ;
		};
		i ++ ;
		if(8 < iter )
		{
			var(spec[nothing ], float3, _282_84 ) = p;
			var(spec[nothing ], float2, _284_84 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_84.xy  );
			p.x  = _284_84.x ;
			p.y  = _284_84.y ;
			var(spec[nothing ], float3, _289_84 ) = p;
			var(spec[nothing ], float2, _291_84 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_84.xz  );
			p.x  = _291_84.x ;
			p.z  = _291_84.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_84 ) = p;
			var(spec[nothing ], float2, _305_84 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_84.xy  );
			p.x  = _305_84.x ;
			p.y  = _305_84.y ;
			var(spec[nothing ], float3, _310_84 ) = p;
			var(spec[nothing ], float2, _312_84 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_84.xz  );
			p.x  = _312_84.x ;
			p.z  = _312_84.y ;
		};
		i ++ ;
		if(9 < iter )
		{
			var(spec[nothing ], float3, _282_85 ) = p;
			var(spec[nothing ], float2, _284_85 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_85.xy  );
			p.x  = _284_85.x ;
			p.y  = _284_85.y ;
			var(spec[nothing ], float3, _289_85 ) = p;
			var(spec[nothing ], float2, _291_85 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_85.xz  );
			p.x  = _291_85.x ;
			p.z  = _291_85.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_85 ) = p;
			var(spec[nothing ], float2, _305_85 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_85.xy  );
			p.x  = _305_85.x ;
			p.y  = _305_85.y ;
			var(spec[nothing ], float3, _310_85 ) = p;
			var(spec[nothing ], float2, _312_85 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_85.xz  );
			p.x  = _312_85.x ;
			p.z  = _312_85.y ;
		};
		i ++ ;
		if(10 < iter )
		{
			var(spec[nothing ], float3, _282_86 ) = p;
			var(spec[nothing ], float2, _284_86 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_86.xy  );
			p.x  = _284_86.x ;
			p.y  = _284_86.y ;
			var(spec[nothing ], float3, _289_86 ) = p;
			var(spec[nothing ], float2, _291_86 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_86.xz  );
			p.x  = _291_86.x ;
			p.z  = _291_86.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_86 ) = p;
			var(spec[nothing ], float2, _305_86 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_86.xy  );
			p.x  = _305_86.x ;
			p.y  = _305_86.y ;
			var(spec[nothing ], float3, _310_86 ) = p;
			var(spec[nothing ], float2, _312_86 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_86.xz  );
			p.x  = _312_86.x ;
			p.z  = _312_86.y ;
		};
		i ++ ;
		if(11 < iter )
		{
			var(spec[nothing ], float3, _282_87 ) = p;
			var(spec[nothing ], float2, _284_87 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_87.xy  );
			p.x  = _284_87.x ;
			p.y  = _284_87.y ;
			var(spec[nothing ], float3, _289_87 ) = p;
			var(spec[nothing ], float2, _291_87 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_87.xz  );
			p.x  = _291_87.x ;
			p.z  = _291_87.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_87 ) = p;
			var(spec[nothing ], float2, _305_87 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_87.xy  );
			p.x  = _305_87.x ;
			p.y  = _305_87.y ;
			var(spec[nothing ], float3, _310_87 ) = p;
			var(spec[nothing ], float2, _312_87 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_87.xz  );
			p.x  = _312_87.x ;
			p.z  = _312_87.y ;
		};
		i ++ ;
		if(12 < iter )
		{
			var(spec[nothing ], float3, _282_88 ) = p;
			var(spec[nothing ], float2, _284_88 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_88.xy  );
			p.x  = _284_88.x ;
			p.y  = _284_88.y ;
			var(spec[nothing ], float3, _289_88 ) = p;
			var(spec[nothing ], float2, _291_88 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_88.xz  );
			p.x  = _291_88.x ;
			p.z  = _291_88.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_88 ) = p;
			var(spec[nothing ], float2, _305_88 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_88.xy  );
			p.x  = _305_88.x ;
			p.y  = _305_88.y ;
			var(spec[nothing ], float3, _310_88 ) = p;
			var(spec[nothing ], float2, _312_88 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_88.xz  );
			p.x  = _312_88.x ;
			p.z  = _312_88.y ;
		};
		i ++ ;
		if(13 < iter )
		{
			var(spec[nothing ], float3, _282_89 ) = p;
			var(spec[nothing ], float2, _284_89 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_89.xy  );
			p.x  = _284_89.x ;
			p.y  = _284_89.y ;
			var(spec[nothing ], float3, _289_89 ) = p;
			var(spec[nothing ], float2, _291_89 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_89.xz  );
			p.x  = _291_89.x ;
			p.z  = _291_89.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_89 ) = p;
			var(spec[nothing ], float2, _305_89 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_89.xy  );
			p.x  = _305_89.x ;
			p.y  = _305_89.y ;
			var(spec[nothing ], float3, _310_89 ) = p;
			var(spec[nothing ], float2, _312_89 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_89.xz  );
			p.x  = _312_89.x ;
			p.z  = _312_89.y ;
		};
		i ++ ;
		if(14 < iter )
		{
			var(spec[nothing ], float3, _282_90 ) = p;
			var(spec[nothing ], float2, _284_90 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_90.xy  );
			p.x  = _284_90.x ;
			p.y  = _284_90.y ;
			var(spec[nothing ], float3, _289_90 ) = p;
			var(spec[nothing ], float2, _291_90 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_90.xz  );
			p.x  = _291_90.x ;
			p.z  = _291_90.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_90 ) = p;
			var(spec[nothing ], float2, _305_90 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_90.xy  );
			p.x  = _305_90.x ;
			p.y  = _305_90.y ;
			var(spec[nothing ], float3, _310_90 ) = p;
			var(spec[nothing ], float2, _312_90 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_90.xz  );
			p.x  = _312_90.x ;
			p.z  = _312_90.y ;
		};
		i ++ ;
		if(15 < iter )
		{
			var(spec[nothing ], float3, _282_91 ) = p;
			var(spec[nothing ], float2, _284_91 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_91.xy  );
			p.x  = _284_91.x ;
			p.y  = _284_91.y ;
			var(spec[nothing ], float3, _289_91 ) = p;
			var(spec[nothing ], float2, _291_91 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_91.xz  );
			p.x  = _291_91.x ;
			p.z  = _291_91.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_91 ) = p;
			var(spec[nothing ], float2, _305_91 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_91.xy  );
			p.x  = _305_91.x ;
			p.y  = _305_91.y ;
			var(spec[nothing ], float3, _310_91 ) = p;
			var(spec[nothing ], float2, _312_91 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_91.xz  );
			p.x  = _312_91.x ;
			p.z  = _312_91.y ;
		};
		i ++ ;
		if(16 < iter )
		{
			var(spec[nothing ], float3, _282_92 ) = p;
			var(spec[nothing ], float2, _284_92 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_92.xy  );
			p.x  = _284_92.x ;
			p.y  = _284_92.y ;
			var(spec[nothing ], float3, _289_92 ) = p;
			var(spec[nothing ], float2, _291_92 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_92.xz  );
			p.x  = _291_92.x ;
			p.z  = _291_92.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_92 ) = p;
			var(spec[nothing ], float2, _305_92 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_92.xy  );
			p.x  = _305_92.x ;
			p.y  = _305_92.y ;
			var(spec[nothing ], float3, _310_92 ) = p;
			var(spec[nothing ], float2, _312_92 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_92.xz  );
			p.x  = _312_92.x ;
			p.z  = _312_92.y ;
		};
		i ++ ;
		if(17 < iter )
		{
			var(spec[nothing ], float3, _282_93 ) = p;
			var(spec[nothing ], float2, _284_93 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_93.xy  );
			p.x  = _284_93.x ;
			p.y  = _284_93.y ;
			var(spec[nothing ], float3, _289_93 ) = p;
			var(spec[nothing ], float2, _291_93 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_93.xz  );
			p.x  = _291_93.x ;
			p.z  = _291_93.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_93 ) = p;
			var(spec[nothing ], float2, _305_93 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_93.xy  );
			p.x  = _305_93.x ;
			p.y  = _305_93.y ;
			var(spec[nothing ], float3, _310_93 ) = p;
			var(spec[nothing ], float2, _312_93 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_93.xz  );
			p.x  = _312_93.x ;
			p.z  = _312_93.y ;
		};
		i ++ ;
		if(18 < iter )
		{
			var(spec[nothing ], float3, _282_94 ) = p;
			var(spec[nothing ], float2, _284_94 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_94.xy  );
			p.x  = _284_94.x ;
			p.y  = _284_94.y ;
			var(spec[nothing ], float3, _289_94 ) = p;
			var(spec[nothing ], float2, _291_94 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_94.xz  );
			p.x  = _291_94.x ;
			p.z  = _291_94.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_94 ) = p;
			var(spec[nothing ], float2, _305_94 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_94.xy  );
			p.x  = _305_94.x ;
			p.y  = _305_94.y ;
			var(spec[nothing ], float3, _310_94 ) = p;
			var(spec[nothing ], float2, _312_94 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_94.xz  );
			p.x  = _312_94.x ;
			p.z  = _312_94.y ;
		};
		i ++ ;
		if(19 < iter )
		{
			var(spec[nothing ], float3, _282_95 ) = p;
			var(spec[nothing ], float2, _284_95 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_95.xy  );
			p.x  = _284_95.x ;
			p.y  = _284_95.y ;
			var(spec[nothing ], float3, _289_95 ) = p;
			var(spec[nothing ], float2, _291_95 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_95.xz  );
			p.x  = _291_95.x ;
			p.z  = _291_95.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_95 ) = p;
			var(spec[nothing ], float2, _305_95 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_95.xy  );
			p.x  = _305_95.x ;
			p.y  = _305_95.y ;
			var(spec[nothing ], float3, _310_95 ) = p;
			var(spec[nothing ], float2, _312_95 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_95.xz  );
			p.x  = _312_95.x ;
			p.z  = _312_95.y ;
		};
		i ++ ;
		if(20 < iter )
		{
			var(spec[nothing ], float3, _282_96 ) = p;
			var(spec[nothing ], float2, _284_96 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_96.xy  );
			p.x  = _284_96.x ;
			p.y  = _284_96.y ;
			var(spec[nothing ], float3, _289_96 ) = p;
			var(spec[nothing ], float2, _291_96 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_96.xz  );
			p.x  = _291_96.x ;
			p.z  = _291_96.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_96 ) = p;
			var(spec[nothing ], float2, _305_96 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_96.xy  );
			p.x  = _305_96.x ;
			p.y  = _305_96.y ;
			var(spec[nothing ], float3, _310_96 ) = p;
			var(spec[nothing ], float2, _312_96 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_96.xz  );
			p.x  = _312_96.x ;
			p.z  = _312_96.y ;
		};
		i ++ ;
		if(21 < iter )
		{
			var(spec[nothing ], float3, _282_97 ) = p;
			var(spec[nothing ], float2, _284_97 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_97.xy  );
			p.x  = _284_97.x ;
			p.y  = _284_97.y ;
			var(spec[nothing ], float3, _289_97 ) = p;
			var(spec[nothing ], float2, _291_97 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_97.xz  );
			p.x  = _291_97.x ;
			p.z  = _291_97.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_97 ) = p;
			var(spec[nothing ], float2, _305_97 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_97.xy  );
			p.x  = _305_97.x ;
			p.y  = _305_97.y ;
			var(spec[nothing ], float3, _310_97 ) = p;
			var(spec[nothing ], float2, _312_97 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_97.xz  );
			p.x  = _312_97.x ;
			p.z  = _312_97.y ;
		};
		i ++ ;
		if(22 < iter )
		{
			var(spec[nothing ], float3, _282_98 ) = p;
			var(spec[nothing ], float2, _284_98 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_98.xy  );
			p.x  = _284_98.x ;
			p.y  = _284_98.y ;
			var(spec[nothing ], float3, _289_98 ) = p;
			var(spec[nothing ], float2, _291_98 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_98.xz  );
			p.x  = _291_98.x ;
			p.z  = _291_98.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_98 ) = p;
			var(spec[nothing ], float2, _305_98 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_98.xy  );
			p.x  = _305_98.x ;
			p.y  = _305_98.y ;
			var(spec[nothing ], float3, _310_98 ) = p;
			var(spec[nothing ], float2, _312_98 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_98.xz  );
			p.x  = _312_98.x ;
			p.z  = _312_98.y ;
		};
		i ++ ;
		if(23 < iter )
		{
			var(spec[nothing ], float3, _282_99 ) = p;
			var(spec[nothing ], float2, _284_99 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_99.xy  );
			p.x  = _284_99.x ;
			p.y  = _284_99.y ;
			var(spec[nothing ], float3, _289_99 ) = p;
			var(spec[nothing ], float2, _291_99 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_99.xz  );
			p.x  = _291_99.x ;
			p.z  = _291_99.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_99 ) = p;
			var(spec[nothing ], float2, _305_99 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_99.xy  );
			p.x  = _305_99.x ;
			p.y  = _305_99.y ;
			var(spec[nothing ], float3, _310_99 ) = p;
			var(spec[nothing ], float2, _312_99 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_99.xz  );
			p.x  = _312_99.x ;
			p.z  = _312_99.y ;
		};
		i ++ ;
		if(24 < iter )
		{
			var(spec[nothing ], float3, _282_100 ) = p;
			var(spec[nothing ], float2, _284_100 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_100.xy  );
			p.x  = _284_100.x ;
			p.y  = _284_100.y ;
			var(spec[nothing ], float3, _289_100 ) = p;
			var(spec[nothing ], float2, _291_100 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_100.xz  );
			p.x  = _291_100.x ;
			p.z  = _291_100.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_100 ) = p;
			var(spec[nothing ], float2, _305_100 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_100.xy  );
			p.x  = _305_100.x ;
			p.y  = _305_100.y ;
			var(spec[nothing ], float3, _310_100 ) = p;
			var(spec[nothing ], float2, _312_100 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_100.xz  );
			p.x  = _312_100.x ;
			p.z  = _312_100.y ;
		};
		i ++ ;
		if(25 < iter )
		{
			var(spec[nothing ], float3, _282_101 ) = p;
			var(spec[nothing ], float2, _284_101 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_101.xy  );
			p.x  = _284_101.x ;
			p.y  = _284_101.y ;
			var(spec[nothing ], float3, _289_101 ) = p;
			var(spec[nothing ], float2, _291_101 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_101.xz  );
			p.x  = _291_101.x ;
			p.z  = _291_101.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_101 ) = p;
			var(spec[nothing ], float2, _305_101 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_101.xy  );
			p.x  = _305_101.x ;
			p.y  = _305_101.y ;
			var(spec[nothing ], float3, _310_101 ) = p;
			var(spec[nothing ], float2, _312_101 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_101.xz  );
			p.x  = _312_101.x ;
			p.z  = _312_101.y ;
		};
		i ++ ;
		if(26 < iter )
		{
			var(spec[nothing ], float3, _282_102 ) = p;
			var(spec[nothing ], float2, _284_102 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_102.xy  );
			p.x  = _284_102.x ;
			p.y  = _284_102.y ;
			var(spec[nothing ], float3, _289_102 ) = p;
			var(spec[nothing ], float2, _291_102 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_102.xz  );
			p.x  = _291_102.x ;
			p.z  = _291_102.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_102 ) = p;
			var(spec[nothing ], float2, _305_102 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_102.xy  );
			p.x  = _305_102.x ;
			p.y  = _305_102.y ;
			var(spec[nothing ], float3, _310_102 ) = p;
			var(spec[nothing ], float2, _312_102 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_102.xz  );
			p.x  = _312_102.x ;
			p.z  = _312_102.y ;
		};
		i ++ ;
		if(27 < iter )
		{
			var(spec[nothing ], float3, _282_103 ) = p;
			var(spec[nothing ], float2, _284_103 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_103.xy  );
			p.x  = _284_103.x ;
			p.y  = _284_103.y ;
			var(spec[nothing ], float3, _289_103 ) = p;
			var(spec[nothing ], float2, _291_103 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_103.xz  );
			p.x  = _291_103.x ;
			p.z  = _291_103.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_103 ) = p;
			var(spec[nothing ], float2, _305_103 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_103.xy  );
			p.x  = _305_103.x ;
			p.y  = _305_103.y ;
			var(spec[nothing ], float3, _310_103 ) = p;
			var(spec[nothing ], float2, _312_103 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_103.xz  );
			p.x  = _312_103.x ;
			p.z  = _312_103.y ;
		};
		i ++ ;
		if(28 < iter )
		{
			var(spec[nothing ], float3, _282_104 ) = p;
			var(spec[nothing ], float2, _284_104 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_104.xy  );
			p.x  = _284_104.x ;
			p.y  = _284_104.y ;
			var(spec[nothing ], float3, _289_104 ) = p;
			var(spec[nothing ], float2, _291_104 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_104.xz  );
			p.x  = _291_104.x ;
			p.z  = _291_104.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_104 ) = p;
			var(spec[nothing ], float2, _305_104 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_104.xy  );
			p.x  = _305_104.x ;
			p.y  = _305_104.y ;
			var(spec[nothing ], float3, _310_104 ) = p;
			var(spec[nothing ], float2, _312_104 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_104.xz  );
			p.x  = _312_104.x ;
			p.z  = _312_104.y ;
		};
		i ++ ;
		if(29 < iter )
		{
			var(spec[nothing ], float3, _282_105 ) = p;
			var(spec[nothing ], float2, _284_105 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_105.xy  );
			p.x  = _284_105.x ;
			p.y  = _284_105.y ;
			var(spec[nothing ], float3, _289_105 ) = p;
			var(spec[nothing ], float2, _291_105 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_105.xz  );
			p.x  = _291_105.x ;
			p.z  = _291_105.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_105 ) = p;
			var(spec[nothing ], float2, _305_105 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_105.xy  );
			p.x  = _305_105.x ;
			p.y  = _305_105.y ;
			var(spec[nothing ], float3, _310_105 ) = p;
			var(spec[nothing ], float2, _312_105 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_105.xz  );
			p.x  = _312_105.x ;
			p.z  = _312_105.y ;
		};
		i ++ ;
		if(30 < iter )
		{
			var(spec[nothing ], float3, _282_106 ) = p;
			var(spec[nothing ], float2, _284_106 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_106.xy  );
			p.x  = _284_106.x ;
			p.y  = _284_106.y ;
			var(spec[nothing ], float3, _289_106 ) = p;
			var(spec[nothing ], float2, _291_106 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_106.xz  );
			p.x  = _291_106.x ;
			p.z  = _291_106.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_106 ) = p;
			var(spec[nothing ], float2, _305_106 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_106.xy  );
			p.x  = _305_106.x ;
			p.y  = _305_106.y ;
			var(spec[nothing ], float3, _310_106 ) = p;
			var(spec[nothing ], float2, _312_106 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_106.xz  );
			p.x  = _312_106.x ;
			p.z  = _312_106.y ;
		};
		i ++ ;
		if(31 < iter )
		{
			var(spec[nothing ], float3, _282_107 ) = p;
			var(spec[nothing ], float2, _284_107 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_107.xy  );
			p.x  = _284_107.x ;
			p.y  = _284_107.y ;
			var(spec[nothing ], float3, _289_107 ) = p;
			var(spec[nothing ], float2, _291_107 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_107.xz  );
			p.x  = _291_107.x ;
			p.z  = _291_107.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_107 ) = p;
			var(spec[nothing ], float2, _305_107 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_107.xy  );
			p.x  = _305_107.x ;
			p.y  = _305_107.y ;
			var(spec[nothing ], float3, _310_107 ) = p;
			var(spec[nothing ], float2, _312_107 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_107.xz  );
			p.x  = _312_107.x ;
			p.z  = _312_107.y ;
		};
		i ++ ;
		if(32 < iter )
		{
			var(spec[nothing ], float3, _282_108 ) = p;
			var(spec[nothing ], float2, _284_108 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_108.xy  );
			p.x  = _284_108.x ;
			p.y  = _284_108.y ;
			var(spec[nothing ], float3, _289_108 ) = p;
			var(spec[nothing ], float2, _291_108 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_108.xz  );
			p.x  = _291_108.x ;
			p.z  = _291_108.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_108 ) = p;
			var(spec[nothing ], float2, _305_108 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_108.xy  );
			p.x  = _305_108.x ;
			p.y  = _305_108.y ;
			var(spec[nothing ], float3, _310_108 ) = p;
			var(spec[nothing ], float2, _312_108 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_108.xz  );
			p.x  = _312_108.x ;
			p.z  = _312_108.y ;
		};
		i ++ ;
		if(33 < iter )
		{
			var(spec[nothing ], float3, _282_109 ) = p;
			var(spec[nothing ], float2, _284_109 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_109.xy  );
			p.x  = _284_109.x ;
			p.y  = _284_109.y ;
			var(spec[nothing ], float3, _289_109 ) = p;
			var(spec[nothing ], float2, _291_109 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_109.xz  );
			p.x  = _291_109.x ;
			p.z  = _291_109.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_109 ) = p;
			var(spec[nothing ], float2, _305_109 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_109.xy  );
			p.x  = _305_109.x ;
			p.y  = _305_109.y ;
			var(spec[nothing ], float3, _310_109 ) = p;
			var(spec[nothing ], float2, _312_109 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_109.xz  );
			p.x  = _312_109.x ;
			p.z  = _312_109.y ;
		};
		i ++ ;
		if(34 < iter )
		{
			var(spec[nothing ], float3, _282_110 ) = p;
			var(spec[nothing ], float2, _284_110 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_110.xy  );
			p.x  = _284_110.x ;
			p.y  = _284_110.y ;
			var(spec[nothing ], float3, _289_110 ) = p;
			var(spec[nothing ], float2, _291_110 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_110.xz  );
			p.x  = _291_110.x ;
			p.z  = _291_110.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_110 ) = p;
			var(spec[nothing ], float2, _305_110 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_110.xy  );
			p.x  = _305_110.x ;
			p.y  = _305_110.y ;
			var(spec[nothing ], float3, _310_110 ) = p;
			var(spec[nothing ], float2, _312_110 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_110.xz  );
			p.x  = _312_110.x ;
			p.z  = _312_110.y ;
		};
		i ++ ;
		if(35 < iter )
		{
			var(spec[nothing ], float3, _282_111 ) = p;
			var(spec[nothing ], float2, _284_111 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_111.xy  );
			p.x  = _284_111.x ;
			p.y  = _284_111.y ;
			var(spec[nothing ], float3, _289_111 ) = p;
			var(spec[nothing ], float2, _291_111 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_111.xz  );
			p.x  = _291_111.x ;
			p.z  = _291_111.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_111 ) = p;
			var(spec[nothing ], float2, _305_111 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_111.xy  );
			p.x  = _305_111.x ;
			p.y  = _305_111.y ;
			var(spec[nothing ], float3, _310_111 ) = p;
			var(spec[nothing ], float2, _312_111 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_111.xz  );
			p.x  = _312_111.x ;
			p.z  = _312_111.y ;
		};
		i ++ ;
		if(36 < iter )
		{
			var(spec[nothing ], float3, _282_112 ) = p;
			var(spec[nothing ], float2, _284_112 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_112.xy  );
			p.x  = _284_112.x ;
			p.y  = _284_112.y ;
			var(spec[nothing ], float3, _289_112 ) = p;
			var(spec[nothing ], float2, _291_112 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_112.xz  );
			p.x  = _291_112.x ;
			p.z  = _291_112.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_112 ) = p;
			var(spec[nothing ], float2, _305_112 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_112.xy  );
			p.x  = _305_112.x ;
			p.y  = _305_112.y ;
			var(spec[nothing ], float3, _310_112 ) = p;
			var(spec[nothing ], float2, _312_112 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_112.xz  );
			p.x  = _312_112.x ;
			p.z  = _312_112.y ;
		};
		i ++ ;
		if(37 < iter )
		{
			var(spec[nothing ], float3, _282_113 ) = p;
			var(spec[nothing ], float2, _284_113 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_113.xy  );
			p.x  = _284_113.x ;
			p.y  = _284_113.y ;
			var(spec[nothing ], float3, _289_113 ) = p;
			var(spec[nothing ], float2, _291_113 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_113.xz  );
			p.x  = _291_113.x ;
			p.z  = _291_113.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_113 ) = p;
			var(spec[nothing ], float2, _305_113 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_113.xy  );
			p.x  = _305_113.x ;
			p.y  = _305_113.y ;
			var(spec[nothing ], float3, _310_113 ) = p;
			var(spec[nothing ], float2, _312_113 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_113.xz  );
			p.x  = _312_113.x ;
			p.z  = _312_113.y ;
		};
		i ++ ;
		if(38 < iter )
		{
			var(spec[nothing ], float3, _282_114 ) = p;
			var(spec[nothing ], float2, _284_114 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_114.xy  );
			p.x  = _284_114.x ;
			p.y  = _284_114.y ;
			var(spec[nothing ], float3, _289_114 ) = p;
			var(spec[nothing ], float2, _291_114 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_114.xz  );
			p.x  = _291_114.x ;
			p.z  = _291_114.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_114 ) = p;
			var(spec[nothing ], float2, _305_114 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_114.xy  );
			p.x  = _305_114.x ;
			p.y  = _305_114.y ;
			var(spec[nothing ], float3, _310_114 ) = p;
			var(spec[nothing ], float2, _312_114 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_114.xz  );
			p.x  = _312_114.x ;
			p.z  = _312_114.y ;
		};
		i ++ ;
		if(39 < iter )
		{
			var(spec[nothing ], float3, _282_115 ) = p;
			var(spec[nothing ], float2, _284_115 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_115.xy  );
			p.x  = _284_115.x ;
			p.y  = _284_115.y ;
			var(spec[nothing ], float3, _289_115 ) = p;
			var(spec[nothing ], float2, _291_115 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_115.xz  );
			p.x  = _291_115.x ;
			p.z  = _291_115.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_115 ) = p;
			var(spec[nothing ], float2, _305_115 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_115.xy  );
			p.x  = _305_115.x ;
			p.y  = _305_115.y ;
			var(spec[nothing ], float3, _310_115 ) = p;
			var(spec[nothing ], float2, _312_115 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_115.xz  );
			p.x  = _312_115.x ;
			p.z  = _312_115.y ;
		};
		i ++ ;
		if(40 < iter )
		{
			var(spec[nothing ], float3, _282_116 ) = p;
			var(spec[nothing ], float2, _284_116 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_116.xy  );
			p.x  = _284_116.x ;
			p.y  = _284_116.y ;
			var(spec[nothing ], float3, _289_116 ) = p;
			var(spec[nothing ], float2, _291_116 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_116.xz  );
			p.x  = _291_116.x ;
			p.z  = _291_116.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_116 ) = p;
			var(spec[nothing ], float2, _305_116 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_116.xy  );
			p.x  = _305_116.x ;
			p.y  = _305_116.y ;
			var(spec[nothing ], float3, _310_116 ) = p;
			var(spec[nothing ], float2, _312_116 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_116.xz  );
			p.x  = _312_116.x ;
			p.z  = _312_116.y ;
		};
		i ++ ;
		if(41 < iter )
		{
			var(spec[nothing ], float3, _282_117 ) = p;
			var(spec[nothing ], float2, _284_117 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_117.xy  );
			p.x  = _284_117.x ;
			p.y  = _284_117.y ;
			var(spec[nothing ], float3, _289_117 ) = p;
			var(spec[nothing ], float2, _291_117 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_117.xz  );
			p.x  = _291_117.x ;
			p.z  = _291_117.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_117 ) = p;
			var(spec[nothing ], float2, _305_117 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_117.xy  );
			p.x  = _305_117.x ;
			p.y  = _305_117.y ;
			var(spec[nothing ], float3, _310_117 ) = p;
			var(spec[nothing ], float2, _312_117 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_117.xz  );
			p.x  = _312_117.x ;
			p.z  = _312_117.y ;
		};
		i ++ ;
		if(42 < iter )
		{
			var(spec[nothing ], float3, _282_118 ) = p;
			var(spec[nothing ], float2, _284_118 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_118.xy  );
			p.x  = _284_118.x ;
			p.y  = _284_118.y ;
			var(spec[nothing ], float3, _289_118 ) = p;
			var(spec[nothing ], float2, _291_118 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_118.xz  );
			p.x  = _291_118.x ;
			p.z  = _291_118.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_118 ) = p;
			var(spec[nothing ], float2, _305_118 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_118.xy  );
			p.x  = _305_118.x ;
			p.y  = _305_118.y ;
			var(spec[nothing ], float3, _310_118 ) = p;
			var(spec[nothing ], float2, _312_118 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_118.xz  );
			p.x  = _312_118.x ;
			p.z  = _312_118.y ;
		};
		i ++ ;
		if(43 < iter )
		{
			var(spec[nothing ], float3, _282_119 ) = p;
			var(spec[nothing ], float2, _284_119 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_119.xy  );
			p.x  = _284_119.x ;
			p.y  = _284_119.y ;
			var(spec[nothing ], float3, _289_119 ) = p;
			var(spec[nothing ], float2, _291_119 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_119.xz  );
			p.x  = _291_119.x ;
			p.z  = _291_119.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_119 ) = p;
			var(spec[nothing ], float2, _305_119 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_119.xy  );
			p.x  = _305_119.x ;
			p.y  = _305_119.y ;
			var(spec[nothing ], float3, _310_119 ) = p;
			var(spec[nothing ], float2, _312_119 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_119.xz  );
			p.x  = _312_119.x ;
			p.z  = _312_119.y ;
		};
		i ++ ;
		if(44 < iter )
		{
			var(spec[nothing ], float3, _282_120 ) = p;
			var(spec[nothing ], float2, _284_120 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_120.xy  );
			p.x  = _284_120.x ;
			p.y  = _284_120.y ;
			var(spec[nothing ], float3, _289_120 ) = p;
			var(spec[nothing ], float2, _291_120 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_120.xz  );
			p.x  = _291_120.x ;
			p.z  = _291_120.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_120 ) = p;
			var(spec[nothing ], float2, _305_120 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_120.xy  );
			p.x  = _305_120.x ;
			p.y  = _305_120.y ;
			var(spec[nothing ], float3, _310_120 ) = p;
			var(spec[nothing ], float2, _312_120 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_120.xz  );
			p.x  = _312_120.x ;
			p.z  = _312_120.y ;
		};
		i ++ ;
		if(45 < iter )
		{
			var(spec[nothing ], float3, _282_121 ) = p;
			var(spec[nothing ], float2, _284_121 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_121.xy  );
			p.x  = _284_121.x ;
			p.y  = _284_121.y ;
			var(spec[nothing ], float3, _289_121 ) = p;
			var(spec[nothing ], float2, _291_121 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_121.xz  );
			p.x  = _291_121.x ;
			p.z  = _291_121.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_121 ) = p;
			var(spec[nothing ], float2, _305_121 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_121.xy  );
			p.x  = _305_121.x ;
			p.y  = _305_121.y ;
			var(spec[nothing ], float3, _310_121 ) = p;
			var(spec[nothing ], float2, _312_121 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_121.xz  );
			p.x  = _312_121.x ;
			p.z  = _312_121.y ;
		};
		i ++ ;
		if(46 < iter )
		{
			var(spec[nothing ], float3, _282_122 ) = p;
			var(spec[nothing ], float2, _284_122 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_122.xy  );
			p.x  = _284_122.x ;
			p.y  = _284_122.y ;
			var(spec[nothing ], float3, _289_122 ) = p;
			var(spec[nothing ], float2, _291_122 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_122.xz  );
			p.x  = _291_122.x ;
			p.z  = _291_122.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_122 ) = p;
			var(spec[nothing ], float2, _305_122 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_122.xy  );
			p.x  = _305_122.x ;
			p.y  = _305_122.y ;
			var(spec[nothing ], float3, _310_122 ) = p;
			var(spec[nothing ], float2, _312_122 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_122.xz  );
			p.x  = _312_122.x ;
			p.z  = _312_122.y ;
		};
		i ++ ;
		if(47 < iter )
		{
			var(spec[nothing ], float3, _282_123 ) = p;
			var(spec[nothing ], float2, _284_123 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_123.xy  );
			p.x  = _284_123.x ;
			p.y  = _284_123.y ;
			var(spec[nothing ], float3, _289_123 ) = p;
			var(spec[nothing ], float2, _291_123 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_123.xz  );
			p.x  = _291_123.x ;
			p.z  = _291_123.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_123 ) = p;
			var(spec[nothing ], float2, _305_123 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_123.xy  );
			p.x  = _305_123.x ;
			p.y  = _305_123.y ;
			var(spec[nothing ], float3, _310_123 ) = p;
			var(spec[nothing ], float2, _312_123 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_123.xz  );
			p.x  = _312_123.x ;
			p.z  = _312_123.y ;
		};
		i ++ ;
		if(48 < iter )
		{
			var(spec[nothing ], float3, _282_124 ) = p;
			var(spec[nothing ], float2, _284_124 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_124.xy  );
			p.x  = _284_124.x ;
			p.y  = _284_124.y ;
			var(spec[nothing ], float3, _289_124 ) = p;
			var(spec[nothing ], float2, _291_124 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_124.xz  );
			p.x  = _291_124.x ;
			p.z  = _291_124.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_124 ) = p;
			var(spec[nothing ], float2, _305_124 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_124.xy  );
			p.x  = _305_124.x ;
			p.y  = _305_124.y ;
			var(spec[nothing ], float3, _310_124 ) = p;
			var(spec[nothing ], float2, _312_124 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_124.xz  );
			p.x  = _312_124.x ;
			p.z  = _312_124.y ;
		};
		i ++ ;
		if(49 < iter )
		{
			var(spec[nothing ], float3, _282_125 ) = p;
			var(spec[nothing ], float2, _284_125 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_125.xy  );
			p.x  = _284_125.x ;
			p.y  = _284_125.y ;
			var(spec[nothing ], float3, _289_125 ) = p;
			var(spec[nothing ], float2, _291_125 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_125.xz  );
			p.x  = _291_125.x ;
			p.z  = _291_125.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_125 ) = p;
			var(spec[nothing ], float2, _305_125 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_125.xy  );
			p.x  = _305_125.x ;
			p.y  = _305_125.y ;
			var(spec[nothing ], float3, _310_125 ) = p;
			var(spec[nothing ], float2, _312_125 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_125.xz  );
			p.x  = _312_125.x ;
			p.z  = _312_125.y ;
		};
		i ++ ;
		if(50 < iter )
		{
			var(spec[nothing ], float3, _282_126 ) = p;
			var(spec[nothing ], float2, _284_126 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_126.xy  );
			p.x  = _284_126.x ;
			p.y  = _284_126.y ;
			var(spec[nothing ], float3, _289_126 ) = p;
			var(spec[nothing ], float2, _291_126 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_126.xz  );
			p.x  = _291_126.x ;
			p.z  = _291_126.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_126 ) = p;
			var(spec[nothing ], float2, _305_126 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_126.xy  );
			p.x  = _305_126.x ;
			p.y  = _305_126.y ;
			var(spec[nothing ], float3, _310_126 ) = p;
			var(spec[nothing ], float2, _312_126 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_126.xz  );
			p.x  = _312_126.x ;
			p.z  = _312_126.y ;
		};
		i ++ ;
		if(51 < iter )
		{
			var(spec[nothing ], float3, _282_127 ) = p;
			var(spec[nothing ], float2, _284_127 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_127.xy  );
			p.x  = _284_127.x ;
			p.y  = _284_127.y ;
			var(spec[nothing ], float3, _289_127 ) = p;
			var(spec[nothing ], float2, _291_127 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_127.xz  );
			p.x  = _291_127.x ;
			p.z  = _291_127.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_127 ) = p;
			var(spec[nothing ], float2, _305_127 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_127.xy  );
			p.x  = _305_127.x ;
			p.y  = _305_127.y ;
			var(spec[nothing ], float3, _310_127 ) = p;
			var(spec[nothing ], float2, _312_127 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_127.xz  );
			p.x  = _312_127.x ;
			p.z  = _312_127.y ;
		};
		i ++ ;
		if(52 < iter )
		{
			var(spec[nothing ], float3, _282_128 ) = p;
			var(spec[nothing ], float2, _284_128 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_128.xy  );
			p.x  = _284_128.x ;
			p.y  = _284_128.y ;
			var(spec[nothing ], float3, _289_128 ) = p;
			var(spec[nothing ], float2, _291_128 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_128.xz  );
			p.x  = _291_128.x ;
			p.z  = _291_128.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_128 ) = p;
			var(spec[nothing ], float2, _305_128 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_128.xy  );
			p.x  = _305_128.x ;
			p.y  = _305_128.y ;
			var(spec[nothing ], float3, _310_128 ) = p;
			var(spec[nothing ], float2, _312_128 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_128.xz  );
			p.x  = _312_128.x ;
			p.z  = _312_128.y ;
		};
		i ++ ;
		if(53 < iter )
		{
			var(spec[nothing ], float3, _282_129 ) = p;
			var(spec[nothing ], float2, _284_129 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_129.xy  );
			p.x  = _284_129.x ;
			p.y  = _284_129.y ;
			var(spec[nothing ], float3, _289_129 ) = p;
			var(spec[nothing ], float2, _291_129 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_129.xz  );
			p.x  = _291_129.x ;
			p.z  = _291_129.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_129 ) = p;
			var(spec[nothing ], float2, _305_129 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_129.xy  );
			p.x  = _305_129.x ;
			p.y  = _305_129.y ;
			var(spec[nothing ], float3, _310_129 ) = p;
			var(spec[nothing ], float2, _312_129 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_129.xz  );
			p.x  = _312_129.x ;
			p.z  = _312_129.y ;
		};
		i ++ ;
		if(54 < iter )
		{
			var(spec[nothing ], float3, _282_130 ) = p;
			var(spec[nothing ], float2, _284_130 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_130.xy  );
			p.x  = _284_130.x ;
			p.y  = _284_130.y ;
			var(spec[nothing ], float3, _289_130 ) = p;
			var(spec[nothing ], float2, _291_130 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_130.xz  );
			p.x  = _291_130.x ;
			p.z  = _291_130.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_130 ) = p;
			var(spec[nothing ], float2, _305_130 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_130.xy  );
			p.x  = _305_130.x ;
			p.y  = _305_130.y ;
			var(spec[nothing ], float3, _310_130 ) = p;
			var(spec[nothing ], float2, _312_130 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_130.xz  );
			p.x  = _312_130.x ;
			p.z  = _312_130.y ;
		};
		i ++ ;
		if(55 < iter )
		{
			var(spec[nothing ], float3, _282_131 ) = p;
			var(spec[nothing ], float2, _284_131 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_131.xy  );
			p.x  = _284_131.x ;
			p.y  = _284_131.y ;
			var(spec[nothing ], float3, _289_131 ) = p;
			var(spec[nothing ], float2, _291_131 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_131.xz  );
			p.x  = _291_131.x ;
			p.z  = _291_131.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_131 ) = p;
			var(spec[nothing ], float2, _305_131 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_131.xy  );
			p.x  = _305_131.x ;
			p.y  = _305_131.y ;
			var(spec[nothing ], float3, _310_131 ) = p;
			var(spec[nothing ], float2, _312_131 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_131.xz  );
			p.x  = _312_131.x ;
			p.z  = _312_131.y ;
		};
		i ++ ;
		if(56 < iter )
		{
			var(spec[nothing ], float3, _282_132 ) = p;
			var(spec[nothing ], float2, _284_132 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_132.xy  );
			p.x  = _284_132.x ;
			p.y  = _284_132.y ;
			var(spec[nothing ], float3, _289_132 ) = p;
			var(spec[nothing ], float2, _291_132 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_132.xz  );
			p.x  = _291_132.x ;
			p.z  = _291_132.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_132 ) = p;
			var(spec[nothing ], float2, _305_132 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_132.xy  );
			p.x  = _305_132.x ;
			p.y  = _305_132.y ;
			var(spec[nothing ], float3, _310_132 ) = p;
			var(spec[nothing ], float2, _312_132 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_132.xz  );
			p.x  = _312_132.x ;
			p.z  = _312_132.y ;
		};
		i ++ ;
		if(57 < iter )
		{
			var(spec[nothing ], float3, _282_133 ) = p;
			var(spec[nothing ], float2, _284_133 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_133.xy  );
			p.x  = _284_133.x ;
			p.y  = _284_133.y ;
			var(spec[nothing ], float3, _289_133 ) = p;
			var(spec[nothing ], float2, _291_133 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_133.xz  );
			p.x  = _291_133.x ;
			p.z  = _291_133.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_133 ) = p;
			var(spec[nothing ], float2, _305_133 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_133.xy  );
			p.x  = _305_133.x ;
			p.y  = _305_133.y ;
			var(spec[nothing ], float3, _310_133 ) = p;
			var(spec[nothing ], float2, _312_133 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_133.xz  );
			p.x  = _312_133.x ;
			p.z  = _312_133.y ;
		};
		i ++ ;
		if(58 < iter )
		{
			var(spec[nothing ], float3, _282_134 ) = p;
			var(spec[nothing ], float2, _284_134 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_134.xy  );
			p.x  = _284_134.x ;
			p.y  = _284_134.y ;
			var(spec[nothing ], float3, _289_134 ) = p;
			var(spec[nothing ], float2, _291_134 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_134.xz  );
			p.x  = _291_134.x ;
			p.z  = _291_134.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_134 ) = p;
			var(spec[nothing ], float2, _305_134 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_134.xy  );
			p.x  = _305_134.x ;
			p.y  = _305_134.y ;
			var(spec[nothing ], float3, _310_134 ) = p;
			var(spec[nothing ], float2, _312_134 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_134.xz  );
			p.x  = _312_134.x ;
			p.z  = _312_134.y ;
		};
		i ++ ;
		if(59 < iter )
		{
			var(spec[nothing ], float3, _282_135 ) = p;
			var(spec[nothing ], float2, _284_135 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_135.xy  );
			p.x  = _284_135.x ;
			p.y  = _284_135.y ;
			var(spec[nothing ], float3, _289_135 ) = p;
			var(spec[nothing ], float2, _291_135 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_135.xz  );
			p.x  = _291_135.x ;
			p.z  = _291_135.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_135 ) = p;
			var(spec[nothing ], float2, _305_135 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_135.xy  );
			p.x  = _305_135.x ;
			p.y  = _305_135.y ;
			var(spec[nothing ], float3, _310_135 ) = p;
			var(spec[nothing ], float2, _312_135 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_135.xz  );
			p.x  = _312_135.x ;
			p.z  = _312_135.y ;
		};
		i ++ ;
		if(60 < iter )
		{
			var(spec[nothing ], float3, _282_136 ) = p;
			var(spec[nothing ], float2, _284_136 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_136.xy  );
			p.x  = _284_136.x ;
			p.y  = _284_136.y ;
			var(spec[nothing ], float3, _289_136 ) = p;
			var(spec[nothing ], float2, _291_136 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_136.xz  );
			p.x  = _291_136.x ;
			p.z  = _291_136.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_136 ) = p;
			var(spec[nothing ], float2, _305_136 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_136.xy  );
			p.x  = _305_136.x ;
			p.y  = _305_136.y ;
			var(spec[nothing ], float3, _310_136 ) = p;
			var(spec[nothing ], float2, _312_136 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_136.xz  );
			p.x  = _312_136.x ;
			p.z  = _312_136.y ;
		};
		i ++ ;
		if(61 < iter )
		{
			var(spec[nothing ], float3, _282_137 ) = p;
			var(spec[nothing ], float2, _284_137 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_137.xy  );
			p.x  = _284_137.x ;
			p.y  = _284_137.y ;
			var(spec[nothing ], float3, _289_137 ) = p;
			var(spec[nothing ], float2, _291_137 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_137.xz  );
			p.x  = _291_137.x ;
			p.z  = _291_137.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_137 ) = p;
			var(spec[nothing ], float2, _305_137 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_137.xy  );
			p.x  = _305_137.x ;
			p.y  = _305_137.y ;
			var(spec[nothing ], float3, _310_137 ) = p;
			var(spec[nothing ], float2, _312_137 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_137.xz  );
			p.x  = _312_137.x ;
			p.z  = _312_137.y ;
		};
		i ++ ;
		if(62 < iter )
		{
			var(spec[nothing ], float3, _282_138 ) = p;
			var(spec[nothing ], float2, _284_138 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_138.xy  );
			p.x  = _284_138.x ;
			p.y  = _284_138.y ;
			var(spec[nothing ], float3, _289_138 ) = p;
			var(spec[nothing ], float2, _291_138 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_138.xz  );
			p.x  = _291_138.x ;
			p.z  = _291_138.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_138 ) = p;
			var(spec[nothing ], float2, _305_138 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_138.xy  );
			p.x  = _305_138.x ;
			p.y  = _305_138.y ;
			var(spec[nothing ], float3, _310_138 ) = p;
			var(spec[nothing ], float2, _312_138 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_138.xz  );
			p.x  = _312_138.x ;
			p.z  = _312_138.y ;
		};
		i ++ ;
		if(63 < iter )
		{
			var(spec[nothing ], float3, _282_139 ) = p;
			var(spec[nothing ], float2, _284_139 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _282_139.xy  );
			p.x  = _284_139.x ;
			p.y  = _284_139.y ;
			var(spec[nothing ], float3, _289_139 ) = p;
			var(spec[nothing ], float2, _291_139 ) = mul(float2x2(float2(0.707106888, 0.707106709 ), float2(-0.707106709, 0.707106888 ) ), _289_139.xz  );
			p.x  = _291_139.x ;
			p.z  = _291_139.y ;
			p = abs(p ) - 1.0F.xxx ;
			var(spec[nothing ], float3, _303_139 ) = p;
			var(spec[nothing ], float2, _305_139 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _303_139.xy  );
			p.x  = _305_139.x ;
			p.y  = _305_139.y ;
			var(spec[nothing ], float3, _310_139 ) = p;
			var(spec[nothing ], float2, _312_139 ) = mul(float2x2(float2(0.707106888, -0.707106709 ), float2(0.707106709, 0.707106888 ) ), _310_139.xz  );
			p.x  = _312_139.x ;
			p.z  = _312_139.y ;
		};
	} 
	return <- p;
};
func(spec[nothing ], float, cy )
params(var(spec[inout, nothing ], float3, p ), var(spec[nothing ], float2, s ) )
{
	p.y  += (s.x  / 2.0 );
	p.y  -= clamp(p.y , 0.0, s.x  );
	return <- length(p ) - s.y ;
};
func(spec[nothing ], float, shatter )
params(var(spec[inout, nothing ], float3, p ), var(spec[inout, nothing ], float, d ), var(spec[nothing ], float, n ), var(spec[nothing ], float, a ), var(spec[nothing ], float, s ) )
{
	var(spec[nothing ], float, _234 );
	var(spec[nothing ], float, _243 );
	block
	{
		var(spec[nothing ], float, i ) = 0.0;
		if(0.0 < n )
		{
			var(spec[nothing ], float3, _171 ) = p;
			var(spec[nothing ], float2, _173 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171.xy  );
			p.x  = _173.x ;
			p.y  = _173.y ;
			var(spec[nothing ], float3, _195 ) = p;
			var(spec[nothing ], float2, _197 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195.xz  );
			p.x  = _197.x ;
			p.z  = _197.y ;
			var(spec[nothing ], float3, _222 ) = p;
			var(spec[nothing ], float2, _224 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222.yz  );
			p.y  = _224.x ;
			p.z  = _224.y ;
			if(mod(0.0, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(0.0, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c ) = _234;
			c = abs(c ) - s;
			d = max(d, - c );
		};
		i += 1.0;
		if(1.00 < n )
		{
			var(spec[nothing ], float3, _171_148 ) = p;
			var(spec[nothing ], float2, _173_148 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_148.xy  );
			p.x  = _173_148.x ;
			p.y  = _173_148.y ;
			var(spec[nothing ], float3, _195_148 ) = p;
			var(spec[nothing ], float2, _197_148 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_148.xz  );
			p.x  = _197_148.x ;
			p.z  = _197_148.y ;
			var(spec[nothing ], float3, _222_148 ) = p;
			var(spec[nothing ], float2, _224_148 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_148.yz  );
			p.y  = _224_148.x ;
			p.z  = _224_148.y ;
			if(mod(1.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(1.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_148 ) = _234;
			c_148 = abs(c_148 ) - s;
			d = max(d, - c_148 );
		};
		i += 1.0;
		if(2.00 < n )
		{
			var(spec[nothing ], float3, _171_153 ) = p;
			var(spec[nothing ], float2, _173_153 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_153.xy  );
			p.x  = _173_153.x ;
			p.y  = _173_153.y ;
			var(spec[nothing ], float3, _195_153 ) = p;
			var(spec[nothing ], float2, _197_153 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_153.xz  );
			p.x  = _197_153.x ;
			p.z  = _197_153.y ;
			var(spec[nothing ], float3, _222_153 ) = p;
			var(spec[nothing ], float2, _224_153 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_153.yz  );
			p.y  = _224_153.x ;
			p.z  = _224_153.y ;
			if(mod(2.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(2.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_153 ) = _234;
			c_153 = abs(c_153 ) - s;
			d = max(d, - c_153 );
		};
		i += 1.0;
		if(3.00 < n )
		{
			var(spec[nothing ], float3, _171_158 ) = p;
			var(spec[nothing ], float2, _173_158 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_158.xy  );
			p.x  = _173_158.x ;
			p.y  = _173_158.y ;
			var(spec[nothing ], float3, _195_158 ) = p;
			var(spec[nothing ], float2, _197_158 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_158.xz  );
			p.x  = _197_158.x ;
			p.z  = _197_158.y ;
			var(spec[nothing ], float3, _222_158 ) = p;
			var(spec[nothing ], float2, _224_158 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_158.yz  );
			p.y  = _224_158.x ;
			p.z  = _224_158.y ;
			if(mod(3.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(3.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_158 ) = _234;
			c_158 = abs(c_158 ) - s;
			d = max(d, - c_158 );
		};
		i += 1.0;
		if(4.00 < n )
		{
			var(spec[nothing ], float3, _171_163 ) = p;
			var(spec[nothing ], float2, _173_163 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_163.xy  );
			p.x  = _173_163.x ;
			p.y  = _173_163.y ;
			var(spec[nothing ], float3, _195_163 ) = p;
			var(spec[nothing ], float2, _197_163 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_163.xz  );
			p.x  = _197_163.x ;
			p.z  = _197_163.y ;
			var(spec[nothing ], float3, _222_163 ) = p;
			var(spec[nothing ], float2, _224_163 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_163.yz  );
			p.y  = _224_163.x ;
			p.z  = _224_163.y ;
			if(mod(4.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(4.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_163 ) = _234;
			c_163 = abs(c_163 ) - s;
			d = max(d, - c_163 );
		};
		i += 1.0;
		if(5.00 < n )
		{
			var(spec[nothing ], float3, _171_168 ) = p;
			var(spec[nothing ], float2, _173_168 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_168.xy  );
			p.x  = _173_168.x ;
			p.y  = _173_168.y ;
			var(spec[nothing ], float3, _195_168 ) = p;
			var(spec[nothing ], float2, _197_168 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_168.xz  );
			p.x  = _197_168.x ;
			p.z  = _197_168.y ;
			var(spec[nothing ], float3, _222_168 ) = p;
			var(spec[nothing ], float2, _224_168 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_168.yz  );
			p.y  = _224_168.x ;
			p.z  = _224_168.y ;
			if(mod(5.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(5.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_168 ) = _234;
			c_168 = abs(c_168 ) - s;
			d = max(d, - c_168 );
		};
		i += 1.0;
		if(6.00 < n )
		{
			var(spec[nothing ], float3, _171_173 ) = p;
			var(spec[nothing ], float2, _173_173 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_173.xy  );
			p.x  = _173_173.x ;
			p.y  = _173_173.y ;
			var(spec[nothing ], float3, _195_173 ) = p;
			var(spec[nothing ], float2, _197_173 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_173.xz  );
			p.x  = _197_173.x ;
			p.z  = _197_173.y ;
			var(spec[nothing ], float3, _222_173 ) = p;
			var(spec[nothing ], float2, _224_173 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_173.yz  );
			p.y  = _224_173.x ;
			p.z  = _224_173.y ;
			if(mod(6.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(6.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_173 ) = _234;
			c_173 = abs(c_173 ) - s;
			d = max(d, - c_173 );
		};
		i += 1.0;
		if(7.00 < n )
		{
			var(spec[nothing ], float3, _171_178 ) = p;
			var(spec[nothing ], float2, _173_178 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_178.xy  );
			p.x  = _173_178.x ;
			p.y  = _173_178.y ;
			var(spec[nothing ], float3, _195_178 ) = p;
			var(spec[nothing ], float2, _197_178 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_178.xz  );
			p.x  = _197_178.x ;
			p.z  = _197_178.y ;
			var(spec[nothing ], float3, _222_178 ) = p;
			var(spec[nothing ], float2, _224_178 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_178.yz  );
			p.y  = _224_178.x ;
			p.z  = _224_178.y ;
			if(mod(7.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(7.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_178 ) = _234;
			c_178 = abs(c_178 ) - s;
			d = max(d, - c_178 );
		};
		i += 1.0;
		if(8.00 < n )
		{
			var(spec[nothing ], float3, _171_183 ) = p;
			var(spec[nothing ], float2, _173_183 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_183.xy  );
			p.x  = _173_183.x ;
			p.y  = _173_183.y ;
			var(spec[nothing ], float3, _195_183 ) = p;
			var(spec[nothing ], float2, _197_183 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_183.xz  );
			p.x  = _197_183.x ;
			p.z  = _197_183.y ;
			var(spec[nothing ], float3, _222_183 ) = p;
			var(spec[nothing ], float2, _224_183 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_183.yz  );
			p.y  = _224_183.x ;
			p.z  = _224_183.y ;
			if(mod(8.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(8.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_183 ) = _234;
			c_183 = abs(c_183 ) - s;
			d = max(d, - c_183 );
		};
		i += 1.0;
		if(9.00 < n )
		{
			var(spec[nothing ], float3, _171_188 ) = p;
			var(spec[nothing ], float2, _173_188 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_188.xy  );
			p.x  = _173_188.x ;
			p.y  = _173_188.y ;
			var(spec[nothing ], float3, _195_188 ) = p;
			var(spec[nothing ], float2, _197_188 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_188.xz  );
			p.x  = _197_188.x ;
			p.z  = _197_188.y ;
			var(spec[nothing ], float3, _222_188 ) = p;
			var(spec[nothing ], float2, _224_188 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_188.yz  );
			p.y  = _224_188.x ;
			p.z  = _224_188.y ;
			if(mod(9.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(9.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_188 ) = _234;
			c_188 = abs(c_188 ) - s;
			d = max(d, - c_188 );
		};
		i += 1.0;
		if(10.00 < n )
		{
			var(spec[nothing ], float3, _171_193 ) = p;
			var(spec[nothing ], float2, _173_193 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_193.xy  );
			p.x  = _173_193.x ;
			p.y  = _173_193.y ;
			var(spec[nothing ], float3, _195_193 ) = p;
			var(spec[nothing ], float2, _197_193 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_193.xz  );
			p.x  = _197_193.x ;
			p.z  = _197_193.y ;
			var(spec[nothing ], float3, _222_193 ) = p;
			var(spec[nothing ], float2, _224_193 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_193.yz  );
			p.y  = _224_193.x ;
			p.z  = _224_193.y ;
			if(mod(10.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(10.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_193 ) = _234;
			c_193 = abs(c_193 ) - s;
			d = max(d, - c_193 );
		};
		i += 1.0;
		if(11.00 < n )
		{
			var(spec[nothing ], float3, _171_198 ) = p;
			var(spec[nothing ], float2, _173_198 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_198.xy  );
			p.x  = _173_198.x ;
			p.y  = _173_198.y ;
			var(spec[nothing ], float3, _195_198 ) = p;
			var(spec[nothing ], float2, _197_198 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_198.xz  );
			p.x  = _197_198.x ;
			p.z  = _197_198.y ;
			var(spec[nothing ], float3, _222_198 ) = p;
			var(spec[nothing ], float2, _224_198 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_198.yz  );
			p.y  = _224_198.x ;
			p.z  = _224_198.y ;
			if(mod(11.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(11.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_198 ) = _234;
			c_198 = abs(c_198 ) - s;
			d = max(d, - c_198 );
		};
		i += 1.0;
		if(12.00 < n )
		{
			var(spec[nothing ], float3, _171_203 ) = p;
			var(spec[nothing ], float2, _173_203 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_203.xy  );
			p.x  = _173_203.x ;
			p.y  = _173_203.y ;
			var(spec[nothing ], float3, _195_203 ) = p;
			var(spec[nothing ], float2, _197_203 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_203.xz  );
			p.x  = _197_203.x ;
			p.z  = _197_203.y ;
			var(spec[nothing ], float3, _222_203 ) = p;
			var(spec[nothing ], float2, _224_203 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_203.yz  );
			p.y  = _224_203.x ;
			p.z  = _224_203.y ;
			if(mod(12.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(12.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_203 ) = _234;
			c_203 = abs(c_203 ) - s;
			d = max(d, - c_203 );
		};
		i += 1.0;
		if(13.00 < n )
		{
			var(spec[nothing ], float3, _171_208 ) = p;
			var(spec[nothing ], float2, _173_208 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_208.xy  );
			p.x  = _173_208.x ;
			p.y  = _173_208.y ;
			var(spec[nothing ], float3, _195_208 ) = p;
			var(spec[nothing ], float2, _197_208 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_208.xz  );
			p.x  = _197_208.x ;
			p.z  = _197_208.y ;
			var(spec[nothing ], float3, _222_208 ) = p;
			var(spec[nothing ], float2, _224_208 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_208.yz  );
			p.y  = _224_208.x ;
			p.z  = _224_208.y ;
			if(mod(13.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(13.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_208 ) = _234;
			c_208 = abs(c_208 ) - s;
			d = max(d, - c_208 );
		};
		i += 1.0;
		if(14.00 < n )
		{
			var(spec[nothing ], float3, _171_213 ) = p;
			var(spec[nothing ], float2, _173_213 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_213.xy  );
			p.x  = _173_213.x ;
			p.y  = _173_213.y ;
			var(spec[nothing ], float3, _195_213 ) = p;
			var(spec[nothing ], float2, _197_213 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_213.xz  );
			p.x  = _197_213.x ;
			p.z  = _197_213.y ;
			var(spec[nothing ], float3, _222_213 ) = p;
			var(spec[nothing ], float2, _224_213 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_213.yz  );
			p.y  = _224_213.x ;
			p.z  = _224_213.y ;
			if(mod(14.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(14.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_213 ) = _234;
			c_213 = abs(c_213 ) - s;
			d = max(d, - c_213 );
		};
		i += 1.0;
		if(15.00 < n )
		{
			var(spec[nothing ], float3, _171_218 ) = p;
			var(spec[nothing ], float2, _173_218 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_218.xy  );
			p.x  = _173_218.x ;
			p.y  = _173_218.y ;
			var(spec[nothing ], float3, _195_218 ) = p;
			var(spec[nothing ], float2, _197_218 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_218.xz  );
			p.x  = _197_218.x ;
			p.z  = _197_218.y ;
			var(spec[nothing ], float3, _222_218 ) = p;
			var(spec[nothing ], float2, _224_218 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_218.yz  );
			p.y  = _224_218.x ;
			p.z  = _224_218.y ;
			if(mod(15.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(15.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_218 ) = _234;
			c_218 = abs(c_218 ) - s;
			d = max(d, - c_218 );
		};
		i += 1.0;
		if(16.00 < n )
		{
			var(spec[nothing ], float3, _171_223 ) = p;
			var(spec[nothing ], float2, _173_223 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_223.xy  );
			p.x  = _173_223.x ;
			p.y  = _173_223.y ;
			var(spec[nothing ], float3, _195_223 ) = p;
			var(spec[nothing ], float2, _197_223 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_223.xz  );
			p.x  = _197_223.x ;
			p.z  = _197_223.y ;
			var(spec[nothing ], float3, _222_223 ) = p;
			var(spec[nothing ], float2, _224_223 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_223.yz  );
			p.y  = _224_223.x ;
			p.z  = _224_223.y ;
			if(mod(16.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(16.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_223 ) = _234;
			c_223 = abs(c_223 ) - s;
			d = max(d, - c_223 );
		};
		i += 1.0;
		if(17.00 < n )
		{
			var(spec[nothing ], float3, _171_228 ) = p;
			var(spec[nothing ], float2, _173_228 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_228.xy  );
			p.x  = _173_228.x ;
			p.y  = _173_228.y ;
			var(spec[nothing ], float3, _195_228 ) = p;
			var(spec[nothing ], float2, _197_228 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_228.xz  );
			p.x  = _197_228.x ;
			p.z  = _197_228.y ;
			var(spec[nothing ], float3, _222_228 ) = p;
			var(spec[nothing ], float2, _224_228 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_228.yz  );
			p.y  = _224_228.x ;
			p.z  = _224_228.y ;
			if(mod(17.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(17.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_228 ) = _234;
			c_228 = abs(c_228 ) - s;
			d = max(d, - c_228 );
		};
		i += 1.0;
		if(18.00 < n )
		{
			var(spec[nothing ], float3, _171_233 ) = p;
			var(spec[nothing ], float2, _173_233 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_233.xy  );
			p.x  = _173_233.x ;
			p.y  = _173_233.y ;
			var(spec[nothing ], float3, _195_233 ) = p;
			var(spec[nothing ], float2, _197_233 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_233.xz  );
			p.x  = _197_233.x ;
			p.z  = _197_233.y ;
			var(spec[nothing ], float3, _222_233 ) = p;
			var(spec[nothing ], float2, _224_233 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_233.yz  );
			p.y  = _224_233.x ;
			p.z  = _224_233.y ;
			if(mod(18.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(18.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_233 ) = _234;
			c_233 = abs(c_233 ) - s;
			d = max(d, - c_233 );
		};
		i += 1.0;
		if(19.00 < n )
		{
			var(spec[nothing ], float3, _171_238 ) = p;
			var(spec[nothing ], float2, _173_238 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_238.xy  );
			p.x  = _173_238.x ;
			p.y  = _173_238.y ;
			var(spec[nothing ], float3, _195_238 ) = p;
			var(spec[nothing ], float2, _197_238 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_238.xz  );
			p.x  = _197_238.x ;
			p.z  = _197_238.y ;
			var(spec[nothing ], float3, _222_238 ) = p;
			var(spec[nothing ], float2, _224_238 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_238.yz  );
			p.y  = _224_238.x ;
			p.z  = _224_238.y ;
			if(mod(19.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(19.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_238 ) = _234;
			c_238 = abs(c_238 ) - s;
			d = max(d, - c_238 );
		};
		i += 1.0;
		if(20.00 < n )
		{
			var(spec[nothing ], float3, _171_243 ) = p;
			var(spec[nothing ], float2, _173_243 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_243.xy  );
			p.x  = _173_243.x ;
			p.y  = _173_243.y ;
			var(spec[nothing ], float3, _195_243 ) = p;
			var(spec[nothing ], float2, _197_243 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_243.xz  );
			p.x  = _197_243.x ;
			p.z  = _197_243.y ;
			var(spec[nothing ], float3, _222_243 ) = p;
			var(spec[nothing ], float2, _224_243 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_243.yz  );
			p.y  = _224_243.x ;
			p.z  = _224_243.y ;
			if(mod(20.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(20.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_243 ) = _234;
			c_243 = abs(c_243 ) - s;
			d = max(d, - c_243 );
		};
		i += 1.0;
		if(21.00 < n )
		{
			var(spec[nothing ], float3, _171_248 ) = p;
			var(spec[nothing ], float2, _173_248 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_248.xy  );
			p.x  = _173_248.x ;
			p.y  = _173_248.y ;
			var(spec[nothing ], float3, _195_248 ) = p;
			var(spec[nothing ], float2, _197_248 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_248.xz  );
			p.x  = _197_248.x ;
			p.z  = _197_248.y ;
			var(spec[nothing ], float3, _222_248 ) = p;
			var(spec[nothing ], float2, _224_248 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_248.yz  );
			p.y  = _224_248.x ;
			p.z  = _224_248.y ;
			if(mod(21.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(21.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_248 ) = _234;
			c_248 = abs(c_248 ) - s;
			d = max(d, - c_248 );
		};
		i += 1.0;
		if(22.00 < n )
		{
			var(spec[nothing ], float3, _171_253 ) = p;
			var(spec[nothing ], float2, _173_253 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_253.xy  );
			p.x  = _173_253.x ;
			p.y  = _173_253.y ;
			var(spec[nothing ], float3, _195_253 ) = p;
			var(spec[nothing ], float2, _197_253 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_253.xz  );
			p.x  = _197_253.x ;
			p.z  = _197_253.y ;
			var(spec[nothing ], float3, _222_253 ) = p;
			var(spec[nothing ], float2, _224_253 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_253.yz  );
			p.y  = _224_253.x ;
			p.z  = _224_253.y ;
			if(mod(22.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(22.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_253 ) = _234;
			c_253 = abs(c_253 ) - s;
			d = max(d, - c_253 );
		};
		i += 1.0;
		if(23.00 < n )
		{
			var(spec[nothing ], float3, _171_258 ) = p;
			var(spec[nothing ], float2, _173_258 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_258.xy  );
			p.x  = _173_258.x ;
			p.y  = _173_258.y ;
			var(spec[nothing ], float3, _195_258 ) = p;
			var(spec[nothing ], float2, _197_258 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_258.xz  );
			p.x  = _197_258.x ;
			p.z  = _197_258.y ;
			var(spec[nothing ], float3, _222_258 ) = p;
			var(spec[nothing ], float2, _224_258 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_258.yz  );
			p.y  = _224_258.x ;
			p.z  = _224_258.y ;
			if(mod(23.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(23.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_258 ) = _234;
			c_258 = abs(c_258 ) - s;
			d = max(d, - c_258 );
		};
		i += 1.0;
		if(24.00 < n )
		{
			var(spec[nothing ], float3, _171_263 ) = p;
			var(spec[nothing ], float2, _173_263 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_263.xy  );
			p.x  = _173_263.x ;
			p.y  = _173_263.y ;
			var(spec[nothing ], float3, _195_263 ) = p;
			var(spec[nothing ], float2, _197_263 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_263.xz  );
			p.x  = _197_263.x ;
			p.z  = _197_263.y ;
			var(spec[nothing ], float3, _222_263 ) = p;
			var(spec[nothing ], float2, _224_263 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_263.yz  );
			p.y  = _224_263.x ;
			p.z  = _224_263.y ;
			if(mod(24.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(24.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_263 ) = _234;
			c_263 = abs(c_263 ) - s;
			d = max(d, - c_263 );
		};
		i += 1.0;
		if(25.00 < n )
		{
			var(spec[nothing ], float3, _171_268 ) = p;
			var(spec[nothing ], float2, _173_268 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_268.xy  );
			p.x  = _173_268.x ;
			p.y  = _173_268.y ;
			var(spec[nothing ], float3, _195_268 ) = p;
			var(spec[nothing ], float2, _197_268 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_268.xz  );
			p.x  = _197_268.x ;
			p.z  = _197_268.y ;
			var(spec[nothing ], float3, _222_268 ) = p;
			var(spec[nothing ], float2, _224_268 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_268.yz  );
			p.y  = _224_268.x ;
			p.z  = _224_268.y ;
			if(mod(25.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(25.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_268 ) = _234;
			c_268 = abs(c_268 ) - s;
			d = max(d, - c_268 );
		};
		i += 1.0;
		if(26.00 < n )
		{
			var(spec[nothing ], float3, _171_273 ) = p;
			var(spec[nothing ], float2, _173_273 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_273.xy  );
			p.x  = _173_273.x ;
			p.y  = _173_273.y ;
			var(spec[nothing ], float3, _195_273 ) = p;
			var(spec[nothing ], float2, _197_273 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_273.xz  );
			p.x  = _197_273.x ;
			p.z  = _197_273.y ;
			var(spec[nothing ], float3, _222_273 ) = p;
			var(spec[nothing ], float2, _224_273 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_273.yz  );
			p.y  = _224_273.x ;
			p.z  = _224_273.y ;
			if(mod(26.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(26.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_273 ) = _234;
			c_273 = abs(c_273 ) - s;
			d = max(d, - c_273 );
		};
		i += 1.0;
		if(27.00 < n )
		{
			var(spec[nothing ], float3, _171_278 ) = p;
			var(spec[nothing ], float2, _173_278 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_278.xy  );
			p.x  = _173_278.x ;
			p.y  = _173_278.y ;
			var(spec[nothing ], float3, _195_278 ) = p;
			var(spec[nothing ], float2, _197_278 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_278.xz  );
			p.x  = _197_278.x ;
			p.z  = _197_278.y ;
			var(spec[nothing ], float3, _222_278 ) = p;
			var(spec[nothing ], float2, _224_278 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_278.yz  );
			p.y  = _224_278.x ;
			p.z  = _224_278.y ;
			if(mod(27.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(27.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_278 ) = _234;
			c_278 = abs(c_278 ) - s;
			d = max(d, - c_278 );
		};
		i += 1.0;
		if(28.00 < n )
		{
			var(spec[nothing ], float3, _171_283 ) = p;
			var(spec[nothing ], float2, _173_283 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_283.xy  );
			p.x  = _173_283.x ;
			p.y  = _173_283.y ;
			var(spec[nothing ], float3, _195_283 ) = p;
			var(spec[nothing ], float2, _197_283 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_283.xz  );
			p.x  = _197_283.x ;
			p.z  = _197_283.y ;
			var(spec[nothing ], float3, _222_283 ) = p;
			var(spec[nothing ], float2, _224_283 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_283.yz  );
			p.y  = _224_283.x ;
			p.z  = _224_283.y ;
			if(mod(28.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(28.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_283 ) = _234;
			c_283 = abs(c_283 ) - s;
			d = max(d, - c_283 );
		};
		i += 1.0;
		if(29.00 < n )
		{
			var(spec[nothing ], float3, _171_288 ) = p;
			var(spec[nothing ], float2, _173_288 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_288.xy  );
			p.x  = _173_288.x ;
			p.y  = _173_288.y ;
			var(spec[nothing ], float3, _195_288 ) = p;
			var(spec[nothing ], float2, _197_288 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_288.xz  );
			p.x  = _197_288.x ;
			p.z  = _197_288.y ;
			var(spec[nothing ], float3, _222_288 ) = p;
			var(spec[nothing ], float2, _224_288 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_288.yz  );
			p.y  = _224_288.x ;
			p.z  = _224_288.y ;
			if(mod(29.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(29.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_288 ) = _234;
			c_288 = abs(c_288 ) - s;
			d = max(d, - c_288 );
		};
		i += 1.0;
		if(30.00 < n )
		{
			var(spec[nothing ], float3, _171_293 ) = p;
			var(spec[nothing ], float2, _173_293 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_293.xy  );
			p.x  = _173_293.x ;
			p.y  = _173_293.y ;
			var(spec[nothing ], float3, _195_293 ) = p;
			var(spec[nothing ], float2, _197_293 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_293.xz  );
			p.x  = _197_293.x ;
			p.z  = _197_293.y ;
			var(spec[nothing ], float3, _222_293 ) = p;
			var(spec[nothing ], float2, _224_293 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_293.yz  );
			p.y  = _224_293.x ;
			p.z  = _224_293.y ;
			if(mod(30.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(30.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_293 ) = _234;
			c_293 = abs(c_293 ) - s;
			d = max(d, - c_293 );
		};
		i += 1.0;
		if(31.00 < n )
		{
			var(spec[nothing ], float3, _171_298 ) = p;
			var(spec[nothing ], float2, _173_298 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_298.xy  );
			p.x  = _173_298.x ;
			p.y  = _173_298.y ;
			var(spec[nothing ], float3, _195_298 ) = p;
			var(spec[nothing ], float2, _197_298 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_298.xz  );
			p.x  = _197_298.x ;
			p.z  = _197_298.y ;
			var(spec[nothing ], float3, _222_298 ) = p;
			var(spec[nothing ], float2, _224_298 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_298.yz  );
			p.y  = _224_298.x ;
			p.z  = _224_298.y ;
			if(mod(31.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(31.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_298 ) = _234;
			c_298 = abs(c_298 ) - s;
			d = max(d, - c_298 );
		};
		i += 1.0;
		if(32.00 < n )
		{
			var(spec[nothing ], float3, _171_303 ) = p;
			var(spec[nothing ], float2, _173_303 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_303.xy  );
			p.x  = _173_303.x ;
			p.y  = _173_303.y ;
			var(spec[nothing ], float3, _195_303 ) = p;
			var(spec[nothing ], float2, _197_303 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_303.xz  );
			p.x  = _197_303.x ;
			p.z  = _197_303.y ;
			var(spec[nothing ], float3, _222_303 ) = p;
			var(spec[nothing ], float2, _224_303 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_303.yz  );
			p.y  = _224_303.x ;
			p.z  = _224_303.y ;
			if(mod(32.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(32.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_303 ) = _234;
			c_303 = abs(c_303 ) - s;
			d = max(d, - c_303 );
		};
		i += 1.0;
		if(33.00 < n )
		{
			var(spec[nothing ], float3, _171_308 ) = p;
			var(spec[nothing ], float2, _173_308 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_308.xy  );
			p.x  = _173_308.x ;
			p.y  = _173_308.y ;
			var(spec[nothing ], float3, _195_308 ) = p;
			var(spec[nothing ], float2, _197_308 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_308.xz  );
			p.x  = _197_308.x ;
			p.z  = _197_308.y ;
			var(spec[nothing ], float3, _222_308 ) = p;
			var(spec[nothing ], float2, _224_308 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_308.yz  );
			p.y  = _224_308.x ;
			p.z  = _224_308.y ;
			if(mod(33.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(33.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_308 ) = _234;
			c_308 = abs(c_308 ) - s;
			d = max(d, - c_308 );
		};
		i += 1.0;
		if(34.00 < n )
		{
			var(spec[nothing ], float3, _171_313 ) = p;
			var(spec[nothing ], float2, _173_313 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_313.xy  );
			p.x  = _173_313.x ;
			p.y  = _173_313.y ;
			var(spec[nothing ], float3, _195_313 ) = p;
			var(spec[nothing ], float2, _197_313 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_313.xz  );
			p.x  = _197_313.x ;
			p.z  = _197_313.y ;
			var(spec[nothing ], float3, _222_313 ) = p;
			var(spec[nothing ], float2, _224_313 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_313.yz  );
			p.y  = _224_313.x ;
			p.z  = _224_313.y ;
			if(mod(34.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(34.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_313 ) = _234;
			c_313 = abs(c_313 ) - s;
			d = max(d, - c_313 );
		};
		i += 1.0;
		if(35.00 < n )
		{
			var(spec[nothing ], float3, _171_318 ) = p;
			var(spec[nothing ], float2, _173_318 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_318.xy  );
			p.x  = _173_318.x ;
			p.y  = _173_318.y ;
			var(spec[nothing ], float3, _195_318 ) = p;
			var(spec[nothing ], float2, _197_318 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_318.xz  );
			p.x  = _197_318.x ;
			p.z  = _197_318.y ;
			var(spec[nothing ], float3, _222_318 ) = p;
			var(spec[nothing ], float2, _224_318 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_318.yz  );
			p.y  = _224_318.x ;
			p.z  = _224_318.y ;
			if(mod(35.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(35.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_318 ) = _234;
			c_318 = abs(c_318 ) - s;
			d = max(d, - c_318 );
		};
		i += 1.0;
		if(36.00 < n )
		{
			var(spec[nothing ], float3, _171_323 ) = p;
			var(spec[nothing ], float2, _173_323 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_323.xy  );
			p.x  = _173_323.x ;
			p.y  = _173_323.y ;
			var(spec[nothing ], float3, _195_323 ) = p;
			var(spec[nothing ], float2, _197_323 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_323.xz  );
			p.x  = _197_323.x ;
			p.z  = _197_323.y ;
			var(spec[nothing ], float3, _222_323 ) = p;
			var(spec[nothing ], float2, _224_323 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_323.yz  );
			p.y  = _224_323.x ;
			p.z  = _224_323.y ;
			if(mod(36.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(36.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_323 ) = _234;
			c_323 = abs(c_323 ) - s;
			d = max(d, - c_323 );
		};
		i += 1.0;
		if(37.00 < n )
		{
			var(spec[nothing ], float3, _171_328 ) = p;
			var(spec[nothing ], float2, _173_328 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_328.xy  );
			p.x  = _173_328.x ;
			p.y  = _173_328.y ;
			var(spec[nothing ], float3, _195_328 ) = p;
			var(spec[nothing ], float2, _197_328 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_328.xz  );
			p.x  = _197_328.x ;
			p.z  = _197_328.y ;
			var(spec[nothing ], float3, _222_328 ) = p;
			var(spec[nothing ], float2, _224_328 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_328.yz  );
			p.y  = _224_328.x ;
			p.z  = _224_328.y ;
			if(mod(37.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(37.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_328 ) = _234;
			c_328 = abs(c_328 ) - s;
			d = max(d, - c_328 );
		};
		i += 1.0;
		if(38.00 < n )
		{
			var(spec[nothing ], float3, _171_333 ) = p;
			var(spec[nothing ], float2, _173_333 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_333.xy  );
			p.x  = _173_333.x ;
			p.y  = _173_333.y ;
			var(spec[nothing ], float3, _195_333 ) = p;
			var(spec[nothing ], float2, _197_333 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_333.xz  );
			p.x  = _197_333.x ;
			p.z  = _197_333.y ;
			var(spec[nothing ], float3, _222_333 ) = p;
			var(spec[nothing ], float2, _224_333 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_333.yz  );
			p.y  = _224_333.x ;
			p.z  = _224_333.y ;
			if(mod(38.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(38.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_333 ) = _234;
			c_333 = abs(c_333 ) - s;
			d = max(d, - c_333 );
		};
		i += 1.0;
		if(39.00 < n )
		{
			var(spec[nothing ], float3, _171_338 ) = p;
			var(spec[nothing ], float2, _173_338 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_338.xy  );
			p.x  = _173_338.x ;
			p.y  = _173_338.y ;
			var(spec[nothing ], float3, _195_338 ) = p;
			var(spec[nothing ], float2, _197_338 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_338.xz  );
			p.x  = _197_338.x ;
			p.z  = _197_338.y ;
			var(spec[nothing ], float3, _222_338 ) = p;
			var(spec[nothing ], float2, _224_338 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_338.yz  );
			p.y  = _224_338.x ;
			p.z  = _224_338.y ;
			if(mod(39.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(39.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_338 ) = _234;
			c_338 = abs(c_338 ) - s;
			d = max(d, - c_338 );
		};
		i += 1.0;
		if(40.00 < n )
		{
			var(spec[nothing ], float3, _171_343 ) = p;
			var(spec[nothing ], float2, _173_343 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_343.xy  );
			p.x  = _173_343.x ;
			p.y  = _173_343.y ;
			var(spec[nothing ], float3, _195_343 ) = p;
			var(spec[nothing ], float2, _197_343 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_343.xz  );
			p.x  = _197_343.x ;
			p.z  = _197_343.y ;
			var(spec[nothing ], float3, _222_343 ) = p;
			var(spec[nothing ], float2, _224_343 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_343.yz  );
			p.y  = _224_343.x ;
			p.z  = _224_343.y ;
			if(mod(40.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(40.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_343 ) = _234;
			c_343 = abs(c_343 ) - s;
			d = max(d, - c_343 );
		};
		i += 1.0;
		if(41.00 < n )
		{
			var(spec[nothing ], float3, _171_348 ) = p;
			var(spec[nothing ], float2, _173_348 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_348.xy  );
			p.x  = _173_348.x ;
			p.y  = _173_348.y ;
			var(spec[nothing ], float3, _195_348 ) = p;
			var(spec[nothing ], float2, _197_348 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_348.xz  );
			p.x  = _197_348.x ;
			p.z  = _197_348.y ;
			var(spec[nothing ], float3, _222_348 ) = p;
			var(spec[nothing ], float2, _224_348 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_348.yz  );
			p.y  = _224_348.x ;
			p.z  = _224_348.y ;
			if(mod(41.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(41.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_348 ) = _234;
			c_348 = abs(c_348 ) - s;
			d = max(d, - c_348 );
		};
		i += 1.0;
		if(42.00 < n )
		{
			var(spec[nothing ], float3, _171_353 ) = p;
			var(spec[nothing ], float2, _173_353 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_353.xy  );
			p.x  = _173_353.x ;
			p.y  = _173_353.y ;
			var(spec[nothing ], float3, _195_353 ) = p;
			var(spec[nothing ], float2, _197_353 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_353.xz  );
			p.x  = _197_353.x ;
			p.z  = _197_353.y ;
			var(spec[nothing ], float3, _222_353 ) = p;
			var(spec[nothing ], float2, _224_353 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_353.yz  );
			p.y  = _224_353.x ;
			p.z  = _224_353.y ;
			if(mod(42.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(42.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_353 ) = _234;
			c_353 = abs(c_353 ) - s;
			d = max(d, - c_353 );
		};
		i += 1.0;
		if(43.00 < n )
		{
			var(spec[nothing ], float3, _171_358 ) = p;
			var(spec[nothing ], float2, _173_358 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_358.xy  );
			p.x  = _173_358.x ;
			p.y  = _173_358.y ;
			var(spec[nothing ], float3, _195_358 ) = p;
			var(spec[nothing ], float2, _197_358 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_358.xz  );
			p.x  = _197_358.x ;
			p.z  = _197_358.y ;
			var(spec[nothing ], float3, _222_358 ) = p;
			var(spec[nothing ], float2, _224_358 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_358.yz  );
			p.y  = _224_358.x ;
			p.z  = _224_358.y ;
			if(mod(43.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(43.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_358 ) = _234;
			c_358 = abs(c_358 ) - s;
			d = max(d, - c_358 );
		};
		i += 1.0;
		if(44.00 < n )
		{
			var(spec[nothing ], float3, _171_363 ) = p;
			var(spec[nothing ], float2, _173_363 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_363.xy  );
			p.x  = _173_363.x ;
			p.y  = _173_363.y ;
			var(spec[nothing ], float3, _195_363 ) = p;
			var(spec[nothing ], float2, _197_363 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_363.xz  );
			p.x  = _197_363.x ;
			p.z  = _197_363.y ;
			var(spec[nothing ], float3, _222_363 ) = p;
			var(spec[nothing ], float2, _224_363 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_363.yz  );
			p.y  = _224_363.x ;
			p.z  = _224_363.y ;
			if(mod(44.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(44.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_363 ) = _234;
			c_363 = abs(c_363 ) - s;
			d = max(d, - c_363 );
		};
		i += 1.0;
		if(45.00 < n )
		{
			var(spec[nothing ], float3, _171_368 ) = p;
			var(spec[nothing ], float2, _173_368 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_368.xy  );
			p.x  = _173_368.x ;
			p.y  = _173_368.y ;
			var(spec[nothing ], float3, _195_368 ) = p;
			var(spec[nothing ], float2, _197_368 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_368.xz  );
			p.x  = _197_368.x ;
			p.z  = _197_368.y ;
			var(spec[nothing ], float3, _222_368 ) = p;
			var(spec[nothing ], float2, _224_368 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_368.yz  );
			p.y  = _224_368.x ;
			p.z  = _224_368.y ;
			if(mod(45.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(45.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_368 ) = _234;
			c_368 = abs(c_368 ) - s;
			d = max(d, - c_368 );
		};
		i += 1.0;
		if(46.00 < n )
		{
			var(spec[nothing ], float3, _171_373 ) = p;
			var(spec[nothing ], float2, _173_373 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_373.xy  );
			p.x  = _173_373.x ;
			p.y  = _173_373.y ;
			var(spec[nothing ], float3, _195_373 ) = p;
			var(spec[nothing ], float2, _197_373 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_373.xz  );
			p.x  = _197_373.x ;
			p.z  = _197_373.y ;
			var(spec[nothing ], float3, _222_373 ) = p;
			var(spec[nothing ], float2, _224_373 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_373.yz  );
			p.y  = _224_373.x ;
			p.z  = _224_373.y ;
			if(mod(46.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(46.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_373 ) = _234;
			c_373 = abs(c_373 ) - s;
			d = max(d, - c_373 );
		};
		i += 1.0;
		if(47.00 < n )
		{
			var(spec[nothing ], float3, _171_378 ) = p;
			var(spec[nothing ], float2, _173_378 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_378.xy  );
			p.x  = _173_378.x ;
			p.y  = _173_378.y ;
			var(spec[nothing ], float3, _195_378 ) = p;
			var(spec[nothing ], float2, _197_378 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_378.xz  );
			p.x  = _197_378.x ;
			p.z  = _197_378.y ;
			var(spec[nothing ], float3, _222_378 ) = p;
			var(spec[nothing ], float2, _224_378 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_378.yz  );
			p.y  = _224_378.x ;
			p.z  = _224_378.y ;
			if(mod(47.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(47.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_378 ) = _234;
			c_378 = abs(c_378 ) - s;
			d = max(d, - c_378 );
		};
		i += 1.0;
		if(48.00 < n )
		{
			var(spec[nothing ], float3, _171_383 ) = p;
			var(spec[nothing ], float2, _173_383 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_383.xy  );
			p.x  = _173_383.x ;
			p.y  = _173_383.y ;
			var(spec[nothing ], float3, _195_383 ) = p;
			var(spec[nothing ], float2, _197_383 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_383.xz  );
			p.x  = _197_383.x ;
			p.z  = _197_383.y ;
			var(spec[nothing ], float3, _222_383 ) = p;
			var(spec[nothing ], float2, _224_383 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_383.yz  );
			p.y  = _224_383.x ;
			p.z  = _224_383.y ;
			if(mod(48.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(48.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_383 ) = _234;
			c_383 = abs(c_383 ) - s;
			d = max(d, - c_383 );
		};
		i += 1.0;
		if(49.00 < n )
		{
			var(spec[nothing ], float3, _171_388 ) = p;
			var(spec[nothing ], float2, _173_388 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_388.xy  );
			p.x  = _173_388.x ;
			p.y  = _173_388.y ;
			var(spec[nothing ], float3, _195_388 ) = p;
			var(spec[nothing ], float2, _197_388 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_388.xz  );
			p.x  = _197_388.x ;
			p.z  = _197_388.y ;
			var(spec[nothing ], float3, _222_388 ) = p;
			var(spec[nothing ], float2, _224_388 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_388.yz  );
			p.y  = _224_388.x ;
			p.z  = _224_388.y ;
			if(mod(49.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(49.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_388 ) = _234;
			c_388 = abs(c_388 ) - s;
			d = max(d, - c_388 );
		};
		i += 1.0;
		if(50.00 < n )
		{
			var(spec[nothing ], float3, _171_393 ) = p;
			var(spec[nothing ], float2, _173_393 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_393.xy  );
			p.x  = _173_393.x ;
			p.y  = _173_393.y ;
			var(spec[nothing ], float3, _195_393 ) = p;
			var(spec[nothing ], float2, _197_393 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_393.xz  );
			p.x  = _197_393.x ;
			p.z  = _197_393.y ;
			var(spec[nothing ], float3, _222_393 ) = p;
			var(spec[nothing ], float2, _224_393 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_393.yz  );
			p.y  = _224_393.x ;
			p.z  = _224_393.y ;
			if(mod(50.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(50.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_393 ) = _234;
			c_393 = abs(c_393 ) - s;
			d = max(d, - c_393 );
		};
		i += 1.0;
		if(51.00 < n )
		{
			var(spec[nothing ], float3, _171_398 ) = p;
			var(spec[nothing ], float2, _173_398 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_398.xy  );
			p.x  = _173_398.x ;
			p.y  = _173_398.y ;
			var(spec[nothing ], float3, _195_398 ) = p;
			var(spec[nothing ], float2, _197_398 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_398.xz  );
			p.x  = _197_398.x ;
			p.z  = _197_398.y ;
			var(spec[nothing ], float3, _222_398 ) = p;
			var(spec[nothing ], float2, _224_398 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_398.yz  );
			p.y  = _224_398.x ;
			p.z  = _224_398.y ;
			if(mod(51.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(51.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_398 ) = _234;
			c_398 = abs(c_398 ) - s;
			d = max(d, - c_398 );
		};
		i += 1.0;
		if(52.00 < n )
		{
			var(spec[nothing ], float3, _171_403 ) = p;
			var(spec[nothing ], float2, _173_403 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_403.xy  );
			p.x  = _173_403.x ;
			p.y  = _173_403.y ;
			var(spec[nothing ], float3, _195_403 ) = p;
			var(spec[nothing ], float2, _197_403 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_403.xz  );
			p.x  = _197_403.x ;
			p.z  = _197_403.y ;
			var(spec[nothing ], float3, _222_403 ) = p;
			var(spec[nothing ], float2, _224_403 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_403.yz  );
			p.y  = _224_403.x ;
			p.z  = _224_403.y ;
			if(mod(52.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(52.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_403 ) = _234;
			c_403 = abs(c_403 ) - s;
			d = max(d, - c_403 );
		};
		i += 1.0;
		if(53.00 < n )
		{
			var(spec[nothing ], float3, _171_408 ) = p;
			var(spec[nothing ], float2, _173_408 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_408.xy  );
			p.x  = _173_408.x ;
			p.y  = _173_408.y ;
			var(spec[nothing ], float3, _195_408 ) = p;
			var(spec[nothing ], float2, _197_408 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_408.xz  );
			p.x  = _197_408.x ;
			p.z  = _197_408.y ;
			var(spec[nothing ], float3, _222_408 ) = p;
			var(spec[nothing ], float2, _224_408 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_408.yz  );
			p.y  = _224_408.x ;
			p.z  = _224_408.y ;
			if(mod(53.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(53.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_408 ) = _234;
			c_408 = abs(c_408 ) - s;
			d = max(d, - c_408 );
		};
		i += 1.0;
		if(54.00 < n )
		{
			var(spec[nothing ], float3, _171_413 ) = p;
			var(spec[nothing ], float2, _173_413 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_413.xy  );
			p.x  = _173_413.x ;
			p.y  = _173_413.y ;
			var(spec[nothing ], float3, _195_413 ) = p;
			var(spec[nothing ], float2, _197_413 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_413.xz  );
			p.x  = _197_413.x ;
			p.z  = _197_413.y ;
			var(spec[nothing ], float3, _222_413 ) = p;
			var(spec[nothing ], float2, _224_413 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_413.yz  );
			p.y  = _224_413.x ;
			p.z  = _224_413.y ;
			if(mod(54.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(54.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_413 ) = _234;
			c_413 = abs(c_413 ) - s;
			d = max(d, - c_413 );
		};
		i += 1.0;
		if(55.00 < n )
		{
			var(spec[nothing ], float3, _171_418 ) = p;
			var(spec[nothing ], float2, _173_418 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_418.xy  );
			p.x  = _173_418.x ;
			p.y  = _173_418.y ;
			var(spec[nothing ], float3, _195_418 ) = p;
			var(spec[nothing ], float2, _197_418 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_418.xz  );
			p.x  = _197_418.x ;
			p.z  = _197_418.y ;
			var(spec[nothing ], float3, _222_418 ) = p;
			var(spec[nothing ], float2, _224_418 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_418.yz  );
			p.y  = _224_418.x ;
			p.z  = _224_418.y ;
			if(mod(55.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(55.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_418 ) = _234;
			c_418 = abs(c_418 ) - s;
			d = max(d, - c_418 );
		};
		i += 1.0;
		if(56.00 < n )
		{
			var(spec[nothing ], float3, _171_423 ) = p;
			var(spec[nothing ], float2, _173_423 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_423.xy  );
			p.x  = _173_423.x ;
			p.y  = _173_423.y ;
			var(spec[nothing ], float3, _195_423 ) = p;
			var(spec[nothing ], float2, _197_423 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_423.xz  );
			p.x  = _197_423.x ;
			p.z  = _197_423.y ;
			var(spec[nothing ], float3, _222_423 ) = p;
			var(spec[nothing ], float2, _224_423 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_423.yz  );
			p.y  = _224_423.x ;
			p.z  = _224_423.y ;
			if(mod(56.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(56.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_423 ) = _234;
			c_423 = abs(c_423 ) - s;
			d = max(d, - c_423 );
		};
		i += 1.0;
		if(57.00 < n )
		{
			var(spec[nothing ], float3, _171_428 ) = p;
			var(spec[nothing ], float2, _173_428 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_428.xy  );
			p.x  = _173_428.x ;
			p.y  = _173_428.y ;
			var(spec[nothing ], float3, _195_428 ) = p;
			var(spec[nothing ], float2, _197_428 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_428.xz  );
			p.x  = _197_428.x ;
			p.z  = _197_428.y ;
			var(spec[nothing ], float3, _222_428 ) = p;
			var(spec[nothing ], float2, _224_428 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_428.yz  );
			p.y  = _224_428.x ;
			p.z  = _224_428.y ;
			if(mod(57.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(57.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_428 ) = _234;
			c_428 = abs(c_428 ) - s;
			d = max(d, - c_428 );
		};
		i += 1.0;
		if(58.00 < n )
		{
			var(spec[nothing ], float3, _171_433 ) = p;
			var(spec[nothing ], float2, _173_433 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_433.xy  );
			p.x  = _173_433.x ;
			p.y  = _173_433.y ;
			var(spec[nothing ], float3, _195_433 ) = p;
			var(spec[nothing ], float2, _197_433 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_433.xz  );
			p.x  = _197_433.x ;
			p.z  = _197_433.y ;
			var(spec[nothing ], float3, _222_433 ) = p;
			var(spec[nothing ], float2, _224_433 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_433.yz  );
			p.y  = _224_433.x ;
			p.z  = _224_433.y ;
			if(mod(58.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(58.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_433 ) = _234;
			c_433 = abs(c_433 ) - s;
			d = max(d, - c_433 );
		};
		i += 1.0;
		if(59.00 < n )
		{
			var(spec[nothing ], float3, _171_438 ) = p;
			var(spec[nothing ], float2, _173_438 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_438.xy  );
			p.x  = _173_438.x ;
			p.y  = _173_438.y ;
			var(spec[nothing ], float3, _195_438 ) = p;
			var(spec[nothing ], float2, _197_438 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_438.xz  );
			p.x  = _197_438.x ;
			p.z  = _197_438.y ;
			var(spec[nothing ], float3, _222_438 ) = p;
			var(spec[nothing ], float2, _224_438 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_438.yz  );
			p.y  = _224_438.x ;
			p.z  = _224_438.y ;
			if(mod(59.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(59.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_438 ) = _234;
			c_438 = abs(c_438 ) - s;
			d = max(d, - c_438 );
		};
		i += 1.0;
		if(60.00 < n )
		{
			var(spec[nothing ], float3, _171_443 ) = p;
			var(spec[nothing ], float2, _173_443 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_443.xy  );
			p.x  = _173_443.x ;
			p.y  = _173_443.y ;
			var(spec[nothing ], float3, _195_443 ) = p;
			var(spec[nothing ], float2, _197_443 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_443.xz  );
			p.x  = _197_443.x ;
			p.z  = _197_443.y ;
			var(spec[nothing ], float3, _222_443 ) = p;
			var(spec[nothing ], float2, _224_443 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_443.yz  );
			p.y  = _224_443.x ;
			p.z  = _224_443.y ;
			if(mod(60.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(60.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_443 ) = _234;
			c_443 = abs(c_443 ) - s;
			d = max(d, - c_443 );
		};
		i += 1.0;
		if(61.00 < n )
		{
			var(spec[nothing ], float3, _171_448 ) = p;
			var(spec[nothing ], float2, _173_448 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_448.xy  );
			p.x  = _173_448.x ;
			p.y  = _173_448.y ;
			var(spec[nothing ], float3, _195_448 ) = p;
			var(spec[nothing ], float2, _197_448 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_448.xz  );
			p.x  = _197_448.x ;
			p.z  = _197_448.y ;
			var(spec[nothing ], float3, _222_448 ) = p;
			var(spec[nothing ], float2, _224_448 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_448.yz  );
			p.y  = _224_448.x ;
			p.z  = _224_448.y ;
			if(mod(61.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(61.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_448 ) = _234;
			c_448 = abs(c_448 ) - s;
			d = max(d, - c_448 );
		};
		i += 1.0;
		if(62.00 < n )
		{
			var(spec[nothing ], float3, _171_453 ) = p;
			var(spec[nothing ], float2, _173_453 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_453.xy  );
			p.x  = _173_453.x ;
			p.y  = _173_453.y ;
			var(spec[nothing ], float3, _195_453 ) = p;
			var(spec[nothing ], float2, _197_453 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_453.xz  );
			p.x  = _197_453.x ;
			p.z  = _197_453.y ;
			var(spec[nothing ], float3, _222_453 ) = p;
			var(spec[nothing ], float2, _224_453 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_453.yz  );
			p.y  = _224_453.x ;
			p.z  = _224_453.y ;
			if(mod(62.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(62.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_453 ) = _234;
			c_453 = abs(c_453 ) - s;
			d = max(d, - c_453 );
		};
		i += 1.0;
		if(63.00 < n )
		{
			var(spec[nothing ], float3, _171_458 ) = p;
			var(spec[nothing ], float2, _173_458 ) = mul(float2x2(float2(cos(a ), sin(a ) ), float2(- sin(a ), cos(a ) ) ), _171_458.xy  );
			p.x  = _173_458.x ;
			p.y  = _173_458.y ;
			var(spec[nothing ], float3, _195_458 ) = p;
			var(spec[nothing ], float2, _197_458 ) = mul(float2x2(float2(cos(a * 0.5 ), sin(a * 0.5 ) ), float2(- sin(a * 0.5 ), cos(a * 0.5 ) ) ), _195_458.xz  );
			p.x  = _197_458.x ;
			p.z  = _197_458.y ;
			var(spec[nothing ], float3, _222_458 ) = p;
			var(spec[nothing ], float2, _224_458 ) = mul(float2x2(float2(cos(a + a ), sin(a + a ) ), float2(- sin(a + a ), cos(a + a ) ) ), _222_458.yz  );
			p.y  = _224_458.x ;
			p.z  = _224_458.y ;
			if(mod(63.00, 3.0 ) == 0.0 )
			{
				_234 = p.x ;
			}
			else
			{
				if(mod(63.00, 3.0 ) == 1.0 )
				{
					_243 = p.y ;
				}
				else
				{
					_243 = p.z ;
				};
				_234 = _243;
			};
			var(spec[nothing ], float, c_458 ) = _234;
			c_458 = abs(c_458 ) - s;
			d = max(d, - c_458 );
		};
	} 
	return <- d;
};
func(spec[nothing ], float, bx )
params(var(spec[nothing ], float3, p ), var(spec[nothing ], float3, s ) )
{
	var(spec[nothing ], float3, q ) = abs(p ) - s;
	return <- min(max(q.x , max(q.y , q.z  ) ), 0.0 ) + length(max(q, 0.0F.xxx  ) );
};
func(spec[nothing ], float, mp )
params(var(spec[inout, nothing ], float3, p ), var(spec[inout, nothing ], float3, oc ), var(spec[inout, nothing ], float, oa ), var(spec[inout, nothing ], float, io ), var(spec[inout, nothing ], float3, ss ), var(spec[inout, nothing ], float3, vb ), var(spec[inout, nothing ], int, ec ) )
{
	if(iMouse.z  > 0.0 )
	{
		var(spec[nothing ], float3, _369 ) = p;
		var(spec[nothing ], float2, _371 ) = mul(float2x2(float2(cos(2.0 * ((iMouse.y  / iResolution.y  ) - 0.5 ) ), sin(2.0 * ((iMouse.y  / iResolution.y  ) - 0.5 ) ) ), float2(- sin(2.0 * ((iMouse.y  / iResolution.y  ) - 0.5 ) ), cos(2.0 * ((iMouse.y  / iResolution.y  ) - 0.5 ) ) ) ), _369.yz  );
		p.y  = _371.x ;
		p.z  = _371.y ;
		var(spec[nothing ], float3, _413 ) = p;
		var(spec[nothing ], float2, _415 ) = mul(float2x2(float2(cos(-7.0 * ((iMouse.x  / iResolution.x  ) - 0.5 ) ), sin(-7.0 * ((iMouse.x  / iResolution.x  ) - 0.5 ) ) ), float2(- sin(-7.0 * ((iMouse.x  / iResolution.x  ) - 0.5 ) ), cos(-7.0 * ((iMouse.x  / iResolution.x  ) - 0.5 ) ) ) ), _413.zx  );
		p.z  = _415.x ;
		p.x  = _415.y ;
	};
	var(spec[nothing ], float3, pp ) = p;
	var(spec[nothing ], float3, _440 ) = p;
	var(spec[nothing ], float2, _442 ) = mul(float2x2(float2(cos(tt * 0.200000003 ), sin(tt * 0.200000003 ) ), float2(- sin(tt * 0.200000003 ), cos(tt * 0.200000003 ) ) ), _440.xz  );
	p.x  = _442.x ;
	p.z  = _442.y ;
	var(spec[nothing ], float3, _463 ) = p;
	var(spec[nothing ], float2, _465 ) = mul(float2x2(float2(cos(tt * 0.200000003 ), sin(tt * 0.200000003 ) ), float2(- sin(tt * 0.200000003 ), cos(tt * 0.200000003 ) ) ), _463.xy  );
	p.x  = _465.x ;
	p.y  = _465.y ;
	var(spec[nothing ], float3, param ) = p;
	var(spec[nothing ], int, param_1 ) = 3;
	var(spec[nothing ], float3, _474 ) = lattice(param, 3 );
	p = _474;
	var(spec[nothing ], float3, param_2 ) = p;
	var(spec[nothing ], float2, param_3 ) = 1.0F.xx ;
	var(spec[nothing ], float, _480 ) = cy(param_2, param_3 );
	var(spec[nothing ], float, sd ) = _480 - 0.0500000007;
	var(spec[nothing ], float3, param_4 ) = p;
	var(spec[nothing ], float, param_5 ) = sd;
	var(spec[nothing ], float, param_6 ) = 1.0;
	var(spec[nothing ], float, param_7 ) = sin(tt * 0.100000001 );
	var(spec[nothing ], float, param_8 ) = 0.200000003;
	var(spec[nothing ], float, _494 ) = shatter(param_4, param_5, 1.0, param_7, 0.200000003 );
	sd = _494;
	var(spec[nothing ], float3, param_9 ) = p;
	var(spec[nothing ], float3, param_10 ) = float3(0.100000001, 2.0999999, 8.0 );
	sd = min(sd, bx(param_9, param_10 ) - 0.300000012 );
	var(spec[nothing ], float3, param_11 ) = p;
	var(spec[nothing ], float2, param_12 ) = float2(4.0, 1.0 );
	var(spec[nothing ], float, _512 ) = cy(param_11, param_12 );
	sd = lerp(sd, _512, (cos(tt * 0.5 ) * 0.5 ) + 0.5 );
	sd = abs(sd ) - 0.00100000005;
	if(sd < 0.00100000005 )
	{
		oc = lerp(float3(1.0, 0.100000001, 0.600000024 ), float3(0.0, 0.600000024, 1.0 ), pow(length(pp ) * 0.180000007, 1.5 ).xxx  );
		io = 1.10000002;
		oa = 1.04999995 - (length(pp ) * 0.200000003 );
		ss = 0.0F.xxx ;
		vb = float3(0.0, 2.5, 2.5 );
		ec = 2;
	};
	return <- sd;
};
func(spec[nothing ], void, tr )
params(var(spec[nothing ], float3, ro ), var(spec[nothing ], float3, rd ), var(spec[inout, nothing ], float3, oc ), var(spec[inout, nothing ], float, oa ), var(spec[inout, nothing ], float, cd ), var(spec[inout, nothing ], float, td ), var(spec[inout, nothing ], float, io ), var(spec[inout, nothing ], float3, ss ), var(spec[inout, nothing ], float3, vb ), var(spec[inout, nothing ], int, ec ) )
{
	vb.x  = 0.0F;
	cd = 0.0;
	var(spec[nothing ], bool, _br_flag_13 ) = false;
	block
	{
		var(spec[nothing ], float, i ) = 0.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param ) = ro + (rd * 0.0 );
			var(spec[nothing ], float3, param_1 ) = oc;
			var(spec[nothing ], float, param_2 ) = oa;
			var(spec[nothing ], float, param_3 ) = io;
			var(spec[nothing ], float3, param_4 ) = ss;
			var(spec[nothing ], float3, param_5 ) = vb;
			var(spec[nothing ], int, param_6 ) = ec;
			var(spec[nothing ], float, _580 ) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6 );
			oc = param_1;
			oa = param_2;
			io = param_3;
			ss = param_4;
			vb = param_5;
			ec = param_6;
			var(spec[nothing ], float, sd ) = _580;
			cd += sd;
			td += sd;
			if((sd < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 1.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_468 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_468 ) = oc;
			var(spec[nothing ], float, param_2_468 ) = oa;
			var(spec[nothing ], float, param_3_468 ) = io;
			var(spec[nothing ], float3, param_4_468 ) = ss;
			var(spec[nothing ], float3, param_5_468 ) = vb;
			var(spec[nothing ], int, param_6_468 ) = ec;
			var(spec[nothing ], float, _580_468 ) = mp(param_468, param_1_468, param_2_468, param_3_468, param_4_468, param_5_468, param_6_468 );
			oc = param_1_468;
			oa = param_2_468;
			io = param_3_468;
			ss = param_4_468;
			vb = param_5_468;
			ec = param_6_468;
			var(spec[nothing ], float, sd_468 ) = _580_468;
			cd += sd_468;
			td += sd_468;
			if((sd_468 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 2.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_470 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_470 ) = oc;
			var(spec[nothing ], float, param_2_470 ) = oa;
			var(spec[nothing ], float, param_3_470 ) = io;
			var(spec[nothing ], float3, param_4_470 ) = ss;
			var(spec[nothing ], float3, param_5_470 ) = vb;
			var(spec[nothing ], int, param_6_470 ) = ec;
			var(spec[nothing ], float, _580_470 ) = mp(param_470, param_1_470, param_2_470, param_3_470, param_4_470, param_5_470, param_6_470 );
			oc = param_1_470;
			oa = param_2_470;
			io = param_3_470;
			ss = param_4_470;
			vb = param_5_470;
			ec = param_6_470;
			var(spec[nothing ], float, sd_470 ) = _580_470;
			cd += sd_470;
			td += sd_470;
			if((sd_470 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 3.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_472 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_472 ) = oc;
			var(spec[nothing ], float, param_2_472 ) = oa;
			var(spec[nothing ], float, param_3_472 ) = io;
			var(spec[nothing ], float3, param_4_472 ) = ss;
			var(spec[nothing ], float3, param_5_472 ) = vb;
			var(spec[nothing ], int, param_6_472 ) = ec;
			var(spec[nothing ], float, _580_472 ) = mp(param_472, param_1_472, param_2_472, param_3_472, param_4_472, param_5_472, param_6_472 );
			oc = param_1_472;
			oa = param_2_472;
			io = param_3_472;
			ss = param_4_472;
			vb = param_5_472;
			ec = param_6_472;
			var(spec[nothing ], float, sd_472 ) = _580_472;
			cd += sd_472;
			td += sd_472;
			if((sd_472 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 4.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_474 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_474 ) = oc;
			var(spec[nothing ], float, param_2_474 ) = oa;
			var(spec[nothing ], float, param_3_474 ) = io;
			var(spec[nothing ], float3, param_4_474 ) = ss;
			var(spec[nothing ], float3, param_5_474 ) = vb;
			var(spec[nothing ], int, param_6_474 ) = ec;
			var(spec[nothing ], float, _580_474 ) = mp(param_474, param_1_474, param_2_474, param_3_474, param_4_474, param_5_474, param_6_474 );
			oc = param_1_474;
			oa = param_2_474;
			io = param_3_474;
			ss = param_4_474;
			vb = param_5_474;
			ec = param_6_474;
			var(spec[nothing ], float, sd_474 ) = _580_474;
			cd += sd_474;
			td += sd_474;
			if((sd_474 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 5.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_476 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_476 ) = oc;
			var(spec[nothing ], float, param_2_476 ) = oa;
			var(spec[nothing ], float, param_3_476 ) = io;
			var(spec[nothing ], float3, param_4_476 ) = ss;
			var(spec[nothing ], float3, param_5_476 ) = vb;
			var(spec[nothing ], int, param_6_476 ) = ec;
			var(spec[nothing ], float, _580_476 ) = mp(param_476, param_1_476, param_2_476, param_3_476, param_4_476, param_5_476, param_6_476 );
			oc = param_1_476;
			oa = param_2_476;
			io = param_3_476;
			ss = param_4_476;
			vb = param_5_476;
			ec = param_6_476;
			var(spec[nothing ], float, sd_476 ) = _580_476;
			cd += sd_476;
			td += sd_476;
			if((sd_476 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 6.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_478 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_478 ) = oc;
			var(spec[nothing ], float, param_2_478 ) = oa;
			var(spec[nothing ], float, param_3_478 ) = io;
			var(spec[nothing ], float3, param_4_478 ) = ss;
			var(spec[nothing ], float3, param_5_478 ) = vb;
			var(spec[nothing ], int, param_6_478 ) = ec;
			var(spec[nothing ], float, _580_478 ) = mp(param_478, param_1_478, param_2_478, param_3_478, param_4_478, param_5_478, param_6_478 );
			oc = param_1_478;
			oa = param_2_478;
			io = param_3_478;
			ss = param_4_478;
			vb = param_5_478;
			ec = param_6_478;
			var(spec[nothing ], float, sd_478 ) = _580_478;
			cd += sd_478;
			td += sd_478;
			if((sd_478 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 7.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_480 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_480 ) = oc;
			var(spec[nothing ], float, param_2_480 ) = oa;
			var(spec[nothing ], float, param_3_480 ) = io;
			var(spec[nothing ], float3, param_4_480 ) = ss;
			var(spec[nothing ], float3, param_5_480 ) = vb;
			var(spec[nothing ], int, param_6_480 ) = ec;
			var(spec[nothing ], float, _580_480 ) = mp(param_480, param_1_480, param_2_480, param_3_480, param_4_480, param_5_480, param_6_480 );
			oc = param_1_480;
			oa = param_2_480;
			io = param_3_480;
			ss = param_4_480;
			vb = param_5_480;
			ec = param_6_480;
			var(spec[nothing ], float, sd_480 ) = _580_480;
			cd += sd_480;
			td += sd_480;
			if((sd_480 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 8.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_482 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_482 ) = oc;
			var(spec[nothing ], float, param_2_482 ) = oa;
			var(spec[nothing ], float, param_3_482 ) = io;
			var(spec[nothing ], float3, param_4_482 ) = ss;
			var(spec[nothing ], float3, param_5_482 ) = vb;
			var(spec[nothing ], int, param_6_482 ) = ec;
			var(spec[nothing ], float, _580_482 ) = mp(param_482, param_1_482, param_2_482, param_3_482, param_4_482, param_5_482, param_6_482 );
			oc = param_1_482;
			oa = param_2_482;
			io = param_3_482;
			ss = param_4_482;
			vb = param_5_482;
			ec = param_6_482;
			var(spec[nothing ], float, sd_482 ) = _580_482;
			cd += sd_482;
			td += sd_482;
			if((sd_482 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 9.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_484 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_484 ) = oc;
			var(spec[nothing ], float, param_2_484 ) = oa;
			var(spec[nothing ], float, param_3_484 ) = io;
			var(spec[nothing ], float3, param_4_484 ) = ss;
			var(spec[nothing ], float3, param_5_484 ) = vb;
			var(spec[nothing ], int, param_6_484 ) = ec;
			var(spec[nothing ], float, _580_484 ) = mp(param_484, param_1_484, param_2_484, param_3_484, param_4_484, param_5_484, param_6_484 );
			oc = param_1_484;
			oa = param_2_484;
			io = param_3_484;
			ss = param_4_484;
			vb = param_5_484;
			ec = param_6_484;
			var(spec[nothing ], float, sd_484 ) = _580_484;
			cd += sd_484;
			td += sd_484;
			if((sd_484 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 10.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_486 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_486 ) = oc;
			var(spec[nothing ], float, param_2_486 ) = oa;
			var(spec[nothing ], float, param_3_486 ) = io;
			var(spec[nothing ], float3, param_4_486 ) = ss;
			var(spec[nothing ], float3, param_5_486 ) = vb;
			var(spec[nothing ], int, param_6_486 ) = ec;
			var(spec[nothing ], float, _580_486 ) = mp(param_486, param_1_486, param_2_486, param_3_486, param_4_486, param_5_486, param_6_486 );
			oc = param_1_486;
			oa = param_2_486;
			io = param_3_486;
			ss = param_4_486;
			vb = param_5_486;
			ec = param_6_486;
			var(spec[nothing ], float, sd_486 ) = _580_486;
			cd += sd_486;
			td += sd_486;
			if((sd_486 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 11.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_488 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_488 ) = oc;
			var(spec[nothing ], float, param_2_488 ) = oa;
			var(spec[nothing ], float, param_3_488 ) = io;
			var(spec[nothing ], float3, param_4_488 ) = ss;
			var(spec[nothing ], float3, param_5_488 ) = vb;
			var(spec[nothing ], int, param_6_488 ) = ec;
			var(spec[nothing ], float, _580_488 ) = mp(param_488, param_1_488, param_2_488, param_3_488, param_4_488, param_5_488, param_6_488 );
			oc = param_1_488;
			oa = param_2_488;
			io = param_3_488;
			ss = param_4_488;
			vb = param_5_488;
			ec = param_6_488;
			var(spec[nothing ], float, sd_488 ) = _580_488;
			cd += sd_488;
			td += sd_488;
			if((sd_488 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 12.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_490 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_490 ) = oc;
			var(spec[nothing ], float, param_2_490 ) = oa;
			var(spec[nothing ], float, param_3_490 ) = io;
			var(spec[nothing ], float3, param_4_490 ) = ss;
			var(spec[nothing ], float3, param_5_490 ) = vb;
			var(spec[nothing ], int, param_6_490 ) = ec;
			var(spec[nothing ], float, _580_490 ) = mp(param_490, param_1_490, param_2_490, param_3_490, param_4_490, param_5_490, param_6_490 );
			oc = param_1_490;
			oa = param_2_490;
			io = param_3_490;
			ss = param_4_490;
			vb = param_5_490;
			ec = param_6_490;
			var(spec[nothing ], float, sd_490 ) = _580_490;
			cd += sd_490;
			td += sd_490;
			if((sd_490 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 13.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_492 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_492 ) = oc;
			var(spec[nothing ], float, param_2_492 ) = oa;
			var(spec[nothing ], float, param_3_492 ) = io;
			var(spec[nothing ], float3, param_4_492 ) = ss;
			var(spec[nothing ], float3, param_5_492 ) = vb;
			var(spec[nothing ], int, param_6_492 ) = ec;
			var(spec[nothing ], float, _580_492 ) = mp(param_492, param_1_492, param_2_492, param_3_492, param_4_492, param_5_492, param_6_492 );
			oc = param_1_492;
			oa = param_2_492;
			io = param_3_492;
			ss = param_4_492;
			vb = param_5_492;
			ec = param_6_492;
			var(spec[nothing ], float, sd_492 ) = _580_492;
			cd += sd_492;
			td += sd_492;
			if((sd_492 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 14.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_494 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_494 ) = oc;
			var(spec[nothing ], float, param_2_494 ) = oa;
			var(spec[nothing ], float, param_3_494 ) = io;
			var(spec[nothing ], float3, param_4_494 ) = ss;
			var(spec[nothing ], float3, param_5_494 ) = vb;
			var(spec[nothing ], int, param_6_494 ) = ec;
			var(spec[nothing ], float, _580_494 ) = mp(param_494, param_1_494, param_2_494, param_3_494, param_4_494, param_5_494, param_6_494 );
			oc = param_1_494;
			oa = param_2_494;
			io = param_3_494;
			ss = param_4_494;
			vb = param_5_494;
			ec = param_6_494;
			var(spec[nothing ], float, sd_494 ) = _580_494;
			cd += sd_494;
			td += sd_494;
			if((sd_494 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 15.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_496 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_496 ) = oc;
			var(spec[nothing ], float, param_2_496 ) = oa;
			var(spec[nothing ], float, param_3_496 ) = io;
			var(spec[nothing ], float3, param_4_496 ) = ss;
			var(spec[nothing ], float3, param_5_496 ) = vb;
			var(spec[nothing ], int, param_6_496 ) = ec;
			var(spec[nothing ], float, _580_496 ) = mp(param_496, param_1_496, param_2_496, param_3_496, param_4_496, param_5_496, param_6_496 );
			oc = param_1_496;
			oa = param_2_496;
			io = param_3_496;
			ss = param_4_496;
			vb = param_5_496;
			ec = param_6_496;
			var(spec[nothing ], float, sd_496 ) = _580_496;
			cd += sd_496;
			td += sd_496;
			if((sd_496 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 16.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_498 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_498 ) = oc;
			var(spec[nothing ], float, param_2_498 ) = oa;
			var(spec[nothing ], float, param_3_498 ) = io;
			var(spec[nothing ], float3, param_4_498 ) = ss;
			var(spec[nothing ], float3, param_5_498 ) = vb;
			var(spec[nothing ], int, param_6_498 ) = ec;
			var(spec[nothing ], float, _580_498 ) = mp(param_498, param_1_498, param_2_498, param_3_498, param_4_498, param_5_498, param_6_498 );
			oc = param_1_498;
			oa = param_2_498;
			io = param_3_498;
			ss = param_4_498;
			vb = param_5_498;
			ec = param_6_498;
			var(spec[nothing ], float, sd_498 ) = _580_498;
			cd += sd_498;
			td += sd_498;
			if((sd_498 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 17.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_500 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_500 ) = oc;
			var(spec[nothing ], float, param_2_500 ) = oa;
			var(spec[nothing ], float, param_3_500 ) = io;
			var(spec[nothing ], float3, param_4_500 ) = ss;
			var(spec[nothing ], float3, param_5_500 ) = vb;
			var(spec[nothing ], int, param_6_500 ) = ec;
			var(spec[nothing ], float, _580_500 ) = mp(param_500, param_1_500, param_2_500, param_3_500, param_4_500, param_5_500, param_6_500 );
			oc = param_1_500;
			oa = param_2_500;
			io = param_3_500;
			ss = param_4_500;
			vb = param_5_500;
			ec = param_6_500;
			var(spec[nothing ], float, sd_500 ) = _580_500;
			cd += sd_500;
			td += sd_500;
			if((sd_500 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 18.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_502 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_502 ) = oc;
			var(spec[nothing ], float, param_2_502 ) = oa;
			var(spec[nothing ], float, param_3_502 ) = io;
			var(spec[nothing ], float3, param_4_502 ) = ss;
			var(spec[nothing ], float3, param_5_502 ) = vb;
			var(spec[nothing ], int, param_6_502 ) = ec;
			var(spec[nothing ], float, _580_502 ) = mp(param_502, param_1_502, param_2_502, param_3_502, param_4_502, param_5_502, param_6_502 );
			oc = param_1_502;
			oa = param_2_502;
			io = param_3_502;
			ss = param_4_502;
			vb = param_5_502;
			ec = param_6_502;
			var(spec[nothing ], float, sd_502 ) = _580_502;
			cd += sd_502;
			td += sd_502;
			if((sd_502 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 19.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_504 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_504 ) = oc;
			var(spec[nothing ], float, param_2_504 ) = oa;
			var(spec[nothing ], float, param_3_504 ) = io;
			var(spec[nothing ], float3, param_4_504 ) = ss;
			var(spec[nothing ], float3, param_5_504 ) = vb;
			var(spec[nothing ], int, param_6_504 ) = ec;
			var(spec[nothing ], float, _580_504 ) = mp(param_504, param_1_504, param_2_504, param_3_504, param_4_504, param_5_504, param_6_504 );
			oc = param_1_504;
			oa = param_2_504;
			io = param_3_504;
			ss = param_4_504;
			vb = param_5_504;
			ec = param_6_504;
			var(spec[nothing ], float, sd_504 ) = _580_504;
			cd += sd_504;
			td += sd_504;
			if((sd_504 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 20.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_506 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_506 ) = oc;
			var(spec[nothing ], float, param_2_506 ) = oa;
			var(spec[nothing ], float, param_3_506 ) = io;
			var(spec[nothing ], float3, param_4_506 ) = ss;
			var(spec[nothing ], float3, param_5_506 ) = vb;
			var(spec[nothing ], int, param_6_506 ) = ec;
			var(spec[nothing ], float, _580_506 ) = mp(param_506, param_1_506, param_2_506, param_3_506, param_4_506, param_5_506, param_6_506 );
			oc = param_1_506;
			oa = param_2_506;
			io = param_3_506;
			ss = param_4_506;
			vb = param_5_506;
			ec = param_6_506;
			var(spec[nothing ], float, sd_506 ) = _580_506;
			cd += sd_506;
			td += sd_506;
			if((sd_506 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 21.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_508 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_508 ) = oc;
			var(spec[nothing ], float, param_2_508 ) = oa;
			var(spec[nothing ], float, param_3_508 ) = io;
			var(spec[nothing ], float3, param_4_508 ) = ss;
			var(spec[nothing ], float3, param_5_508 ) = vb;
			var(spec[nothing ], int, param_6_508 ) = ec;
			var(spec[nothing ], float, _580_508 ) = mp(param_508, param_1_508, param_2_508, param_3_508, param_4_508, param_5_508, param_6_508 );
			oc = param_1_508;
			oa = param_2_508;
			io = param_3_508;
			ss = param_4_508;
			vb = param_5_508;
			ec = param_6_508;
			var(spec[nothing ], float, sd_508 ) = _580_508;
			cd += sd_508;
			td += sd_508;
			if((sd_508 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 22.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_510 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_510 ) = oc;
			var(spec[nothing ], float, param_2_510 ) = oa;
			var(spec[nothing ], float, param_3_510 ) = io;
			var(spec[nothing ], float3, param_4_510 ) = ss;
			var(spec[nothing ], float3, param_5_510 ) = vb;
			var(spec[nothing ], int, param_6_510 ) = ec;
			var(spec[nothing ], float, _580_510 ) = mp(param_510, param_1_510, param_2_510, param_3_510, param_4_510, param_5_510, param_6_510 );
			oc = param_1_510;
			oa = param_2_510;
			io = param_3_510;
			ss = param_4_510;
			vb = param_5_510;
			ec = param_6_510;
			var(spec[nothing ], float, sd_510 ) = _580_510;
			cd += sd_510;
			td += sd_510;
			if((sd_510 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 23.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_512 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_512 ) = oc;
			var(spec[nothing ], float, param_2_512 ) = oa;
			var(spec[nothing ], float, param_3_512 ) = io;
			var(spec[nothing ], float3, param_4_512 ) = ss;
			var(spec[nothing ], float3, param_5_512 ) = vb;
			var(spec[nothing ], int, param_6_512 ) = ec;
			var(spec[nothing ], float, _580_512 ) = mp(param_512, param_1_512, param_2_512, param_3_512, param_4_512, param_5_512, param_6_512 );
			oc = param_1_512;
			oa = param_2_512;
			io = param_3_512;
			ss = param_4_512;
			vb = param_5_512;
			ec = param_6_512;
			var(spec[nothing ], float, sd_512 ) = _580_512;
			cd += sd_512;
			td += sd_512;
			if((sd_512 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 24.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_514 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_514 ) = oc;
			var(spec[nothing ], float, param_2_514 ) = oa;
			var(spec[nothing ], float, param_3_514 ) = io;
			var(spec[nothing ], float3, param_4_514 ) = ss;
			var(spec[nothing ], float3, param_5_514 ) = vb;
			var(spec[nothing ], int, param_6_514 ) = ec;
			var(spec[nothing ], float, _580_514 ) = mp(param_514, param_1_514, param_2_514, param_3_514, param_4_514, param_5_514, param_6_514 );
			oc = param_1_514;
			oa = param_2_514;
			io = param_3_514;
			ss = param_4_514;
			vb = param_5_514;
			ec = param_6_514;
			var(spec[nothing ], float, sd_514 ) = _580_514;
			cd += sd_514;
			td += sd_514;
			if((sd_514 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 25.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_516 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_516 ) = oc;
			var(spec[nothing ], float, param_2_516 ) = oa;
			var(spec[nothing ], float, param_3_516 ) = io;
			var(spec[nothing ], float3, param_4_516 ) = ss;
			var(spec[nothing ], float3, param_5_516 ) = vb;
			var(spec[nothing ], int, param_6_516 ) = ec;
			var(spec[nothing ], float, _580_516 ) = mp(param_516, param_1_516, param_2_516, param_3_516, param_4_516, param_5_516, param_6_516 );
			oc = param_1_516;
			oa = param_2_516;
			io = param_3_516;
			ss = param_4_516;
			vb = param_5_516;
			ec = param_6_516;
			var(spec[nothing ], float, sd_516 ) = _580_516;
			cd += sd_516;
			td += sd_516;
			if((sd_516 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 26.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_518 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_518 ) = oc;
			var(spec[nothing ], float, param_2_518 ) = oa;
			var(spec[nothing ], float, param_3_518 ) = io;
			var(spec[nothing ], float3, param_4_518 ) = ss;
			var(spec[nothing ], float3, param_5_518 ) = vb;
			var(spec[nothing ], int, param_6_518 ) = ec;
			var(spec[nothing ], float, _580_518 ) = mp(param_518, param_1_518, param_2_518, param_3_518, param_4_518, param_5_518, param_6_518 );
			oc = param_1_518;
			oa = param_2_518;
			io = param_3_518;
			ss = param_4_518;
			vb = param_5_518;
			ec = param_6_518;
			var(spec[nothing ], float, sd_518 ) = _580_518;
			cd += sd_518;
			td += sd_518;
			if((sd_518 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 27.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_520 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_520 ) = oc;
			var(spec[nothing ], float, param_2_520 ) = oa;
			var(spec[nothing ], float, param_3_520 ) = io;
			var(spec[nothing ], float3, param_4_520 ) = ss;
			var(spec[nothing ], float3, param_5_520 ) = vb;
			var(spec[nothing ], int, param_6_520 ) = ec;
			var(spec[nothing ], float, _580_520 ) = mp(param_520, param_1_520, param_2_520, param_3_520, param_4_520, param_5_520, param_6_520 );
			oc = param_1_520;
			oa = param_2_520;
			io = param_3_520;
			ss = param_4_520;
			vb = param_5_520;
			ec = param_6_520;
			var(spec[nothing ], float, sd_520 ) = _580_520;
			cd += sd_520;
			td += sd_520;
			if((sd_520 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 28.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_522 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_522 ) = oc;
			var(spec[nothing ], float, param_2_522 ) = oa;
			var(spec[nothing ], float, param_3_522 ) = io;
			var(spec[nothing ], float3, param_4_522 ) = ss;
			var(spec[nothing ], float3, param_5_522 ) = vb;
			var(spec[nothing ], int, param_6_522 ) = ec;
			var(spec[nothing ], float, _580_522 ) = mp(param_522, param_1_522, param_2_522, param_3_522, param_4_522, param_5_522, param_6_522 );
			oc = param_1_522;
			oa = param_2_522;
			io = param_3_522;
			ss = param_4_522;
			vb = param_5_522;
			ec = param_6_522;
			var(spec[nothing ], float, sd_522 ) = _580_522;
			cd += sd_522;
			td += sd_522;
			if((sd_522 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 29.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_524 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_524 ) = oc;
			var(spec[nothing ], float, param_2_524 ) = oa;
			var(spec[nothing ], float, param_3_524 ) = io;
			var(spec[nothing ], float3, param_4_524 ) = ss;
			var(spec[nothing ], float3, param_5_524 ) = vb;
			var(spec[nothing ], int, param_6_524 ) = ec;
			var(spec[nothing ], float, _580_524 ) = mp(param_524, param_1_524, param_2_524, param_3_524, param_4_524, param_5_524, param_6_524 );
			oc = param_1_524;
			oa = param_2_524;
			io = param_3_524;
			ss = param_4_524;
			vb = param_5_524;
			ec = param_6_524;
			var(spec[nothing ], float, sd_524 ) = _580_524;
			cd += sd_524;
			td += sd_524;
			if((sd_524 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 30.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_526 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_526 ) = oc;
			var(spec[nothing ], float, param_2_526 ) = oa;
			var(spec[nothing ], float, param_3_526 ) = io;
			var(spec[nothing ], float3, param_4_526 ) = ss;
			var(spec[nothing ], float3, param_5_526 ) = vb;
			var(spec[nothing ], int, param_6_526 ) = ec;
			var(spec[nothing ], float, _580_526 ) = mp(param_526, param_1_526, param_2_526, param_3_526, param_4_526, param_5_526, param_6_526 );
			oc = param_1_526;
			oa = param_2_526;
			io = param_3_526;
			ss = param_4_526;
			vb = param_5_526;
			ec = param_6_526;
			var(spec[nothing ], float, sd_526 ) = _580_526;
			cd += sd_526;
			td += sd_526;
			if((sd_526 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 31.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_528 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_528 ) = oc;
			var(spec[nothing ], float, param_2_528 ) = oa;
			var(spec[nothing ], float, param_3_528 ) = io;
			var(spec[nothing ], float3, param_4_528 ) = ss;
			var(spec[nothing ], float3, param_5_528 ) = vb;
			var(spec[nothing ], int, param_6_528 ) = ec;
			var(spec[nothing ], float, _580_528 ) = mp(param_528, param_1_528, param_2_528, param_3_528, param_4_528, param_5_528, param_6_528 );
			oc = param_1_528;
			oa = param_2_528;
			io = param_3_528;
			ss = param_4_528;
			vb = param_5_528;
			ec = param_6_528;
			var(spec[nothing ], float, sd_528 ) = _580_528;
			cd += sd_528;
			td += sd_528;
			if((sd_528 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 32.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_530 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_530 ) = oc;
			var(spec[nothing ], float, param_2_530 ) = oa;
			var(spec[nothing ], float, param_3_530 ) = io;
			var(spec[nothing ], float3, param_4_530 ) = ss;
			var(spec[nothing ], float3, param_5_530 ) = vb;
			var(spec[nothing ], int, param_6_530 ) = ec;
			var(spec[nothing ], float, _580_530 ) = mp(param_530, param_1_530, param_2_530, param_3_530, param_4_530, param_5_530, param_6_530 );
			oc = param_1_530;
			oa = param_2_530;
			io = param_3_530;
			ss = param_4_530;
			vb = param_5_530;
			ec = param_6_530;
			var(spec[nothing ], float, sd_530 ) = _580_530;
			cd += sd_530;
			td += sd_530;
			if((sd_530 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 33.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_532 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_532 ) = oc;
			var(spec[nothing ], float, param_2_532 ) = oa;
			var(spec[nothing ], float, param_3_532 ) = io;
			var(spec[nothing ], float3, param_4_532 ) = ss;
			var(spec[nothing ], float3, param_5_532 ) = vb;
			var(spec[nothing ], int, param_6_532 ) = ec;
			var(spec[nothing ], float, _580_532 ) = mp(param_532, param_1_532, param_2_532, param_3_532, param_4_532, param_5_532, param_6_532 );
			oc = param_1_532;
			oa = param_2_532;
			io = param_3_532;
			ss = param_4_532;
			vb = param_5_532;
			ec = param_6_532;
			var(spec[nothing ], float, sd_532 ) = _580_532;
			cd += sd_532;
			td += sd_532;
			if((sd_532 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 34.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_534 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_534 ) = oc;
			var(spec[nothing ], float, param_2_534 ) = oa;
			var(spec[nothing ], float, param_3_534 ) = io;
			var(spec[nothing ], float3, param_4_534 ) = ss;
			var(spec[nothing ], float3, param_5_534 ) = vb;
			var(spec[nothing ], int, param_6_534 ) = ec;
			var(spec[nothing ], float, _580_534 ) = mp(param_534, param_1_534, param_2_534, param_3_534, param_4_534, param_5_534, param_6_534 );
			oc = param_1_534;
			oa = param_2_534;
			io = param_3_534;
			ss = param_4_534;
			vb = param_5_534;
			ec = param_6_534;
			var(spec[nothing ], float, sd_534 ) = _580_534;
			cd += sd_534;
			td += sd_534;
			if((sd_534 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 35.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_536 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_536 ) = oc;
			var(spec[nothing ], float, param_2_536 ) = oa;
			var(spec[nothing ], float, param_3_536 ) = io;
			var(spec[nothing ], float3, param_4_536 ) = ss;
			var(spec[nothing ], float3, param_5_536 ) = vb;
			var(spec[nothing ], int, param_6_536 ) = ec;
			var(spec[nothing ], float, _580_536 ) = mp(param_536, param_1_536, param_2_536, param_3_536, param_4_536, param_5_536, param_6_536 );
			oc = param_1_536;
			oa = param_2_536;
			io = param_3_536;
			ss = param_4_536;
			vb = param_5_536;
			ec = param_6_536;
			var(spec[nothing ], float, sd_536 ) = _580_536;
			cd += sd_536;
			td += sd_536;
			if((sd_536 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 36.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_538 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_538 ) = oc;
			var(spec[nothing ], float, param_2_538 ) = oa;
			var(spec[nothing ], float, param_3_538 ) = io;
			var(spec[nothing ], float3, param_4_538 ) = ss;
			var(spec[nothing ], float3, param_5_538 ) = vb;
			var(spec[nothing ], int, param_6_538 ) = ec;
			var(spec[nothing ], float, _580_538 ) = mp(param_538, param_1_538, param_2_538, param_3_538, param_4_538, param_5_538, param_6_538 );
			oc = param_1_538;
			oa = param_2_538;
			io = param_3_538;
			ss = param_4_538;
			vb = param_5_538;
			ec = param_6_538;
			var(spec[nothing ], float, sd_538 ) = _580_538;
			cd += sd_538;
			td += sd_538;
			if((sd_538 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 37.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_540 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_540 ) = oc;
			var(spec[nothing ], float, param_2_540 ) = oa;
			var(spec[nothing ], float, param_3_540 ) = io;
			var(spec[nothing ], float3, param_4_540 ) = ss;
			var(spec[nothing ], float3, param_5_540 ) = vb;
			var(spec[nothing ], int, param_6_540 ) = ec;
			var(spec[nothing ], float, _580_540 ) = mp(param_540, param_1_540, param_2_540, param_3_540, param_4_540, param_5_540, param_6_540 );
			oc = param_1_540;
			oa = param_2_540;
			io = param_3_540;
			ss = param_4_540;
			vb = param_5_540;
			ec = param_6_540;
			var(spec[nothing ], float, sd_540 ) = _580_540;
			cd += sd_540;
			td += sd_540;
			if((sd_540 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 38.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_542 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_542 ) = oc;
			var(spec[nothing ], float, param_2_542 ) = oa;
			var(spec[nothing ], float, param_3_542 ) = io;
			var(spec[nothing ], float3, param_4_542 ) = ss;
			var(spec[nothing ], float3, param_5_542 ) = vb;
			var(spec[nothing ], int, param_6_542 ) = ec;
			var(spec[nothing ], float, _580_542 ) = mp(param_542, param_1_542, param_2_542, param_3_542, param_4_542, param_5_542, param_6_542 );
			oc = param_1_542;
			oa = param_2_542;
			io = param_3_542;
			ss = param_4_542;
			vb = param_5_542;
			ec = param_6_542;
			var(spec[nothing ], float, sd_542 ) = _580_542;
			cd += sd_542;
			td += sd_542;
			if((sd_542 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 39.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_544 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_544 ) = oc;
			var(spec[nothing ], float, param_2_544 ) = oa;
			var(spec[nothing ], float, param_3_544 ) = io;
			var(spec[nothing ], float3, param_4_544 ) = ss;
			var(spec[nothing ], float3, param_5_544 ) = vb;
			var(spec[nothing ], int, param_6_544 ) = ec;
			var(spec[nothing ], float, _580_544 ) = mp(param_544, param_1_544, param_2_544, param_3_544, param_4_544, param_5_544, param_6_544 );
			oc = param_1_544;
			oa = param_2_544;
			io = param_3_544;
			ss = param_4_544;
			vb = param_5_544;
			ec = param_6_544;
			var(spec[nothing ], float, sd_544 ) = _580_544;
			cd += sd_544;
			td += sd_544;
			if((sd_544 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 40.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_546 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_546 ) = oc;
			var(spec[nothing ], float, param_2_546 ) = oa;
			var(spec[nothing ], float, param_3_546 ) = io;
			var(spec[nothing ], float3, param_4_546 ) = ss;
			var(spec[nothing ], float3, param_5_546 ) = vb;
			var(spec[nothing ], int, param_6_546 ) = ec;
			var(spec[nothing ], float, _580_546 ) = mp(param_546, param_1_546, param_2_546, param_3_546, param_4_546, param_5_546, param_6_546 );
			oc = param_1_546;
			oa = param_2_546;
			io = param_3_546;
			ss = param_4_546;
			vb = param_5_546;
			ec = param_6_546;
			var(spec[nothing ], float, sd_546 ) = _580_546;
			cd += sd_546;
			td += sd_546;
			if((sd_546 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 41.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_548 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_548 ) = oc;
			var(spec[nothing ], float, param_2_548 ) = oa;
			var(spec[nothing ], float, param_3_548 ) = io;
			var(spec[nothing ], float3, param_4_548 ) = ss;
			var(spec[nothing ], float3, param_5_548 ) = vb;
			var(spec[nothing ], int, param_6_548 ) = ec;
			var(spec[nothing ], float, _580_548 ) = mp(param_548, param_1_548, param_2_548, param_3_548, param_4_548, param_5_548, param_6_548 );
			oc = param_1_548;
			oa = param_2_548;
			io = param_3_548;
			ss = param_4_548;
			vb = param_5_548;
			ec = param_6_548;
			var(spec[nothing ], float, sd_548 ) = _580_548;
			cd += sd_548;
			td += sd_548;
			if((sd_548 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 42.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_550 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_550 ) = oc;
			var(spec[nothing ], float, param_2_550 ) = oa;
			var(spec[nothing ], float, param_3_550 ) = io;
			var(spec[nothing ], float3, param_4_550 ) = ss;
			var(spec[nothing ], float3, param_5_550 ) = vb;
			var(spec[nothing ], int, param_6_550 ) = ec;
			var(spec[nothing ], float, _580_550 ) = mp(param_550, param_1_550, param_2_550, param_3_550, param_4_550, param_5_550, param_6_550 );
			oc = param_1_550;
			oa = param_2_550;
			io = param_3_550;
			ss = param_4_550;
			vb = param_5_550;
			ec = param_6_550;
			var(spec[nothing ], float, sd_550 ) = _580_550;
			cd += sd_550;
			td += sd_550;
			if((sd_550 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 43.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_552 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_552 ) = oc;
			var(spec[nothing ], float, param_2_552 ) = oa;
			var(spec[nothing ], float, param_3_552 ) = io;
			var(spec[nothing ], float3, param_4_552 ) = ss;
			var(spec[nothing ], float3, param_5_552 ) = vb;
			var(spec[nothing ], int, param_6_552 ) = ec;
			var(spec[nothing ], float, _580_552 ) = mp(param_552, param_1_552, param_2_552, param_3_552, param_4_552, param_5_552, param_6_552 );
			oc = param_1_552;
			oa = param_2_552;
			io = param_3_552;
			ss = param_4_552;
			vb = param_5_552;
			ec = param_6_552;
			var(spec[nothing ], float, sd_552 ) = _580_552;
			cd += sd_552;
			td += sd_552;
			if((sd_552 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 44.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_554 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_554 ) = oc;
			var(spec[nothing ], float, param_2_554 ) = oa;
			var(spec[nothing ], float, param_3_554 ) = io;
			var(spec[nothing ], float3, param_4_554 ) = ss;
			var(spec[nothing ], float3, param_5_554 ) = vb;
			var(spec[nothing ], int, param_6_554 ) = ec;
			var(spec[nothing ], float, _580_554 ) = mp(param_554, param_1_554, param_2_554, param_3_554, param_4_554, param_5_554, param_6_554 );
			oc = param_1_554;
			oa = param_2_554;
			io = param_3_554;
			ss = param_4_554;
			vb = param_5_554;
			ec = param_6_554;
			var(spec[nothing ], float, sd_554 ) = _580_554;
			cd += sd_554;
			td += sd_554;
			if((sd_554 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 45.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_556 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_556 ) = oc;
			var(spec[nothing ], float, param_2_556 ) = oa;
			var(spec[nothing ], float, param_3_556 ) = io;
			var(spec[nothing ], float3, param_4_556 ) = ss;
			var(spec[nothing ], float3, param_5_556 ) = vb;
			var(spec[nothing ], int, param_6_556 ) = ec;
			var(spec[nothing ], float, _580_556 ) = mp(param_556, param_1_556, param_2_556, param_3_556, param_4_556, param_5_556, param_6_556 );
			oc = param_1_556;
			oa = param_2_556;
			io = param_3_556;
			ss = param_4_556;
			vb = param_5_556;
			ec = param_6_556;
			var(spec[nothing ], float, sd_556 ) = _580_556;
			cd += sd_556;
			td += sd_556;
			if((sd_556 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 46.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_558 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_558 ) = oc;
			var(spec[nothing ], float, param_2_558 ) = oa;
			var(spec[nothing ], float, param_3_558 ) = io;
			var(spec[nothing ], float3, param_4_558 ) = ss;
			var(spec[nothing ], float3, param_5_558 ) = vb;
			var(spec[nothing ], int, param_6_558 ) = ec;
			var(spec[nothing ], float, _580_558 ) = mp(param_558, param_1_558, param_2_558, param_3_558, param_4_558, param_5_558, param_6_558 );
			oc = param_1_558;
			oa = param_2_558;
			io = param_3_558;
			ss = param_4_558;
			vb = param_5_558;
			ec = param_6_558;
			var(spec[nothing ], float, sd_558 ) = _580_558;
			cd += sd_558;
			td += sd_558;
			if((sd_558 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 47.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_560 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_560 ) = oc;
			var(spec[nothing ], float, param_2_560 ) = oa;
			var(spec[nothing ], float, param_3_560 ) = io;
			var(spec[nothing ], float3, param_4_560 ) = ss;
			var(spec[nothing ], float3, param_5_560 ) = vb;
			var(spec[nothing ], int, param_6_560 ) = ec;
			var(spec[nothing ], float, _580_560 ) = mp(param_560, param_1_560, param_2_560, param_3_560, param_4_560, param_5_560, param_6_560 );
			oc = param_1_560;
			oa = param_2_560;
			io = param_3_560;
			ss = param_4_560;
			vb = param_5_560;
			ec = param_6_560;
			var(spec[nothing ], float, sd_560 ) = _580_560;
			cd += sd_560;
			td += sd_560;
			if((sd_560 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 48.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_562 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_562 ) = oc;
			var(spec[nothing ], float, param_2_562 ) = oa;
			var(spec[nothing ], float, param_3_562 ) = io;
			var(spec[nothing ], float3, param_4_562 ) = ss;
			var(spec[nothing ], float3, param_5_562 ) = vb;
			var(spec[nothing ], int, param_6_562 ) = ec;
			var(spec[nothing ], float, _580_562 ) = mp(param_562, param_1_562, param_2_562, param_3_562, param_4_562, param_5_562, param_6_562 );
			oc = param_1_562;
			oa = param_2_562;
			io = param_3_562;
			ss = param_4_562;
			vb = param_5_562;
			ec = param_6_562;
			var(spec[nothing ], float, sd_562 ) = _580_562;
			cd += sd_562;
			td += sd_562;
			if((sd_562 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 49.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_564 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_564 ) = oc;
			var(spec[nothing ], float, param_2_564 ) = oa;
			var(spec[nothing ], float, param_3_564 ) = io;
			var(spec[nothing ], float3, param_4_564 ) = ss;
			var(spec[nothing ], float3, param_5_564 ) = vb;
			var(spec[nothing ], int, param_6_564 ) = ec;
			var(spec[nothing ], float, _580_564 ) = mp(param_564, param_1_564, param_2_564, param_3_564, param_4_564, param_5_564, param_6_564 );
			oc = param_1_564;
			oa = param_2_564;
			io = param_3_564;
			ss = param_4_564;
			vb = param_5_564;
			ec = param_6_564;
			var(spec[nothing ], float, sd_564 ) = _580_564;
			cd += sd_564;
			td += sd_564;
			if((sd_564 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 50.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_566 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_566 ) = oc;
			var(spec[nothing ], float, param_2_566 ) = oa;
			var(spec[nothing ], float, param_3_566 ) = io;
			var(spec[nothing ], float3, param_4_566 ) = ss;
			var(spec[nothing ], float3, param_5_566 ) = vb;
			var(spec[nothing ], int, param_6_566 ) = ec;
			var(spec[nothing ], float, _580_566 ) = mp(param_566, param_1_566, param_2_566, param_3_566, param_4_566, param_5_566, param_6_566 );
			oc = param_1_566;
			oa = param_2_566;
			io = param_3_566;
			ss = param_4_566;
			vb = param_5_566;
			ec = param_6_566;
			var(spec[nothing ], float, sd_566 ) = _580_566;
			cd += sd_566;
			td += sd_566;
			if((sd_566 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 51.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_568 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_568 ) = oc;
			var(spec[nothing ], float, param_2_568 ) = oa;
			var(spec[nothing ], float, param_3_568 ) = io;
			var(spec[nothing ], float3, param_4_568 ) = ss;
			var(spec[nothing ], float3, param_5_568 ) = vb;
			var(spec[nothing ], int, param_6_568 ) = ec;
			var(spec[nothing ], float, _580_568 ) = mp(param_568, param_1_568, param_2_568, param_3_568, param_4_568, param_5_568, param_6_568 );
			oc = param_1_568;
			oa = param_2_568;
			io = param_3_568;
			ss = param_4_568;
			vb = param_5_568;
			ec = param_6_568;
			var(spec[nothing ], float, sd_568 ) = _580_568;
			cd += sd_568;
			td += sd_568;
			if((sd_568 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 52.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_570 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_570 ) = oc;
			var(spec[nothing ], float, param_2_570 ) = oa;
			var(spec[nothing ], float, param_3_570 ) = io;
			var(spec[nothing ], float3, param_4_570 ) = ss;
			var(spec[nothing ], float3, param_5_570 ) = vb;
			var(spec[nothing ], int, param_6_570 ) = ec;
			var(spec[nothing ], float, _580_570 ) = mp(param_570, param_1_570, param_2_570, param_3_570, param_4_570, param_5_570, param_6_570 );
			oc = param_1_570;
			oa = param_2_570;
			io = param_3_570;
			ss = param_4_570;
			vb = param_5_570;
			ec = param_6_570;
			var(spec[nothing ], float, sd_570 ) = _580_570;
			cd += sd_570;
			td += sd_570;
			if((sd_570 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 53.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_572 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_572 ) = oc;
			var(spec[nothing ], float, param_2_572 ) = oa;
			var(spec[nothing ], float, param_3_572 ) = io;
			var(spec[nothing ], float3, param_4_572 ) = ss;
			var(spec[nothing ], float3, param_5_572 ) = vb;
			var(spec[nothing ], int, param_6_572 ) = ec;
			var(spec[nothing ], float, _580_572 ) = mp(param_572, param_1_572, param_2_572, param_3_572, param_4_572, param_5_572, param_6_572 );
			oc = param_1_572;
			oa = param_2_572;
			io = param_3_572;
			ss = param_4_572;
			vb = param_5_572;
			ec = param_6_572;
			var(spec[nothing ], float, sd_572 ) = _580_572;
			cd += sd_572;
			td += sd_572;
			if((sd_572 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 54.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_574 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_574 ) = oc;
			var(spec[nothing ], float, param_2_574 ) = oa;
			var(spec[nothing ], float, param_3_574 ) = io;
			var(spec[nothing ], float3, param_4_574 ) = ss;
			var(spec[nothing ], float3, param_5_574 ) = vb;
			var(spec[nothing ], int, param_6_574 ) = ec;
			var(spec[nothing ], float, _580_574 ) = mp(param_574, param_1_574, param_2_574, param_3_574, param_4_574, param_5_574, param_6_574 );
			oc = param_1_574;
			oa = param_2_574;
			io = param_3_574;
			ss = param_4_574;
			vb = param_5_574;
			ec = param_6_574;
			var(spec[nothing ], float, sd_574 ) = _580_574;
			cd += sd_574;
			td += sd_574;
			if((sd_574 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 55.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_576 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_576 ) = oc;
			var(spec[nothing ], float, param_2_576 ) = oa;
			var(spec[nothing ], float, param_3_576 ) = io;
			var(spec[nothing ], float3, param_4_576 ) = ss;
			var(spec[nothing ], float3, param_5_576 ) = vb;
			var(spec[nothing ], int, param_6_576 ) = ec;
			var(spec[nothing ], float, _580_576 ) = mp(param_576, param_1_576, param_2_576, param_3_576, param_4_576, param_5_576, param_6_576 );
			oc = param_1_576;
			oa = param_2_576;
			io = param_3_576;
			ss = param_4_576;
			vb = param_5_576;
			ec = param_6_576;
			var(spec[nothing ], float, sd_576 ) = _580_576;
			cd += sd_576;
			td += sd_576;
			if((sd_576 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 56.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_578 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_578 ) = oc;
			var(spec[nothing ], float, param_2_578 ) = oa;
			var(spec[nothing ], float, param_3_578 ) = io;
			var(spec[nothing ], float3, param_4_578 ) = ss;
			var(spec[nothing ], float3, param_5_578 ) = vb;
			var(spec[nothing ], int, param_6_578 ) = ec;
			var(spec[nothing ], float, _580_578 ) = mp(param_578, param_1_578, param_2_578, param_3_578, param_4_578, param_5_578, param_6_578 );
			oc = param_1_578;
			oa = param_2_578;
			io = param_3_578;
			ss = param_4_578;
			vb = param_5_578;
			ec = param_6_578;
			var(spec[nothing ], float, sd_578 ) = _580_578;
			cd += sd_578;
			td += sd_578;
			if((sd_578 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 57.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_580 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_580 ) = oc;
			var(spec[nothing ], float, param_2_580 ) = oa;
			var(spec[nothing ], float, param_3_580 ) = io;
			var(spec[nothing ], float3, param_4_580 ) = ss;
			var(spec[nothing ], float3, param_5_580 ) = vb;
			var(spec[nothing ], int, param_6_580 ) = ec;
			var(spec[nothing ], float, _580_580 ) = mp(param_580, param_1_580, param_2_580, param_3_580, param_4_580, param_5_580, param_6_580 );
			oc = param_1_580;
			oa = param_2_580;
			io = param_3_580;
			ss = param_4_580;
			vb = param_5_580;
			ec = param_6_580;
			var(spec[nothing ], float, sd_580 ) = _580_580;
			cd += sd_580;
			td += sd_580;
			if((sd_580 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 58.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_582 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_582 ) = oc;
			var(spec[nothing ], float, param_2_582 ) = oa;
			var(spec[nothing ], float, param_3_582 ) = io;
			var(spec[nothing ], float3, param_4_582 ) = ss;
			var(spec[nothing ], float3, param_5_582 ) = vb;
			var(spec[nothing ], int, param_6_582 ) = ec;
			var(spec[nothing ], float, _580_582 ) = mp(param_582, param_1_582, param_2_582, param_3_582, param_4_582, param_5_582, param_6_582 );
			oc = param_1_582;
			oa = param_2_582;
			io = param_3_582;
			ss = param_4_582;
			vb = param_5_582;
			ec = param_6_582;
			var(spec[nothing ], float, sd_582 ) = _580_582;
			cd += sd_582;
			td += sd_582;
			if((sd_582 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 59.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_584 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_584 ) = oc;
			var(spec[nothing ], float, param_2_584 ) = oa;
			var(spec[nothing ], float, param_3_584 ) = io;
			var(spec[nothing ], float3, param_4_584 ) = ss;
			var(spec[nothing ], float3, param_5_584 ) = vb;
			var(spec[nothing ], int, param_6_584 ) = ec;
			var(spec[nothing ], float, _580_584 ) = mp(param_584, param_1_584, param_2_584, param_3_584, param_4_584, param_5_584, param_6_584 );
			oc = param_1_584;
			oa = param_2_584;
			io = param_3_584;
			ss = param_4_584;
			vb = param_5_584;
			ec = param_6_584;
			var(spec[nothing ], float, sd_584 ) = _580_584;
			cd += sd_584;
			td += sd_584;
			if((sd_584 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 60.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_586 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_586 ) = oc;
			var(spec[nothing ], float, param_2_586 ) = oa;
			var(spec[nothing ], float, param_3_586 ) = io;
			var(spec[nothing ], float3, param_4_586 ) = ss;
			var(spec[nothing ], float3, param_5_586 ) = vb;
			var(spec[nothing ], int, param_6_586 ) = ec;
			var(spec[nothing ], float, _580_586 ) = mp(param_586, param_1_586, param_2_586, param_3_586, param_4_586, param_5_586, param_6_586 );
			oc = param_1_586;
			oa = param_2_586;
			io = param_3_586;
			ss = param_4_586;
			vb = param_5_586;
			ec = param_6_586;
			var(spec[nothing ], float, sd_586 ) = _580_586;
			cd += sd_586;
			td += sd_586;
			if((sd_586 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 61.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_588 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_588 ) = oc;
			var(spec[nothing ], float, param_2_588 ) = oa;
			var(spec[nothing ], float, param_3_588 ) = io;
			var(spec[nothing ], float3, param_4_588 ) = ss;
			var(spec[nothing ], float3, param_5_588 ) = vb;
			var(spec[nothing ], int, param_6_588 ) = ec;
			var(spec[nothing ], float, _580_588 ) = mp(param_588, param_1_588, param_2_588, param_3_588, param_4_588, param_5_588, param_6_588 );
			oc = param_1_588;
			oa = param_2_588;
			io = param_3_588;
			ss = param_4_588;
			vb = param_5_588;
			ec = param_6_588;
			var(spec[nothing ], float, sd_588 ) = _580_588;
			cd += sd_588;
			td += sd_588;
			if((sd_588 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 62.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_590 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_590 ) = oc;
			var(spec[nothing ], float, param_2_590 ) = oa;
			var(spec[nothing ], float, param_3_590 ) = io;
			var(spec[nothing ], float3, param_4_590 ) = ss;
			var(spec[nothing ], float3, param_5_590 ) = vb;
			var(spec[nothing ], int, param_6_590 ) = ec;
			var(spec[nothing ], float, _580_590 ) = mp(param_590, param_1_590, param_2_590, param_3_590, param_4_590, param_5_590, param_6_590 );
			oc = param_1_590;
			oa = param_2_590;
			io = param_3_590;
			ss = param_4_590;
			vb = param_5_590;
			ec = param_6_590;
			var(spec[nothing ], float, sd_590 ) = _580_590;
			cd += sd_590;
			td += sd_590;
			if((sd_590 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 63.0;
		if(! _br_flag_13 )
		{
			var(spec[nothing ], float3, param_592 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_1_592 ) = oc;
			var(spec[nothing ], float, param_2_592 ) = oa;
			var(spec[nothing ], float, param_3_592 ) = io;
			var(spec[nothing ], float3, param_4_592 ) = ss;
			var(spec[nothing ], float3, param_5_592 ) = vb;
			var(spec[nothing ], int, param_6_592 ) = ec;
			var(spec[nothing ], float, _580_592 ) = mp(param_592, param_1_592, param_2_592, param_3_592, param_4_592, param_5_592, param_6_592 );
			oc = param_1_592;
			oa = param_2_592;
			io = param_3_592;
			ss = param_4_592;
			vb = param_5_592;
			ec = param_6_592;
			var(spec[nothing ], float, sd_592 ) = _580_592;
			cd += sd_592;
			td += sd_592;
			if((sd_592 < 9.99999974E-5 ) || (cd > 128.0 ) )
			{
				_br_flag_13 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
};
func(spec[nothing ], float3, nm )
params(var(spec[nothing ], float3, cp ), var(spec[inout, nothing ], float3, oc ), var(spec[inout, nothing ], float, oa ), var(spec[inout, nothing ], float, io ), var(spec[inout, nothing ], float3, ss ), var(spec[inout, nothing ], float3, vb ), var(spec[inout, nothing ], int, ec ) )
{
	var(spec[nothing ], float3x3, _623 ) = float3x3(float3(cp ), float3(cp ), float3(cp ) );
	var(spec[nothing ], float3x3, k ) = float3x3(_623[0 ] - float3(0.00100000005, 0.0, 0.0 ), _623[1 ] - float3(0.0, 0.00100000005, 0.0 ), _623[2 ] - float3(0.0, 0.0, 0.00100000005 ) );
	var(spec[nothing ], float3, param ) = cp;
	var(spec[nothing ], float3, param_1 ) = oc;
	var(spec[nothing ], float, param_2 ) = oa;
	var(spec[nothing ], float, param_3 ) = io;
	var(spec[nothing ], float3, param_4 ) = ss;
	var(spec[nothing ], float3, param_5 ) = vb;
	var(spec[nothing ], int, param_6 ) = ec;
	var(spec[nothing ], float, _652 ) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6 );
	oc = param_1;
	oa = param_2;
	io = param_3;
	ss = param_4;
	vb = param_5;
	ec = param_6;
	var(spec[nothing ], float3, param_7 ) = k[0 ];
	var(spec[nothing ], float3, param_8 ) = oc;
	var(spec[nothing ], float, param_9 ) = oa;
	var(spec[nothing ], float, param_10 ) = io;
	var(spec[nothing ], float3, param_11 ) = ss;
	var(spec[nothing ], float3, param_12 ) = vb;
	var(spec[nothing ], int, param_13 ) = ec;
	var(spec[nothing ], float, _674 ) = mp(param_7, param_8, param_9, param_10, param_11, param_12, param_13 );
	oc = param_8;
	oa = param_9;
	io = param_10;
	ss = param_11;
	vb = param_12;
	ec = param_13;
	var(spec[nothing ], float3, param_14 ) = k[1 ];
	var(spec[nothing ], float3, param_15 ) = oc;
	var(spec[nothing ], float, param_16 ) = oa;
	var(spec[nothing ], float, param_17 ) = io;
	var(spec[nothing ], float3, param_18 ) = ss;
	var(spec[nothing ], float3, param_19 ) = vb;
	var(spec[nothing ], int, param_20 ) = ec;
	var(spec[nothing ], float, _696 ) = mp(param_14, param_15, param_16, param_17, param_18, param_19, param_20 );
	oc = param_15;
	oa = param_16;
	io = param_17;
	ss = param_18;
	vb = param_19;
	ec = param_20;
	var(spec[nothing ], float3, param_21 ) = k[2 ];
	var(spec[nothing ], float3, param_22 ) = oc;
	var(spec[nothing ], float, param_23 ) = oa;
	var(spec[nothing ], float, param_24 ) = io;
	var(spec[nothing ], float3, param_25 ) = ss;
	var(spec[nothing ], float3, param_26 ) = vb;
	var(spec[nothing ], int, param_27 ) = ec;
	var(spec[nothing ], float, _718 ) = mp(param_21, param_22, param_23, param_24, param_25, param_26, param_27 );
	oc = param_22;
	oa = param_23;
	io = param_24;
	ss = param_25;
	vb = param_26;
	ec = param_27;
	return <- normalize(_652.xxx  - float3(_674, _696, _718 ) );
};
func(spec[nothing ], float3, px )
params(var(spec[nothing ], float3, rd ), var(spec[nothing ], float3, cp ), var(spec[nothing ], float3, cr ), var(spec[nothing ], float3, cn ), var(spec[nothing ], float, cd ), var(spec[inout, nothing ], float3, oc ), var(spec[inout, nothing ], float, oa ), var(spec[inout, nothing ], float, io ), var(spec[inout, nothing ], float3, ss ), var(spec[inout, nothing ], float3, vb ), var(spec[inout, nothing ], int, ec ) )
{
	var(spec[nothing ], float3, _func_ret_val_15 );
	var(spec[nothing ], bool, _func_ret_flag_15 ) = false;
	var(spec[nothing ], float3, cc ) = (float3(0.699999988, 0.400000006, 0.600000024 ) + (length(pow(abs(rd + float3(0.0, 0.5, 0.0 ) ), 3.0F.xxx  ) ) * 0.300000012 ).xxx  ) + glv;
	if(cd > 128.0 )
	{
		oa = 1.0;
		_func_ret_flag_15 = true;
		_func_ret_val_15 = cc;
	};
	if(! _func_ret_flag_15 )
	{
		var(spec[nothing ], float3, l ) = float3(0.400000006, 0.699999988, 0.800000011 );
		var(spec[nothing ], float, df ) = clamp(length(cn * l ), 0.0, 1.0 );
		var(spec[nothing ], float3, fr ) = lerp(cc, 0.400000006F.xxx , 0.5F.xxx  ) * pow(1.0 - df, 3.0 );
		var(spec[nothing ], float, sp ) = (1.0 - length(cross(cr, cn * l ) ) ) * 0.200000003;
		var(spec[nothing ], float3, param ) = cp + (cn * 0.300000012 );
		var(spec[nothing ], float3, param_1 ) = oc;
		var(spec[nothing ], float, param_2 ) = oa;
		var(spec[nothing ], float, param_3 ) = io;
		var(spec[nothing ], float3, param_4 ) = ss;
		var(spec[nothing ], float3, param_5 ) = vb;
		var(spec[nothing ], int, param_6 ) = ec;
		var(spec[nothing ], float, _799 ) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6 );
		oc = param_1;
		oa = param_2;
		io = param_3;
		ss = param_4;
		vb = param_5;
		ec = param_6;
		var(spec[nothing ], float, ao ) = min(_799 - 0.300000012, 0.300000012 ) * 0.5;
		cc = lerp(((((oc * ((df.xxx  + fr ) + ss ) ) + fr ) + sp.xxx  ) + ao.xxx  ) + glv, oc, vb.x .xxx  );
		_func_ret_flag_15 = true;
		_func_ret_val_15 = cc;
	};
	return <- _func_ret_val_15;
};
func(spec[nothing ], float4, render )
params(var(spec[nothing ], float2, frag ), var(spec[nothing ], float2, res ), var(spec[nothing ], float, time ) )
{
	var(spec[nothing ], float4, fc ) = 0.100000001F.xxxx ;
	var(spec[nothing ], int, es ) = 0;
	tt = mod(time, 260.0 );
	var(spec[nothing ], float2, uv ) = float2(frag.x  / res.x , frag.y  / res.y  );
	uv -= 0.5F.xx ;
	uv /= float2(res.y  / res.x , 1.0 );
	var(spec[nothing ], float3, ro ) = float3(0.0, 0.0, -15.0 );
	var(spec[nothing ], float3, rd ) = normalize(float3(uv, 1.0 ) );
	var(spec[nothing ], float3, oc );
	var(spec[nothing ], float, oa );
	var(spec[nothing ], float, cd );
	var(spec[nothing ], float, td );
	var(spec[nothing ], float, io );
	var(spec[nothing ], float3, ss );
	var(spec[nothing ], float3, vb );
	var(spec[nothing ], int, ec );
	var(spec[nothing ], float, _958 );
	var(spec[nothing ], bool, _br_flag_17 ) = false;
	block
	{
		var(spec[nothing ], int, i ) = 0;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param ) = ro;
			var(spec[nothing ], float3, param_1 ) = rd;
			var(spec[nothing ], float3, param_2 ) = oc;
			var(spec[nothing ], float, param_3 ) = oa;
			var(spec[nothing ], float, param_4 ) = cd;
			var(spec[nothing ], float, param_5 ) = td;
			var(spec[nothing ], float, param_6 ) = io;
			var(spec[nothing ], float3, param_7 ) = ss;
			var(spec[nothing ], float3, param_8 ) = vb;
			var(spec[nothing ], int, param_9 ) = ec;
			tr(param, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9 );
			oc = param_2;
			oa = param_3;
			cd = param_4;
			td = param_5;
			io = param_6;
			ss = param_7;
			vb = param_8;
			ec = param_9;
			var(spec[nothing ], float3, cp ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10 ) = cp;
			var(spec[nothing ], float3, param_11 ) = oc;
			var(spec[nothing ], float, param_12 ) = oa;
			var(spec[nothing ], float, param_13 ) = io;
			var(spec[nothing ], float3, param_14 ) = ss;
			var(spec[nothing ], float3, param_15 ) = vb;
			var(spec[nothing ], int, param_16 ) = ec;
			var(spec[nothing ], float3, _940 ) = nm(param_10, param_11, param_12, param_13, param_14, param_15, param_16 );
			oc = param_11;
			oa = param_12;
			io = param_13;
			ss = param_14;
			vb = param_15;
			ec = param_16;
			var(spec[nothing ], float3, cn ) = _940;
			ro = cp - (cn * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr ) = refract(rd, cn, _958 );
			if((length(cr ) == 0.0 ) && true )
			{
				cr = reflect(rd, cn );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr;
			};
			es -- ;
			var(spec[nothing ], bool, _993 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999 );
			if(_993 )
			{
				_999 = false;
			}
			else
			{
				_999 = _993;
			};
			if(_999 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17 ) = rd;
			var(spec[nothing ], float3, param_18 ) = cp;
			var(spec[nothing ], float3, param_19 ) = cr;
			var(spec[nothing ], float3, param_20 ) = cn;
			var(spec[nothing ], float, param_21 ) = cd;
			var(spec[nothing ], float3, param_22 ) = oc;
			var(spec[nothing ], float, param_23 ) = oa;
			var(spec[nothing ], float, param_24 ) = io;
			var(spec[nothing ], float3, param_25 ) = ss;
			var(spec[nothing ], float3, param_26 ) = vb;
			var(spec[nothing ], int, param_27 ) = ec;
			var(spec[nothing ], float3, _1033 ) = px(param_17, param_18, param_19, param_20, param_21, param_22, param_23, param_24, param_25, param_26, param_27 );
			oc = param_22;
			oa = param_23;
			io = param_24;
			ss = param_25;
			vb = param_26;
			ec = param_27;
			var(spec[nothing ], float3, cc ) = _1033;
			fc += (float4(cc * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 1;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_606 ) = ro;
			var(spec[nothing ], float3, param_1_606 ) = rd;
			var(spec[nothing ], float3, param_2_606 ) = oc;
			var(spec[nothing ], float, param_3_606 ) = oa;
			var(spec[nothing ], float, param_4_606 ) = cd;
			var(spec[nothing ], float, param_5_606 ) = td;
			var(spec[nothing ], float, param_6_606 ) = io;
			var(spec[nothing ], float3, param_7_606 ) = ss;
			var(spec[nothing ], float3, param_8_606 ) = vb;
			var(spec[nothing ], int, param_9_606 ) = ec;
			tr(param_606, param_1_606, param_2_606, param_3_606, param_4_606, param_5_606, param_6_606, param_7_606, param_8_606, param_9_606 );
			oc = param_2_606;
			oa = param_3_606;
			cd = param_4_606;
			td = param_5_606;
			io = param_6_606;
			ss = param_7_606;
			vb = param_8_606;
			ec = param_9_606;
			var(spec[nothing ], float3, cp_606 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_606 ) = cp_606;
			var(spec[nothing ], float3, param_11_606 ) = oc;
			var(spec[nothing ], float, param_12_606 ) = oa;
			var(spec[nothing ], float, param_13_606 ) = io;
			var(spec[nothing ], float3, param_14_606 ) = ss;
			var(spec[nothing ], float3, param_15_606 ) = vb;
			var(spec[nothing ], int, param_16_606 ) = ec;
			var(spec[nothing ], float3, _940_606 ) = nm(param_10_606, param_11_606, param_12_606, param_13_606, param_14_606, param_15_606, param_16_606 );
			oc = param_11_606;
			oa = param_12_606;
			io = param_13_606;
			ss = param_14_606;
			vb = param_15_606;
			ec = param_16_606;
			var(spec[nothing ], float3, cn_606 ) = _940_606;
			ro = cp_606 - (cn_606 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_606 ) = refract(rd, cn_606, _958 );
			if((length(cr_606 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_606 = reflect(rd, cn_606 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_606;
			};
			es -- ;
			var(spec[nothing ], bool, _993_606 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_606 );
			if(_993_606 )
			{
				_999_606 = true;
			}
			else
			{
				_999_606 = _993_606;
			};
			if(_999_606 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_606 ) = rd;
			var(spec[nothing ], float3, param_18_606 ) = cp_606;
			var(spec[nothing ], float3, param_19_606 ) = cr_606;
			var(spec[nothing ], float3, param_20_606 ) = cn_606;
			var(spec[nothing ], float, param_21_606 ) = cd;
			var(spec[nothing ], float3, param_22_606 ) = oc;
			var(spec[nothing ], float, param_23_606 ) = oa;
			var(spec[nothing ], float, param_24_606 ) = io;
			var(spec[nothing ], float3, param_25_606 ) = ss;
			var(spec[nothing ], float3, param_26_606 ) = vb;
			var(spec[nothing ], int, param_27_606 ) = ec;
			var(spec[nothing ], float3, _1033_606 ) = px(param_17_606, param_18_606, param_19_606, param_20_606, param_21_606, param_22_606, param_23_606, param_24_606, param_25_606, param_26_606, param_27_606 );
			oc = param_22_606;
			oa = param_23_606;
			io = param_24_606;
			ss = param_25_606;
			vb = param_26_606;
			ec = param_27_606;
			var(spec[nothing ], float3, cc_606 ) = _1033_606;
			fc += (float4(cc_606 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 2;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_615 ) = ro;
			var(spec[nothing ], float3, param_1_615 ) = rd;
			var(spec[nothing ], float3, param_2_615 ) = oc;
			var(spec[nothing ], float, param_3_615 ) = oa;
			var(spec[nothing ], float, param_4_615 ) = cd;
			var(spec[nothing ], float, param_5_615 ) = td;
			var(spec[nothing ], float, param_6_615 ) = io;
			var(spec[nothing ], float3, param_7_615 ) = ss;
			var(spec[nothing ], float3, param_8_615 ) = vb;
			var(spec[nothing ], int, param_9_615 ) = ec;
			tr(param_615, param_1_615, param_2_615, param_3_615, param_4_615, param_5_615, param_6_615, param_7_615, param_8_615, param_9_615 );
			oc = param_2_615;
			oa = param_3_615;
			cd = param_4_615;
			td = param_5_615;
			io = param_6_615;
			ss = param_7_615;
			vb = param_8_615;
			ec = param_9_615;
			var(spec[nothing ], float3, cp_615 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_615 ) = cp_615;
			var(spec[nothing ], float3, param_11_615 ) = oc;
			var(spec[nothing ], float, param_12_615 ) = oa;
			var(spec[nothing ], float, param_13_615 ) = io;
			var(spec[nothing ], float3, param_14_615 ) = ss;
			var(spec[nothing ], float3, param_15_615 ) = vb;
			var(spec[nothing ], int, param_16_615 ) = ec;
			var(spec[nothing ], float3, _940_615 ) = nm(param_10_615, param_11_615, param_12_615, param_13_615, param_14_615, param_15_615, param_16_615 );
			oc = param_11_615;
			oa = param_12_615;
			io = param_13_615;
			ss = param_14_615;
			vb = param_15_615;
			ec = param_16_615;
			var(spec[nothing ], float3, cn_615 ) = _940_615;
			ro = cp_615 - (cn_615 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_615 ) = refract(rd, cn_615, _958 );
			if((length(cr_615 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_615 = reflect(rd, cn_615 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_615;
			};
			es -- ;
			var(spec[nothing ], bool, _993_615 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_615 );
			if(_993_615 )
			{
				_999_615 = false;
			}
			else
			{
				_999_615 = _993_615;
			};
			if(_999_615 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_615 ) = rd;
			var(spec[nothing ], float3, param_18_615 ) = cp_615;
			var(spec[nothing ], float3, param_19_615 ) = cr_615;
			var(spec[nothing ], float3, param_20_615 ) = cn_615;
			var(spec[nothing ], float, param_21_615 ) = cd;
			var(spec[nothing ], float3, param_22_615 ) = oc;
			var(spec[nothing ], float, param_23_615 ) = oa;
			var(spec[nothing ], float, param_24_615 ) = io;
			var(spec[nothing ], float3, param_25_615 ) = ss;
			var(spec[nothing ], float3, param_26_615 ) = vb;
			var(spec[nothing ], int, param_27_615 ) = ec;
			var(spec[nothing ], float3, _1033_615 ) = px(param_17_615, param_18_615, param_19_615, param_20_615, param_21_615, param_22_615, param_23_615, param_24_615, param_25_615, param_26_615, param_27_615 );
			oc = param_22_615;
			oa = param_23_615;
			io = param_24_615;
			ss = param_25_615;
			vb = param_26_615;
			ec = param_27_615;
			var(spec[nothing ], float3, cc_615 ) = _1033_615;
			fc += (float4(cc_615 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 3;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_624 ) = ro;
			var(spec[nothing ], float3, param_1_624 ) = rd;
			var(spec[nothing ], float3, param_2_624 ) = oc;
			var(spec[nothing ], float, param_3_624 ) = oa;
			var(spec[nothing ], float, param_4_624 ) = cd;
			var(spec[nothing ], float, param_5_624 ) = td;
			var(spec[nothing ], float, param_6_624 ) = io;
			var(spec[nothing ], float3, param_7_624 ) = ss;
			var(spec[nothing ], float3, param_8_624 ) = vb;
			var(spec[nothing ], int, param_9_624 ) = ec;
			tr(param_624, param_1_624, param_2_624, param_3_624, param_4_624, param_5_624, param_6_624, param_7_624, param_8_624, param_9_624 );
			oc = param_2_624;
			oa = param_3_624;
			cd = param_4_624;
			td = param_5_624;
			io = param_6_624;
			ss = param_7_624;
			vb = param_8_624;
			ec = param_9_624;
			var(spec[nothing ], float3, cp_624 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_624 ) = cp_624;
			var(spec[nothing ], float3, param_11_624 ) = oc;
			var(spec[nothing ], float, param_12_624 ) = oa;
			var(spec[nothing ], float, param_13_624 ) = io;
			var(spec[nothing ], float3, param_14_624 ) = ss;
			var(spec[nothing ], float3, param_15_624 ) = vb;
			var(spec[nothing ], int, param_16_624 ) = ec;
			var(spec[nothing ], float3, _940_624 ) = nm(param_10_624, param_11_624, param_12_624, param_13_624, param_14_624, param_15_624, param_16_624 );
			oc = param_11_624;
			oa = param_12_624;
			io = param_13_624;
			ss = param_14_624;
			vb = param_15_624;
			ec = param_16_624;
			var(spec[nothing ], float3, cn_624 ) = _940_624;
			ro = cp_624 - (cn_624 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_624 ) = refract(rd, cn_624, _958 );
			if((length(cr_624 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_624 = reflect(rd, cn_624 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_624;
			};
			es -- ;
			var(spec[nothing ], bool, _993_624 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_624 );
			if(_993_624 )
			{
				_999_624 = true;
			}
			else
			{
				_999_624 = _993_624;
			};
			if(_999_624 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_624 ) = rd;
			var(spec[nothing ], float3, param_18_624 ) = cp_624;
			var(spec[nothing ], float3, param_19_624 ) = cr_624;
			var(spec[nothing ], float3, param_20_624 ) = cn_624;
			var(spec[nothing ], float, param_21_624 ) = cd;
			var(spec[nothing ], float3, param_22_624 ) = oc;
			var(spec[nothing ], float, param_23_624 ) = oa;
			var(spec[nothing ], float, param_24_624 ) = io;
			var(spec[nothing ], float3, param_25_624 ) = ss;
			var(spec[nothing ], float3, param_26_624 ) = vb;
			var(spec[nothing ], int, param_27_624 ) = ec;
			var(spec[nothing ], float3, _1033_624 ) = px(param_17_624, param_18_624, param_19_624, param_20_624, param_21_624, param_22_624, param_23_624, param_24_624, param_25_624, param_26_624, param_27_624 );
			oc = param_22_624;
			oa = param_23_624;
			io = param_24_624;
			ss = param_25_624;
			vb = param_26_624;
			ec = param_27_624;
			var(spec[nothing ], float3, cc_624 ) = _1033_624;
			fc += (float4(cc_624 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 4;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_633 ) = ro;
			var(spec[nothing ], float3, param_1_633 ) = rd;
			var(spec[nothing ], float3, param_2_633 ) = oc;
			var(spec[nothing ], float, param_3_633 ) = oa;
			var(spec[nothing ], float, param_4_633 ) = cd;
			var(spec[nothing ], float, param_5_633 ) = td;
			var(spec[nothing ], float, param_6_633 ) = io;
			var(spec[nothing ], float3, param_7_633 ) = ss;
			var(spec[nothing ], float3, param_8_633 ) = vb;
			var(spec[nothing ], int, param_9_633 ) = ec;
			tr(param_633, param_1_633, param_2_633, param_3_633, param_4_633, param_5_633, param_6_633, param_7_633, param_8_633, param_9_633 );
			oc = param_2_633;
			oa = param_3_633;
			cd = param_4_633;
			td = param_5_633;
			io = param_6_633;
			ss = param_7_633;
			vb = param_8_633;
			ec = param_9_633;
			var(spec[nothing ], float3, cp_633 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_633 ) = cp_633;
			var(spec[nothing ], float3, param_11_633 ) = oc;
			var(spec[nothing ], float, param_12_633 ) = oa;
			var(spec[nothing ], float, param_13_633 ) = io;
			var(spec[nothing ], float3, param_14_633 ) = ss;
			var(spec[nothing ], float3, param_15_633 ) = vb;
			var(spec[nothing ], int, param_16_633 ) = ec;
			var(spec[nothing ], float3, _940_633 ) = nm(param_10_633, param_11_633, param_12_633, param_13_633, param_14_633, param_15_633, param_16_633 );
			oc = param_11_633;
			oa = param_12_633;
			io = param_13_633;
			ss = param_14_633;
			vb = param_15_633;
			ec = param_16_633;
			var(spec[nothing ], float3, cn_633 ) = _940_633;
			ro = cp_633 - (cn_633 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_633 ) = refract(rd, cn_633, _958 );
			if((length(cr_633 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_633 = reflect(rd, cn_633 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_633;
			};
			es -- ;
			var(spec[nothing ], bool, _993_633 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_633 );
			if(_993_633 )
			{
				_999_633 = false;
			}
			else
			{
				_999_633 = _993_633;
			};
			if(_999_633 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_633 ) = rd;
			var(spec[nothing ], float3, param_18_633 ) = cp_633;
			var(spec[nothing ], float3, param_19_633 ) = cr_633;
			var(spec[nothing ], float3, param_20_633 ) = cn_633;
			var(spec[nothing ], float, param_21_633 ) = cd;
			var(spec[nothing ], float3, param_22_633 ) = oc;
			var(spec[nothing ], float, param_23_633 ) = oa;
			var(spec[nothing ], float, param_24_633 ) = io;
			var(spec[nothing ], float3, param_25_633 ) = ss;
			var(spec[nothing ], float3, param_26_633 ) = vb;
			var(spec[nothing ], int, param_27_633 ) = ec;
			var(spec[nothing ], float3, _1033_633 ) = px(param_17_633, param_18_633, param_19_633, param_20_633, param_21_633, param_22_633, param_23_633, param_24_633, param_25_633, param_26_633, param_27_633 );
			oc = param_22_633;
			oa = param_23_633;
			io = param_24_633;
			ss = param_25_633;
			vb = param_26_633;
			ec = param_27_633;
			var(spec[nothing ], float3, cc_633 ) = _1033_633;
			fc += (float4(cc_633 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 5;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_642 ) = ro;
			var(spec[nothing ], float3, param_1_642 ) = rd;
			var(spec[nothing ], float3, param_2_642 ) = oc;
			var(spec[nothing ], float, param_3_642 ) = oa;
			var(spec[nothing ], float, param_4_642 ) = cd;
			var(spec[nothing ], float, param_5_642 ) = td;
			var(spec[nothing ], float, param_6_642 ) = io;
			var(spec[nothing ], float3, param_7_642 ) = ss;
			var(spec[nothing ], float3, param_8_642 ) = vb;
			var(spec[nothing ], int, param_9_642 ) = ec;
			tr(param_642, param_1_642, param_2_642, param_3_642, param_4_642, param_5_642, param_6_642, param_7_642, param_8_642, param_9_642 );
			oc = param_2_642;
			oa = param_3_642;
			cd = param_4_642;
			td = param_5_642;
			io = param_6_642;
			ss = param_7_642;
			vb = param_8_642;
			ec = param_9_642;
			var(spec[nothing ], float3, cp_642 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_642 ) = cp_642;
			var(spec[nothing ], float3, param_11_642 ) = oc;
			var(spec[nothing ], float, param_12_642 ) = oa;
			var(spec[nothing ], float, param_13_642 ) = io;
			var(spec[nothing ], float3, param_14_642 ) = ss;
			var(spec[nothing ], float3, param_15_642 ) = vb;
			var(spec[nothing ], int, param_16_642 ) = ec;
			var(spec[nothing ], float3, _940_642 ) = nm(param_10_642, param_11_642, param_12_642, param_13_642, param_14_642, param_15_642, param_16_642 );
			oc = param_11_642;
			oa = param_12_642;
			io = param_13_642;
			ss = param_14_642;
			vb = param_15_642;
			ec = param_16_642;
			var(spec[nothing ], float3, cn_642 ) = _940_642;
			ro = cp_642 - (cn_642 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_642 ) = refract(rd, cn_642, _958 );
			if((length(cr_642 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_642 = reflect(rd, cn_642 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_642;
			};
			es -- ;
			var(spec[nothing ], bool, _993_642 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_642 );
			if(_993_642 )
			{
				_999_642 = true;
			}
			else
			{
				_999_642 = _993_642;
			};
			if(_999_642 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_642 ) = rd;
			var(spec[nothing ], float3, param_18_642 ) = cp_642;
			var(spec[nothing ], float3, param_19_642 ) = cr_642;
			var(spec[nothing ], float3, param_20_642 ) = cn_642;
			var(spec[nothing ], float, param_21_642 ) = cd;
			var(spec[nothing ], float3, param_22_642 ) = oc;
			var(spec[nothing ], float, param_23_642 ) = oa;
			var(spec[nothing ], float, param_24_642 ) = io;
			var(spec[nothing ], float3, param_25_642 ) = ss;
			var(spec[nothing ], float3, param_26_642 ) = vb;
			var(spec[nothing ], int, param_27_642 ) = ec;
			var(spec[nothing ], float3, _1033_642 ) = px(param_17_642, param_18_642, param_19_642, param_20_642, param_21_642, param_22_642, param_23_642, param_24_642, param_25_642, param_26_642, param_27_642 );
			oc = param_22_642;
			oa = param_23_642;
			io = param_24_642;
			ss = param_25_642;
			vb = param_26_642;
			ec = param_27_642;
			var(spec[nothing ], float3, cc_642 ) = _1033_642;
			fc += (float4(cc_642 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 6;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_651 ) = ro;
			var(spec[nothing ], float3, param_1_651 ) = rd;
			var(spec[nothing ], float3, param_2_651 ) = oc;
			var(spec[nothing ], float, param_3_651 ) = oa;
			var(spec[nothing ], float, param_4_651 ) = cd;
			var(spec[nothing ], float, param_5_651 ) = td;
			var(spec[nothing ], float, param_6_651 ) = io;
			var(spec[nothing ], float3, param_7_651 ) = ss;
			var(spec[nothing ], float3, param_8_651 ) = vb;
			var(spec[nothing ], int, param_9_651 ) = ec;
			tr(param_651, param_1_651, param_2_651, param_3_651, param_4_651, param_5_651, param_6_651, param_7_651, param_8_651, param_9_651 );
			oc = param_2_651;
			oa = param_3_651;
			cd = param_4_651;
			td = param_5_651;
			io = param_6_651;
			ss = param_7_651;
			vb = param_8_651;
			ec = param_9_651;
			var(spec[nothing ], float3, cp_651 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_651 ) = cp_651;
			var(spec[nothing ], float3, param_11_651 ) = oc;
			var(spec[nothing ], float, param_12_651 ) = oa;
			var(spec[nothing ], float, param_13_651 ) = io;
			var(spec[nothing ], float3, param_14_651 ) = ss;
			var(spec[nothing ], float3, param_15_651 ) = vb;
			var(spec[nothing ], int, param_16_651 ) = ec;
			var(spec[nothing ], float3, _940_651 ) = nm(param_10_651, param_11_651, param_12_651, param_13_651, param_14_651, param_15_651, param_16_651 );
			oc = param_11_651;
			oa = param_12_651;
			io = param_13_651;
			ss = param_14_651;
			vb = param_15_651;
			ec = param_16_651;
			var(spec[nothing ], float3, cn_651 ) = _940_651;
			ro = cp_651 - (cn_651 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_651 ) = refract(rd, cn_651, _958 );
			if((length(cr_651 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_651 = reflect(rd, cn_651 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_651;
			};
			es -- ;
			var(spec[nothing ], bool, _993_651 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_651 );
			if(_993_651 )
			{
				_999_651 = false;
			}
			else
			{
				_999_651 = _993_651;
			};
			if(_999_651 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_651 ) = rd;
			var(spec[nothing ], float3, param_18_651 ) = cp_651;
			var(spec[nothing ], float3, param_19_651 ) = cr_651;
			var(spec[nothing ], float3, param_20_651 ) = cn_651;
			var(spec[nothing ], float, param_21_651 ) = cd;
			var(spec[nothing ], float3, param_22_651 ) = oc;
			var(spec[nothing ], float, param_23_651 ) = oa;
			var(spec[nothing ], float, param_24_651 ) = io;
			var(spec[nothing ], float3, param_25_651 ) = ss;
			var(spec[nothing ], float3, param_26_651 ) = vb;
			var(spec[nothing ], int, param_27_651 ) = ec;
			var(spec[nothing ], float3, _1033_651 ) = px(param_17_651, param_18_651, param_19_651, param_20_651, param_21_651, param_22_651, param_23_651, param_24_651, param_25_651, param_26_651, param_27_651 );
			oc = param_22_651;
			oa = param_23_651;
			io = param_24_651;
			ss = param_25_651;
			vb = param_26_651;
			ec = param_27_651;
			var(spec[nothing ], float3, cc_651 ) = _1033_651;
			fc += (float4(cc_651 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 7;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_660 ) = ro;
			var(spec[nothing ], float3, param_1_660 ) = rd;
			var(spec[nothing ], float3, param_2_660 ) = oc;
			var(spec[nothing ], float, param_3_660 ) = oa;
			var(spec[nothing ], float, param_4_660 ) = cd;
			var(spec[nothing ], float, param_5_660 ) = td;
			var(spec[nothing ], float, param_6_660 ) = io;
			var(spec[nothing ], float3, param_7_660 ) = ss;
			var(spec[nothing ], float3, param_8_660 ) = vb;
			var(spec[nothing ], int, param_9_660 ) = ec;
			tr(param_660, param_1_660, param_2_660, param_3_660, param_4_660, param_5_660, param_6_660, param_7_660, param_8_660, param_9_660 );
			oc = param_2_660;
			oa = param_3_660;
			cd = param_4_660;
			td = param_5_660;
			io = param_6_660;
			ss = param_7_660;
			vb = param_8_660;
			ec = param_9_660;
			var(spec[nothing ], float3, cp_660 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_660 ) = cp_660;
			var(spec[nothing ], float3, param_11_660 ) = oc;
			var(spec[nothing ], float, param_12_660 ) = oa;
			var(spec[nothing ], float, param_13_660 ) = io;
			var(spec[nothing ], float3, param_14_660 ) = ss;
			var(spec[nothing ], float3, param_15_660 ) = vb;
			var(spec[nothing ], int, param_16_660 ) = ec;
			var(spec[nothing ], float3, _940_660 ) = nm(param_10_660, param_11_660, param_12_660, param_13_660, param_14_660, param_15_660, param_16_660 );
			oc = param_11_660;
			oa = param_12_660;
			io = param_13_660;
			ss = param_14_660;
			vb = param_15_660;
			ec = param_16_660;
			var(spec[nothing ], float3, cn_660 ) = _940_660;
			ro = cp_660 - (cn_660 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_660 ) = refract(rd, cn_660, _958 );
			if((length(cr_660 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_660 = reflect(rd, cn_660 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_660;
			};
			es -- ;
			var(spec[nothing ], bool, _993_660 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_660 );
			if(_993_660 )
			{
				_999_660 = true;
			}
			else
			{
				_999_660 = _993_660;
			};
			if(_999_660 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_660 ) = rd;
			var(spec[nothing ], float3, param_18_660 ) = cp_660;
			var(spec[nothing ], float3, param_19_660 ) = cr_660;
			var(spec[nothing ], float3, param_20_660 ) = cn_660;
			var(spec[nothing ], float, param_21_660 ) = cd;
			var(spec[nothing ], float3, param_22_660 ) = oc;
			var(spec[nothing ], float, param_23_660 ) = oa;
			var(spec[nothing ], float, param_24_660 ) = io;
			var(spec[nothing ], float3, param_25_660 ) = ss;
			var(spec[nothing ], float3, param_26_660 ) = vb;
			var(spec[nothing ], int, param_27_660 ) = ec;
			var(spec[nothing ], float3, _1033_660 ) = px(param_17_660, param_18_660, param_19_660, param_20_660, param_21_660, param_22_660, param_23_660, param_24_660, param_25_660, param_26_660, param_27_660 );
			oc = param_22_660;
			oa = param_23_660;
			io = param_24_660;
			ss = param_25_660;
			vb = param_26_660;
			ec = param_27_660;
			var(spec[nothing ], float3, cc_660 ) = _1033_660;
			fc += (float4(cc_660 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 8;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_669 ) = ro;
			var(spec[nothing ], float3, param_1_669 ) = rd;
			var(spec[nothing ], float3, param_2_669 ) = oc;
			var(spec[nothing ], float, param_3_669 ) = oa;
			var(spec[nothing ], float, param_4_669 ) = cd;
			var(spec[nothing ], float, param_5_669 ) = td;
			var(spec[nothing ], float, param_6_669 ) = io;
			var(spec[nothing ], float3, param_7_669 ) = ss;
			var(spec[nothing ], float3, param_8_669 ) = vb;
			var(spec[nothing ], int, param_9_669 ) = ec;
			tr(param_669, param_1_669, param_2_669, param_3_669, param_4_669, param_5_669, param_6_669, param_7_669, param_8_669, param_9_669 );
			oc = param_2_669;
			oa = param_3_669;
			cd = param_4_669;
			td = param_5_669;
			io = param_6_669;
			ss = param_7_669;
			vb = param_8_669;
			ec = param_9_669;
			var(spec[nothing ], float3, cp_669 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_669 ) = cp_669;
			var(spec[nothing ], float3, param_11_669 ) = oc;
			var(spec[nothing ], float, param_12_669 ) = oa;
			var(spec[nothing ], float, param_13_669 ) = io;
			var(spec[nothing ], float3, param_14_669 ) = ss;
			var(spec[nothing ], float3, param_15_669 ) = vb;
			var(spec[nothing ], int, param_16_669 ) = ec;
			var(spec[nothing ], float3, _940_669 ) = nm(param_10_669, param_11_669, param_12_669, param_13_669, param_14_669, param_15_669, param_16_669 );
			oc = param_11_669;
			oa = param_12_669;
			io = param_13_669;
			ss = param_14_669;
			vb = param_15_669;
			ec = param_16_669;
			var(spec[nothing ], float3, cn_669 ) = _940_669;
			ro = cp_669 - (cn_669 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_669 ) = refract(rd, cn_669, _958 );
			if((length(cr_669 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_669 = reflect(rd, cn_669 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_669;
			};
			es -- ;
			var(spec[nothing ], bool, _993_669 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_669 );
			if(_993_669 )
			{
				_999_669 = false;
			}
			else
			{
				_999_669 = _993_669;
			};
			if(_999_669 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_669 ) = rd;
			var(spec[nothing ], float3, param_18_669 ) = cp_669;
			var(spec[nothing ], float3, param_19_669 ) = cr_669;
			var(spec[nothing ], float3, param_20_669 ) = cn_669;
			var(spec[nothing ], float, param_21_669 ) = cd;
			var(spec[nothing ], float3, param_22_669 ) = oc;
			var(spec[nothing ], float, param_23_669 ) = oa;
			var(spec[nothing ], float, param_24_669 ) = io;
			var(spec[nothing ], float3, param_25_669 ) = ss;
			var(spec[nothing ], float3, param_26_669 ) = vb;
			var(spec[nothing ], int, param_27_669 ) = ec;
			var(spec[nothing ], float3, _1033_669 ) = px(param_17_669, param_18_669, param_19_669, param_20_669, param_21_669, param_22_669, param_23_669, param_24_669, param_25_669, param_26_669, param_27_669 );
			oc = param_22_669;
			oa = param_23_669;
			io = param_24_669;
			ss = param_25_669;
			vb = param_26_669;
			ec = param_27_669;
			var(spec[nothing ], float3, cc_669 ) = _1033_669;
			fc += (float4(cc_669 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 9;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_678 ) = ro;
			var(spec[nothing ], float3, param_1_678 ) = rd;
			var(spec[nothing ], float3, param_2_678 ) = oc;
			var(spec[nothing ], float, param_3_678 ) = oa;
			var(spec[nothing ], float, param_4_678 ) = cd;
			var(spec[nothing ], float, param_5_678 ) = td;
			var(spec[nothing ], float, param_6_678 ) = io;
			var(spec[nothing ], float3, param_7_678 ) = ss;
			var(spec[nothing ], float3, param_8_678 ) = vb;
			var(spec[nothing ], int, param_9_678 ) = ec;
			tr(param_678, param_1_678, param_2_678, param_3_678, param_4_678, param_5_678, param_6_678, param_7_678, param_8_678, param_9_678 );
			oc = param_2_678;
			oa = param_3_678;
			cd = param_4_678;
			td = param_5_678;
			io = param_6_678;
			ss = param_7_678;
			vb = param_8_678;
			ec = param_9_678;
			var(spec[nothing ], float3, cp_678 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_678 ) = cp_678;
			var(spec[nothing ], float3, param_11_678 ) = oc;
			var(spec[nothing ], float, param_12_678 ) = oa;
			var(spec[nothing ], float, param_13_678 ) = io;
			var(spec[nothing ], float3, param_14_678 ) = ss;
			var(spec[nothing ], float3, param_15_678 ) = vb;
			var(spec[nothing ], int, param_16_678 ) = ec;
			var(spec[nothing ], float3, _940_678 ) = nm(param_10_678, param_11_678, param_12_678, param_13_678, param_14_678, param_15_678, param_16_678 );
			oc = param_11_678;
			oa = param_12_678;
			io = param_13_678;
			ss = param_14_678;
			vb = param_15_678;
			ec = param_16_678;
			var(spec[nothing ], float3, cn_678 ) = _940_678;
			ro = cp_678 - (cn_678 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_678 ) = refract(rd, cn_678, _958 );
			if((length(cr_678 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_678 = reflect(rd, cn_678 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_678;
			};
			es -- ;
			var(spec[nothing ], bool, _993_678 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_678 );
			if(_993_678 )
			{
				_999_678 = true;
			}
			else
			{
				_999_678 = _993_678;
			};
			if(_999_678 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_678 ) = rd;
			var(spec[nothing ], float3, param_18_678 ) = cp_678;
			var(spec[nothing ], float3, param_19_678 ) = cr_678;
			var(spec[nothing ], float3, param_20_678 ) = cn_678;
			var(spec[nothing ], float, param_21_678 ) = cd;
			var(spec[nothing ], float3, param_22_678 ) = oc;
			var(spec[nothing ], float, param_23_678 ) = oa;
			var(spec[nothing ], float, param_24_678 ) = io;
			var(spec[nothing ], float3, param_25_678 ) = ss;
			var(spec[nothing ], float3, param_26_678 ) = vb;
			var(spec[nothing ], int, param_27_678 ) = ec;
			var(spec[nothing ], float3, _1033_678 ) = px(param_17_678, param_18_678, param_19_678, param_20_678, param_21_678, param_22_678, param_23_678, param_24_678, param_25_678, param_26_678, param_27_678 );
			oc = param_22_678;
			oa = param_23_678;
			io = param_24_678;
			ss = param_25_678;
			vb = param_26_678;
			ec = param_27_678;
			var(spec[nothing ], float3, cc_678 ) = _1033_678;
			fc += (float4(cc_678 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 10;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_687 ) = ro;
			var(spec[nothing ], float3, param_1_687 ) = rd;
			var(spec[nothing ], float3, param_2_687 ) = oc;
			var(spec[nothing ], float, param_3_687 ) = oa;
			var(spec[nothing ], float, param_4_687 ) = cd;
			var(spec[nothing ], float, param_5_687 ) = td;
			var(spec[nothing ], float, param_6_687 ) = io;
			var(spec[nothing ], float3, param_7_687 ) = ss;
			var(spec[nothing ], float3, param_8_687 ) = vb;
			var(spec[nothing ], int, param_9_687 ) = ec;
			tr(param_687, param_1_687, param_2_687, param_3_687, param_4_687, param_5_687, param_6_687, param_7_687, param_8_687, param_9_687 );
			oc = param_2_687;
			oa = param_3_687;
			cd = param_4_687;
			td = param_5_687;
			io = param_6_687;
			ss = param_7_687;
			vb = param_8_687;
			ec = param_9_687;
			var(spec[nothing ], float3, cp_687 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_687 ) = cp_687;
			var(spec[nothing ], float3, param_11_687 ) = oc;
			var(spec[nothing ], float, param_12_687 ) = oa;
			var(spec[nothing ], float, param_13_687 ) = io;
			var(spec[nothing ], float3, param_14_687 ) = ss;
			var(spec[nothing ], float3, param_15_687 ) = vb;
			var(spec[nothing ], int, param_16_687 ) = ec;
			var(spec[nothing ], float3, _940_687 ) = nm(param_10_687, param_11_687, param_12_687, param_13_687, param_14_687, param_15_687, param_16_687 );
			oc = param_11_687;
			oa = param_12_687;
			io = param_13_687;
			ss = param_14_687;
			vb = param_15_687;
			ec = param_16_687;
			var(spec[nothing ], float3, cn_687 ) = _940_687;
			ro = cp_687 - (cn_687 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_687 ) = refract(rd, cn_687, _958 );
			if((length(cr_687 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_687 = reflect(rd, cn_687 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_687;
			};
			es -- ;
			var(spec[nothing ], bool, _993_687 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_687 );
			if(_993_687 )
			{
				_999_687 = false;
			}
			else
			{
				_999_687 = _993_687;
			};
			if(_999_687 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_687 ) = rd;
			var(spec[nothing ], float3, param_18_687 ) = cp_687;
			var(spec[nothing ], float3, param_19_687 ) = cr_687;
			var(spec[nothing ], float3, param_20_687 ) = cn_687;
			var(spec[nothing ], float, param_21_687 ) = cd;
			var(spec[nothing ], float3, param_22_687 ) = oc;
			var(spec[nothing ], float, param_23_687 ) = oa;
			var(spec[nothing ], float, param_24_687 ) = io;
			var(spec[nothing ], float3, param_25_687 ) = ss;
			var(spec[nothing ], float3, param_26_687 ) = vb;
			var(spec[nothing ], int, param_27_687 ) = ec;
			var(spec[nothing ], float3, _1033_687 ) = px(param_17_687, param_18_687, param_19_687, param_20_687, param_21_687, param_22_687, param_23_687, param_24_687, param_25_687, param_26_687, param_27_687 );
			oc = param_22_687;
			oa = param_23_687;
			io = param_24_687;
			ss = param_25_687;
			vb = param_26_687;
			ec = param_27_687;
			var(spec[nothing ], float3, cc_687 ) = _1033_687;
			fc += (float4(cc_687 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 11;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_696 ) = ro;
			var(spec[nothing ], float3, param_1_696 ) = rd;
			var(spec[nothing ], float3, param_2_696 ) = oc;
			var(spec[nothing ], float, param_3_696 ) = oa;
			var(spec[nothing ], float, param_4_696 ) = cd;
			var(spec[nothing ], float, param_5_696 ) = td;
			var(spec[nothing ], float, param_6_696 ) = io;
			var(spec[nothing ], float3, param_7_696 ) = ss;
			var(spec[nothing ], float3, param_8_696 ) = vb;
			var(spec[nothing ], int, param_9_696 ) = ec;
			tr(param_696, param_1_696, param_2_696, param_3_696, param_4_696, param_5_696, param_6_696, param_7_696, param_8_696, param_9_696 );
			oc = param_2_696;
			oa = param_3_696;
			cd = param_4_696;
			td = param_5_696;
			io = param_6_696;
			ss = param_7_696;
			vb = param_8_696;
			ec = param_9_696;
			var(spec[nothing ], float3, cp_696 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_696 ) = cp_696;
			var(spec[nothing ], float3, param_11_696 ) = oc;
			var(spec[nothing ], float, param_12_696 ) = oa;
			var(spec[nothing ], float, param_13_696 ) = io;
			var(spec[nothing ], float3, param_14_696 ) = ss;
			var(spec[nothing ], float3, param_15_696 ) = vb;
			var(spec[nothing ], int, param_16_696 ) = ec;
			var(spec[nothing ], float3, _940_696 ) = nm(param_10_696, param_11_696, param_12_696, param_13_696, param_14_696, param_15_696, param_16_696 );
			oc = param_11_696;
			oa = param_12_696;
			io = param_13_696;
			ss = param_14_696;
			vb = param_15_696;
			ec = param_16_696;
			var(spec[nothing ], float3, cn_696 ) = _940_696;
			ro = cp_696 - (cn_696 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_696 ) = refract(rd, cn_696, _958 );
			if((length(cr_696 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_696 = reflect(rd, cn_696 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_696;
			};
			es -- ;
			var(spec[nothing ], bool, _993_696 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_696 );
			if(_993_696 )
			{
				_999_696 = true;
			}
			else
			{
				_999_696 = _993_696;
			};
			if(_999_696 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_696 ) = rd;
			var(spec[nothing ], float3, param_18_696 ) = cp_696;
			var(spec[nothing ], float3, param_19_696 ) = cr_696;
			var(spec[nothing ], float3, param_20_696 ) = cn_696;
			var(spec[nothing ], float, param_21_696 ) = cd;
			var(spec[nothing ], float3, param_22_696 ) = oc;
			var(spec[nothing ], float, param_23_696 ) = oa;
			var(spec[nothing ], float, param_24_696 ) = io;
			var(spec[nothing ], float3, param_25_696 ) = ss;
			var(spec[nothing ], float3, param_26_696 ) = vb;
			var(spec[nothing ], int, param_27_696 ) = ec;
			var(spec[nothing ], float3, _1033_696 ) = px(param_17_696, param_18_696, param_19_696, param_20_696, param_21_696, param_22_696, param_23_696, param_24_696, param_25_696, param_26_696, param_27_696 );
			oc = param_22_696;
			oa = param_23_696;
			io = param_24_696;
			ss = param_25_696;
			vb = param_26_696;
			ec = param_27_696;
			var(spec[nothing ], float3, cc_696 ) = _1033_696;
			fc += (float4(cc_696 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 12;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_705 ) = ro;
			var(spec[nothing ], float3, param_1_705 ) = rd;
			var(spec[nothing ], float3, param_2_705 ) = oc;
			var(spec[nothing ], float, param_3_705 ) = oa;
			var(spec[nothing ], float, param_4_705 ) = cd;
			var(spec[nothing ], float, param_5_705 ) = td;
			var(spec[nothing ], float, param_6_705 ) = io;
			var(spec[nothing ], float3, param_7_705 ) = ss;
			var(spec[nothing ], float3, param_8_705 ) = vb;
			var(spec[nothing ], int, param_9_705 ) = ec;
			tr(param_705, param_1_705, param_2_705, param_3_705, param_4_705, param_5_705, param_6_705, param_7_705, param_8_705, param_9_705 );
			oc = param_2_705;
			oa = param_3_705;
			cd = param_4_705;
			td = param_5_705;
			io = param_6_705;
			ss = param_7_705;
			vb = param_8_705;
			ec = param_9_705;
			var(spec[nothing ], float3, cp_705 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_705 ) = cp_705;
			var(spec[nothing ], float3, param_11_705 ) = oc;
			var(spec[nothing ], float, param_12_705 ) = oa;
			var(spec[nothing ], float, param_13_705 ) = io;
			var(spec[nothing ], float3, param_14_705 ) = ss;
			var(spec[nothing ], float3, param_15_705 ) = vb;
			var(spec[nothing ], int, param_16_705 ) = ec;
			var(spec[nothing ], float3, _940_705 ) = nm(param_10_705, param_11_705, param_12_705, param_13_705, param_14_705, param_15_705, param_16_705 );
			oc = param_11_705;
			oa = param_12_705;
			io = param_13_705;
			ss = param_14_705;
			vb = param_15_705;
			ec = param_16_705;
			var(spec[nothing ], float3, cn_705 ) = _940_705;
			ro = cp_705 - (cn_705 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_705 ) = refract(rd, cn_705, _958 );
			if((length(cr_705 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_705 = reflect(rd, cn_705 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_705;
			};
			es -- ;
			var(spec[nothing ], bool, _993_705 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_705 );
			if(_993_705 )
			{
				_999_705 = false;
			}
			else
			{
				_999_705 = _993_705;
			};
			if(_999_705 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_705 ) = rd;
			var(spec[nothing ], float3, param_18_705 ) = cp_705;
			var(spec[nothing ], float3, param_19_705 ) = cr_705;
			var(spec[nothing ], float3, param_20_705 ) = cn_705;
			var(spec[nothing ], float, param_21_705 ) = cd;
			var(spec[nothing ], float3, param_22_705 ) = oc;
			var(spec[nothing ], float, param_23_705 ) = oa;
			var(spec[nothing ], float, param_24_705 ) = io;
			var(spec[nothing ], float3, param_25_705 ) = ss;
			var(spec[nothing ], float3, param_26_705 ) = vb;
			var(spec[nothing ], int, param_27_705 ) = ec;
			var(spec[nothing ], float3, _1033_705 ) = px(param_17_705, param_18_705, param_19_705, param_20_705, param_21_705, param_22_705, param_23_705, param_24_705, param_25_705, param_26_705, param_27_705 );
			oc = param_22_705;
			oa = param_23_705;
			io = param_24_705;
			ss = param_25_705;
			vb = param_26_705;
			ec = param_27_705;
			var(spec[nothing ], float3, cc_705 ) = _1033_705;
			fc += (float4(cc_705 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 13;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_714 ) = ro;
			var(spec[nothing ], float3, param_1_714 ) = rd;
			var(spec[nothing ], float3, param_2_714 ) = oc;
			var(spec[nothing ], float, param_3_714 ) = oa;
			var(spec[nothing ], float, param_4_714 ) = cd;
			var(spec[nothing ], float, param_5_714 ) = td;
			var(spec[nothing ], float, param_6_714 ) = io;
			var(spec[nothing ], float3, param_7_714 ) = ss;
			var(spec[nothing ], float3, param_8_714 ) = vb;
			var(spec[nothing ], int, param_9_714 ) = ec;
			tr(param_714, param_1_714, param_2_714, param_3_714, param_4_714, param_5_714, param_6_714, param_7_714, param_8_714, param_9_714 );
			oc = param_2_714;
			oa = param_3_714;
			cd = param_4_714;
			td = param_5_714;
			io = param_6_714;
			ss = param_7_714;
			vb = param_8_714;
			ec = param_9_714;
			var(spec[nothing ], float3, cp_714 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_714 ) = cp_714;
			var(spec[nothing ], float3, param_11_714 ) = oc;
			var(spec[nothing ], float, param_12_714 ) = oa;
			var(spec[nothing ], float, param_13_714 ) = io;
			var(spec[nothing ], float3, param_14_714 ) = ss;
			var(spec[nothing ], float3, param_15_714 ) = vb;
			var(spec[nothing ], int, param_16_714 ) = ec;
			var(spec[nothing ], float3, _940_714 ) = nm(param_10_714, param_11_714, param_12_714, param_13_714, param_14_714, param_15_714, param_16_714 );
			oc = param_11_714;
			oa = param_12_714;
			io = param_13_714;
			ss = param_14_714;
			vb = param_15_714;
			ec = param_16_714;
			var(spec[nothing ], float3, cn_714 ) = _940_714;
			ro = cp_714 - (cn_714 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_714 ) = refract(rd, cn_714, _958 );
			if((length(cr_714 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_714 = reflect(rd, cn_714 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_714;
			};
			es -- ;
			var(spec[nothing ], bool, _993_714 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_714 );
			if(_993_714 )
			{
				_999_714 = true;
			}
			else
			{
				_999_714 = _993_714;
			};
			if(_999_714 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_714 ) = rd;
			var(spec[nothing ], float3, param_18_714 ) = cp_714;
			var(spec[nothing ], float3, param_19_714 ) = cr_714;
			var(spec[nothing ], float3, param_20_714 ) = cn_714;
			var(spec[nothing ], float, param_21_714 ) = cd;
			var(spec[nothing ], float3, param_22_714 ) = oc;
			var(spec[nothing ], float, param_23_714 ) = oa;
			var(spec[nothing ], float, param_24_714 ) = io;
			var(spec[nothing ], float3, param_25_714 ) = ss;
			var(spec[nothing ], float3, param_26_714 ) = vb;
			var(spec[nothing ], int, param_27_714 ) = ec;
			var(spec[nothing ], float3, _1033_714 ) = px(param_17_714, param_18_714, param_19_714, param_20_714, param_21_714, param_22_714, param_23_714, param_24_714, param_25_714, param_26_714, param_27_714 );
			oc = param_22_714;
			oa = param_23_714;
			io = param_24_714;
			ss = param_25_714;
			vb = param_26_714;
			ec = param_27_714;
			var(spec[nothing ], float3, cc_714 ) = _1033_714;
			fc += (float4(cc_714 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 14;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_723 ) = ro;
			var(spec[nothing ], float3, param_1_723 ) = rd;
			var(spec[nothing ], float3, param_2_723 ) = oc;
			var(spec[nothing ], float, param_3_723 ) = oa;
			var(spec[nothing ], float, param_4_723 ) = cd;
			var(spec[nothing ], float, param_5_723 ) = td;
			var(spec[nothing ], float, param_6_723 ) = io;
			var(spec[nothing ], float3, param_7_723 ) = ss;
			var(spec[nothing ], float3, param_8_723 ) = vb;
			var(spec[nothing ], int, param_9_723 ) = ec;
			tr(param_723, param_1_723, param_2_723, param_3_723, param_4_723, param_5_723, param_6_723, param_7_723, param_8_723, param_9_723 );
			oc = param_2_723;
			oa = param_3_723;
			cd = param_4_723;
			td = param_5_723;
			io = param_6_723;
			ss = param_7_723;
			vb = param_8_723;
			ec = param_9_723;
			var(spec[nothing ], float3, cp_723 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_723 ) = cp_723;
			var(spec[nothing ], float3, param_11_723 ) = oc;
			var(spec[nothing ], float, param_12_723 ) = oa;
			var(spec[nothing ], float, param_13_723 ) = io;
			var(spec[nothing ], float3, param_14_723 ) = ss;
			var(spec[nothing ], float3, param_15_723 ) = vb;
			var(spec[nothing ], int, param_16_723 ) = ec;
			var(spec[nothing ], float3, _940_723 ) = nm(param_10_723, param_11_723, param_12_723, param_13_723, param_14_723, param_15_723, param_16_723 );
			oc = param_11_723;
			oa = param_12_723;
			io = param_13_723;
			ss = param_14_723;
			vb = param_15_723;
			ec = param_16_723;
			var(spec[nothing ], float3, cn_723 ) = _940_723;
			ro = cp_723 - (cn_723 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_723 ) = refract(rd, cn_723, _958 );
			if((length(cr_723 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_723 = reflect(rd, cn_723 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_723;
			};
			es -- ;
			var(spec[nothing ], bool, _993_723 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_723 );
			if(_993_723 )
			{
				_999_723 = false;
			}
			else
			{
				_999_723 = _993_723;
			};
			if(_999_723 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_723 ) = rd;
			var(spec[nothing ], float3, param_18_723 ) = cp_723;
			var(spec[nothing ], float3, param_19_723 ) = cr_723;
			var(spec[nothing ], float3, param_20_723 ) = cn_723;
			var(spec[nothing ], float, param_21_723 ) = cd;
			var(spec[nothing ], float3, param_22_723 ) = oc;
			var(spec[nothing ], float, param_23_723 ) = oa;
			var(spec[nothing ], float, param_24_723 ) = io;
			var(spec[nothing ], float3, param_25_723 ) = ss;
			var(spec[nothing ], float3, param_26_723 ) = vb;
			var(spec[nothing ], int, param_27_723 ) = ec;
			var(spec[nothing ], float3, _1033_723 ) = px(param_17_723, param_18_723, param_19_723, param_20_723, param_21_723, param_22_723, param_23_723, param_24_723, param_25_723, param_26_723, param_27_723 );
			oc = param_22_723;
			oa = param_23_723;
			io = param_24_723;
			ss = param_25_723;
			vb = param_26_723;
			ec = param_27_723;
			var(spec[nothing ], float3, cc_723 ) = _1033_723;
			fc += (float4(cc_723 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 15;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_732 ) = ro;
			var(spec[nothing ], float3, param_1_732 ) = rd;
			var(spec[nothing ], float3, param_2_732 ) = oc;
			var(spec[nothing ], float, param_3_732 ) = oa;
			var(spec[nothing ], float, param_4_732 ) = cd;
			var(spec[nothing ], float, param_5_732 ) = td;
			var(spec[nothing ], float, param_6_732 ) = io;
			var(spec[nothing ], float3, param_7_732 ) = ss;
			var(spec[nothing ], float3, param_8_732 ) = vb;
			var(spec[nothing ], int, param_9_732 ) = ec;
			tr(param_732, param_1_732, param_2_732, param_3_732, param_4_732, param_5_732, param_6_732, param_7_732, param_8_732, param_9_732 );
			oc = param_2_732;
			oa = param_3_732;
			cd = param_4_732;
			td = param_5_732;
			io = param_6_732;
			ss = param_7_732;
			vb = param_8_732;
			ec = param_9_732;
			var(spec[nothing ], float3, cp_732 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_732 ) = cp_732;
			var(spec[nothing ], float3, param_11_732 ) = oc;
			var(spec[nothing ], float, param_12_732 ) = oa;
			var(spec[nothing ], float, param_13_732 ) = io;
			var(spec[nothing ], float3, param_14_732 ) = ss;
			var(spec[nothing ], float3, param_15_732 ) = vb;
			var(spec[nothing ], int, param_16_732 ) = ec;
			var(spec[nothing ], float3, _940_732 ) = nm(param_10_732, param_11_732, param_12_732, param_13_732, param_14_732, param_15_732, param_16_732 );
			oc = param_11_732;
			oa = param_12_732;
			io = param_13_732;
			ss = param_14_732;
			vb = param_15_732;
			ec = param_16_732;
			var(spec[nothing ], float3, cn_732 ) = _940_732;
			ro = cp_732 - (cn_732 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_732 ) = refract(rd, cn_732, _958 );
			if((length(cr_732 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_732 = reflect(rd, cn_732 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_732;
			};
			es -- ;
			var(spec[nothing ], bool, _993_732 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_732 );
			if(_993_732 )
			{
				_999_732 = true;
			}
			else
			{
				_999_732 = _993_732;
			};
			if(_999_732 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_732 ) = rd;
			var(spec[nothing ], float3, param_18_732 ) = cp_732;
			var(spec[nothing ], float3, param_19_732 ) = cr_732;
			var(spec[nothing ], float3, param_20_732 ) = cn_732;
			var(spec[nothing ], float, param_21_732 ) = cd;
			var(spec[nothing ], float3, param_22_732 ) = oc;
			var(spec[nothing ], float, param_23_732 ) = oa;
			var(spec[nothing ], float, param_24_732 ) = io;
			var(spec[nothing ], float3, param_25_732 ) = ss;
			var(spec[nothing ], float3, param_26_732 ) = vb;
			var(spec[nothing ], int, param_27_732 ) = ec;
			var(spec[nothing ], float3, _1033_732 ) = px(param_17_732, param_18_732, param_19_732, param_20_732, param_21_732, param_22_732, param_23_732, param_24_732, param_25_732, param_26_732, param_27_732 );
			oc = param_22_732;
			oa = param_23_732;
			io = param_24_732;
			ss = param_25_732;
			vb = param_26_732;
			ec = param_27_732;
			var(spec[nothing ], float3, cc_732 ) = _1033_732;
			fc += (float4(cc_732 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 16;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_741 ) = ro;
			var(spec[nothing ], float3, param_1_741 ) = rd;
			var(spec[nothing ], float3, param_2_741 ) = oc;
			var(spec[nothing ], float, param_3_741 ) = oa;
			var(spec[nothing ], float, param_4_741 ) = cd;
			var(spec[nothing ], float, param_5_741 ) = td;
			var(spec[nothing ], float, param_6_741 ) = io;
			var(spec[nothing ], float3, param_7_741 ) = ss;
			var(spec[nothing ], float3, param_8_741 ) = vb;
			var(spec[nothing ], int, param_9_741 ) = ec;
			tr(param_741, param_1_741, param_2_741, param_3_741, param_4_741, param_5_741, param_6_741, param_7_741, param_8_741, param_9_741 );
			oc = param_2_741;
			oa = param_3_741;
			cd = param_4_741;
			td = param_5_741;
			io = param_6_741;
			ss = param_7_741;
			vb = param_8_741;
			ec = param_9_741;
			var(spec[nothing ], float3, cp_741 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_741 ) = cp_741;
			var(spec[nothing ], float3, param_11_741 ) = oc;
			var(spec[nothing ], float, param_12_741 ) = oa;
			var(spec[nothing ], float, param_13_741 ) = io;
			var(spec[nothing ], float3, param_14_741 ) = ss;
			var(spec[nothing ], float3, param_15_741 ) = vb;
			var(spec[nothing ], int, param_16_741 ) = ec;
			var(spec[nothing ], float3, _940_741 ) = nm(param_10_741, param_11_741, param_12_741, param_13_741, param_14_741, param_15_741, param_16_741 );
			oc = param_11_741;
			oa = param_12_741;
			io = param_13_741;
			ss = param_14_741;
			vb = param_15_741;
			ec = param_16_741;
			var(spec[nothing ], float3, cn_741 ) = _940_741;
			ro = cp_741 - (cn_741 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_741 ) = refract(rd, cn_741, _958 );
			if((length(cr_741 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_741 = reflect(rd, cn_741 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_741;
			};
			es -- ;
			var(spec[nothing ], bool, _993_741 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_741 );
			if(_993_741 )
			{
				_999_741 = false;
			}
			else
			{
				_999_741 = _993_741;
			};
			if(_999_741 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_741 ) = rd;
			var(spec[nothing ], float3, param_18_741 ) = cp_741;
			var(spec[nothing ], float3, param_19_741 ) = cr_741;
			var(spec[nothing ], float3, param_20_741 ) = cn_741;
			var(spec[nothing ], float, param_21_741 ) = cd;
			var(spec[nothing ], float3, param_22_741 ) = oc;
			var(spec[nothing ], float, param_23_741 ) = oa;
			var(spec[nothing ], float, param_24_741 ) = io;
			var(spec[nothing ], float3, param_25_741 ) = ss;
			var(spec[nothing ], float3, param_26_741 ) = vb;
			var(spec[nothing ], int, param_27_741 ) = ec;
			var(spec[nothing ], float3, _1033_741 ) = px(param_17_741, param_18_741, param_19_741, param_20_741, param_21_741, param_22_741, param_23_741, param_24_741, param_25_741, param_26_741, param_27_741 );
			oc = param_22_741;
			oa = param_23_741;
			io = param_24_741;
			ss = param_25_741;
			vb = param_26_741;
			ec = param_27_741;
			var(spec[nothing ], float3, cc_741 ) = _1033_741;
			fc += (float4(cc_741 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 17;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_750 ) = ro;
			var(spec[nothing ], float3, param_1_750 ) = rd;
			var(spec[nothing ], float3, param_2_750 ) = oc;
			var(spec[nothing ], float, param_3_750 ) = oa;
			var(spec[nothing ], float, param_4_750 ) = cd;
			var(spec[nothing ], float, param_5_750 ) = td;
			var(spec[nothing ], float, param_6_750 ) = io;
			var(spec[nothing ], float3, param_7_750 ) = ss;
			var(spec[nothing ], float3, param_8_750 ) = vb;
			var(spec[nothing ], int, param_9_750 ) = ec;
			tr(param_750, param_1_750, param_2_750, param_3_750, param_4_750, param_5_750, param_6_750, param_7_750, param_8_750, param_9_750 );
			oc = param_2_750;
			oa = param_3_750;
			cd = param_4_750;
			td = param_5_750;
			io = param_6_750;
			ss = param_7_750;
			vb = param_8_750;
			ec = param_9_750;
			var(spec[nothing ], float3, cp_750 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_750 ) = cp_750;
			var(spec[nothing ], float3, param_11_750 ) = oc;
			var(spec[nothing ], float, param_12_750 ) = oa;
			var(spec[nothing ], float, param_13_750 ) = io;
			var(spec[nothing ], float3, param_14_750 ) = ss;
			var(spec[nothing ], float3, param_15_750 ) = vb;
			var(spec[nothing ], int, param_16_750 ) = ec;
			var(spec[nothing ], float3, _940_750 ) = nm(param_10_750, param_11_750, param_12_750, param_13_750, param_14_750, param_15_750, param_16_750 );
			oc = param_11_750;
			oa = param_12_750;
			io = param_13_750;
			ss = param_14_750;
			vb = param_15_750;
			ec = param_16_750;
			var(spec[nothing ], float3, cn_750 ) = _940_750;
			ro = cp_750 - (cn_750 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_750 ) = refract(rd, cn_750, _958 );
			if((length(cr_750 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_750 = reflect(rd, cn_750 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_750;
			};
			es -- ;
			var(spec[nothing ], bool, _993_750 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_750 );
			if(_993_750 )
			{
				_999_750 = true;
			}
			else
			{
				_999_750 = _993_750;
			};
			if(_999_750 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_750 ) = rd;
			var(spec[nothing ], float3, param_18_750 ) = cp_750;
			var(spec[nothing ], float3, param_19_750 ) = cr_750;
			var(spec[nothing ], float3, param_20_750 ) = cn_750;
			var(spec[nothing ], float, param_21_750 ) = cd;
			var(spec[nothing ], float3, param_22_750 ) = oc;
			var(spec[nothing ], float, param_23_750 ) = oa;
			var(spec[nothing ], float, param_24_750 ) = io;
			var(spec[nothing ], float3, param_25_750 ) = ss;
			var(spec[nothing ], float3, param_26_750 ) = vb;
			var(spec[nothing ], int, param_27_750 ) = ec;
			var(spec[nothing ], float3, _1033_750 ) = px(param_17_750, param_18_750, param_19_750, param_20_750, param_21_750, param_22_750, param_23_750, param_24_750, param_25_750, param_26_750, param_27_750 );
			oc = param_22_750;
			oa = param_23_750;
			io = param_24_750;
			ss = param_25_750;
			vb = param_26_750;
			ec = param_27_750;
			var(spec[nothing ], float3, cc_750 ) = _1033_750;
			fc += (float4(cc_750 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 18;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_759 ) = ro;
			var(spec[nothing ], float3, param_1_759 ) = rd;
			var(spec[nothing ], float3, param_2_759 ) = oc;
			var(spec[nothing ], float, param_3_759 ) = oa;
			var(spec[nothing ], float, param_4_759 ) = cd;
			var(spec[nothing ], float, param_5_759 ) = td;
			var(spec[nothing ], float, param_6_759 ) = io;
			var(spec[nothing ], float3, param_7_759 ) = ss;
			var(spec[nothing ], float3, param_8_759 ) = vb;
			var(spec[nothing ], int, param_9_759 ) = ec;
			tr(param_759, param_1_759, param_2_759, param_3_759, param_4_759, param_5_759, param_6_759, param_7_759, param_8_759, param_9_759 );
			oc = param_2_759;
			oa = param_3_759;
			cd = param_4_759;
			td = param_5_759;
			io = param_6_759;
			ss = param_7_759;
			vb = param_8_759;
			ec = param_9_759;
			var(spec[nothing ], float3, cp_759 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_759 ) = cp_759;
			var(spec[nothing ], float3, param_11_759 ) = oc;
			var(spec[nothing ], float, param_12_759 ) = oa;
			var(spec[nothing ], float, param_13_759 ) = io;
			var(spec[nothing ], float3, param_14_759 ) = ss;
			var(spec[nothing ], float3, param_15_759 ) = vb;
			var(spec[nothing ], int, param_16_759 ) = ec;
			var(spec[nothing ], float3, _940_759 ) = nm(param_10_759, param_11_759, param_12_759, param_13_759, param_14_759, param_15_759, param_16_759 );
			oc = param_11_759;
			oa = param_12_759;
			io = param_13_759;
			ss = param_14_759;
			vb = param_15_759;
			ec = param_16_759;
			var(spec[nothing ], float3, cn_759 ) = _940_759;
			ro = cp_759 - (cn_759 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_759 ) = refract(rd, cn_759, _958 );
			if((length(cr_759 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_759 = reflect(rd, cn_759 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_759;
			};
			es -- ;
			var(spec[nothing ], bool, _993_759 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_759 );
			if(_993_759 )
			{
				_999_759 = false;
			}
			else
			{
				_999_759 = _993_759;
			};
			if(_999_759 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_759 ) = rd;
			var(spec[nothing ], float3, param_18_759 ) = cp_759;
			var(spec[nothing ], float3, param_19_759 ) = cr_759;
			var(spec[nothing ], float3, param_20_759 ) = cn_759;
			var(spec[nothing ], float, param_21_759 ) = cd;
			var(spec[nothing ], float3, param_22_759 ) = oc;
			var(spec[nothing ], float, param_23_759 ) = oa;
			var(spec[nothing ], float, param_24_759 ) = io;
			var(spec[nothing ], float3, param_25_759 ) = ss;
			var(spec[nothing ], float3, param_26_759 ) = vb;
			var(spec[nothing ], int, param_27_759 ) = ec;
			var(spec[nothing ], float3, _1033_759 ) = px(param_17_759, param_18_759, param_19_759, param_20_759, param_21_759, param_22_759, param_23_759, param_24_759, param_25_759, param_26_759, param_27_759 );
			oc = param_22_759;
			oa = param_23_759;
			io = param_24_759;
			ss = param_25_759;
			vb = param_26_759;
			ec = param_27_759;
			var(spec[nothing ], float3, cc_759 ) = _1033_759;
			fc += (float4(cc_759 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 19;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_768 ) = ro;
			var(spec[nothing ], float3, param_1_768 ) = rd;
			var(spec[nothing ], float3, param_2_768 ) = oc;
			var(spec[nothing ], float, param_3_768 ) = oa;
			var(spec[nothing ], float, param_4_768 ) = cd;
			var(spec[nothing ], float, param_5_768 ) = td;
			var(spec[nothing ], float, param_6_768 ) = io;
			var(spec[nothing ], float3, param_7_768 ) = ss;
			var(spec[nothing ], float3, param_8_768 ) = vb;
			var(spec[nothing ], int, param_9_768 ) = ec;
			tr(param_768, param_1_768, param_2_768, param_3_768, param_4_768, param_5_768, param_6_768, param_7_768, param_8_768, param_9_768 );
			oc = param_2_768;
			oa = param_3_768;
			cd = param_4_768;
			td = param_5_768;
			io = param_6_768;
			ss = param_7_768;
			vb = param_8_768;
			ec = param_9_768;
			var(spec[nothing ], float3, cp_768 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_768 ) = cp_768;
			var(spec[nothing ], float3, param_11_768 ) = oc;
			var(spec[nothing ], float, param_12_768 ) = oa;
			var(spec[nothing ], float, param_13_768 ) = io;
			var(spec[nothing ], float3, param_14_768 ) = ss;
			var(spec[nothing ], float3, param_15_768 ) = vb;
			var(spec[nothing ], int, param_16_768 ) = ec;
			var(spec[nothing ], float3, _940_768 ) = nm(param_10_768, param_11_768, param_12_768, param_13_768, param_14_768, param_15_768, param_16_768 );
			oc = param_11_768;
			oa = param_12_768;
			io = param_13_768;
			ss = param_14_768;
			vb = param_15_768;
			ec = param_16_768;
			var(spec[nothing ], float3, cn_768 ) = _940_768;
			ro = cp_768 - (cn_768 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_768 ) = refract(rd, cn_768, _958 );
			if((length(cr_768 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_768 = reflect(rd, cn_768 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_768;
			};
			es -- ;
			var(spec[nothing ], bool, _993_768 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_768 );
			if(_993_768 )
			{
				_999_768 = true;
			}
			else
			{
				_999_768 = _993_768;
			};
			if(_999_768 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_768 ) = rd;
			var(spec[nothing ], float3, param_18_768 ) = cp_768;
			var(spec[nothing ], float3, param_19_768 ) = cr_768;
			var(spec[nothing ], float3, param_20_768 ) = cn_768;
			var(spec[nothing ], float, param_21_768 ) = cd;
			var(spec[nothing ], float3, param_22_768 ) = oc;
			var(spec[nothing ], float, param_23_768 ) = oa;
			var(spec[nothing ], float, param_24_768 ) = io;
			var(spec[nothing ], float3, param_25_768 ) = ss;
			var(spec[nothing ], float3, param_26_768 ) = vb;
			var(spec[nothing ], int, param_27_768 ) = ec;
			var(spec[nothing ], float3, _1033_768 ) = px(param_17_768, param_18_768, param_19_768, param_20_768, param_21_768, param_22_768, param_23_768, param_24_768, param_25_768, param_26_768, param_27_768 );
			oc = param_22_768;
			oa = param_23_768;
			io = param_24_768;
			ss = param_25_768;
			vb = param_26_768;
			ec = param_27_768;
			var(spec[nothing ], float3, cc_768 ) = _1033_768;
			fc += (float4(cc_768 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 20;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_777 ) = ro;
			var(spec[nothing ], float3, param_1_777 ) = rd;
			var(spec[nothing ], float3, param_2_777 ) = oc;
			var(spec[nothing ], float, param_3_777 ) = oa;
			var(spec[nothing ], float, param_4_777 ) = cd;
			var(spec[nothing ], float, param_5_777 ) = td;
			var(spec[nothing ], float, param_6_777 ) = io;
			var(spec[nothing ], float3, param_7_777 ) = ss;
			var(spec[nothing ], float3, param_8_777 ) = vb;
			var(spec[nothing ], int, param_9_777 ) = ec;
			tr(param_777, param_1_777, param_2_777, param_3_777, param_4_777, param_5_777, param_6_777, param_7_777, param_8_777, param_9_777 );
			oc = param_2_777;
			oa = param_3_777;
			cd = param_4_777;
			td = param_5_777;
			io = param_6_777;
			ss = param_7_777;
			vb = param_8_777;
			ec = param_9_777;
			var(spec[nothing ], float3, cp_777 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_777 ) = cp_777;
			var(spec[nothing ], float3, param_11_777 ) = oc;
			var(spec[nothing ], float, param_12_777 ) = oa;
			var(spec[nothing ], float, param_13_777 ) = io;
			var(spec[nothing ], float3, param_14_777 ) = ss;
			var(spec[nothing ], float3, param_15_777 ) = vb;
			var(spec[nothing ], int, param_16_777 ) = ec;
			var(spec[nothing ], float3, _940_777 ) = nm(param_10_777, param_11_777, param_12_777, param_13_777, param_14_777, param_15_777, param_16_777 );
			oc = param_11_777;
			oa = param_12_777;
			io = param_13_777;
			ss = param_14_777;
			vb = param_15_777;
			ec = param_16_777;
			var(spec[nothing ], float3, cn_777 ) = _940_777;
			ro = cp_777 - (cn_777 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_777 ) = refract(rd, cn_777, _958 );
			if((length(cr_777 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_777 = reflect(rd, cn_777 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_777;
			};
			es -- ;
			var(spec[nothing ], bool, _993_777 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_777 );
			if(_993_777 )
			{
				_999_777 = false;
			}
			else
			{
				_999_777 = _993_777;
			};
			if(_999_777 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_777 ) = rd;
			var(spec[nothing ], float3, param_18_777 ) = cp_777;
			var(spec[nothing ], float3, param_19_777 ) = cr_777;
			var(spec[nothing ], float3, param_20_777 ) = cn_777;
			var(spec[nothing ], float, param_21_777 ) = cd;
			var(spec[nothing ], float3, param_22_777 ) = oc;
			var(spec[nothing ], float, param_23_777 ) = oa;
			var(spec[nothing ], float, param_24_777 ) = io;
			var(spec[nothing ], float3, param_25_777 ) = ss;
			var(spec[nothing ], float3, param_26_777 ) = vb;
			var(spec[nothing ], int, param_27_777 ) = ec;
			var(spec[nothing ], float3, _1033_777 ) = px(param_17_777, param_18_777, param_19_777, param_20_777, param_21_777, param_22_777, param_23_777, param_24_777, param_25_777, param_26_777, param_27_777 );
			oc = param_22_777;
			oa = param_23_777;
			io = param_24_777;
			ss = param_25_777;
			vb = param_26_777;
			ec = param_27_777;
			var(spec[nothing ], float3, cc_777 ) = _1033_777;
			fc += (float4(cc_777 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 21;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_786 ) = ro;
			var(spec[nothing ], float3, param_1_786 ) = rd;
			var(spec[nothing ], float3, param_2_786 ) = oc;
			var(spec[nothing ], float, param_3_786 ) = oa;
			var(spec[nothing ], float, param_4_786 ) = cd;
			var(spec[nothing ], float, param_5_786 ) = td;
			var(spec[nothing ], float, param_6_786 ) = io;
			var(spec[nothing ], float3, param_7_786 ) = ss;
			var(spec[nothing ], float3, param_8_786 ) = vb;
			var(spec[nothing ], int, param_9_786 ) = ec;
			tr(param_786, param_1_786, param_2_786, param_3_786, param_4_786, param_5_786, param_6_786, param_7_786, param_8_786, param_9_786 );
			oc = param_2_786;
			oa = param_3_786;
			cd = param_4_786;
			td = param_5_786;
			io = param_6_786;
			ss = param_7_786;
			vb = param_8_786;
			ec = param_9_786;
			var(spec[nothing ], float3, cp_786 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_786 ) = cp_786;
			var(spec[nothing ], float3, param_11_786 ) = oc;
			var(spec[nothing ], float, param_12_786 ) = oa;
			var(spec[nothing ], float, param_13_786 ) = io;
			var(spec[nothing ], float3, param_14_786 ) = ss;
			var(spec[nothing ], float3, param_15_786 ) = vb;
			var(spec[nothing ], int, param_16_786 ) = ec;
			var(spec[nothing ], float3, _940_786 ) = nm(param_10_786, param_11_786, param_12_786, param_13_786, param_14_786, param_15_786, param_16_786 );
			oc = param_11_786;
			oa = param_12_786;
			io = param_13_786;
			ss = param_14_786;
			vb = param_15_786;
			ec = param_16_786;
			var(spec[nothing ], float3, cn_786 ) = _940_786;
			ro = cp_786 - (cn_786 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_786 ) = refract(rd, cn_786, _958 );
			if((length(cr_786 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_786 = reflect(rd, cn_786 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_786;
			};
			es -- ;
			var(spec[nothing ], bool, _993_786 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_786 );
			if(_993_786 )
			{
				_999_786 = true;
			}
			else
			{
				_999_786 = _993_786;
			};
			if(_999_786 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_786 ) = rd;
			var(spec[nothing ], float3, param_18_786 ) = cp_786;
			var(spec[nothing ], float3, param_19_786 ) = cr_786;
			var(spec[nothing ], float3, param_20_786 ) = cn_786;
			var(spec[nothing ], float, param_21_786 ) = cd;
			var(spec[nothing ], float3, param_22_786 ) = oc;
			var(spec[nothing ], float, param_23_786 ) = oa;
			var(spec[nothing ], float, param_24_786 ) = io;
			var(spec[nothing ], float3, param_25_786 ) = ss;
			var(spec[nothing ], float3, param_26_786 ) = vb;
			var(spec[nothing ], int, param_27_786 ) = ec;
			var(spec[nothing ], float3, _1033_786 ) = px(param_17_786, param_18_786, param_19_786, param_20_786, param_21_786, param_22_786, param_23_786, param_24_786, param_25_786, param_26_786, param_27_786 );
			oc = param_22_786;
			oa = param_23_786;
			io = param_24_786;
			ss = param_25_786;
			vb = param_26_786;
			ec = param_27_786;
			var(spec[nothing ], float3, cc_786 ) = _1033_786;
			fc += (float4(cc_786 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 22;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_795 ) = ro;
			var(spec[nothing ], float3, param_1_795 ) = rd;
			var(spec[nothing ], float3, param_2_795 ) = oc;
			var(spec[nothing ], float, param_3_795 ) = oa;
			var(spec[nothing ], float, param_4_795 ) = cd;
			var(spec[nothing ], float, param_5_795 ) = td;
			var(spec[nothing ], float, param_6_795 ) = io;
			var(spec[nothing ], float3, param_7_795 ) = ss;
			var(spec[nothing ], float3, param_8_795 ) = vb;
			var(spec[nothing ], int, param_9_795 ) = ec;
			tr(param_795, param_1_795, param_2_795, param_3_795, param_4_795, param_5_795, param_6_795, param_7_795, param_8_795, param_9_795 );
			oc = param_2_795;
			oa = param_3_795;
			cd = param_4_795;
			td = param_5_795;
			io = param_6_795;
			ss = param_7_795;
			vb = param_8_795;
			ec = param_9_795;
			var(spec[nothing ], float3, cp_795 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_795 ) = cp_795;
			var(spec[nothing ], float3, param_11_795 ) = oc;
			var(spec[nothing ], float, param_12_795 ) = oa;
			var(spec[nothing ], float, param_13_795 ) = io;
			var(spec[nothing ], float3, param_14_795 ) = ss;
			var(spec[nothing ], float3, param_15_795 ) = vb;
			var(spec[nothing ], int, param_16_795 ) = ec;
			var(spec[nothing ], float3, _940_795 ) = nm(param_10_795, param_11_795, param_12_795, param_13_795, param_14_795, param_15_795, param_16_795 );
			oc = param_11_795;
			oa = param_12_795;
			io = param_13_795;
			ss = param_14_795;
			vb = param_15_795;
			ec = param_16_795;
			var(spec[nothing ], float3, cn_795 ) = _940_795;
			ro = cp_795 - (cn_795 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_795 ) = refract(rd, cn_795, _958 );
			if((length(cr_795 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_795 = reflect(rd, cn_795 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_795;
			};
			es -- ;
			var(spec[nothing ], bool, _993_795 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_795 );
			if(_993_795 )
			{
				_999_795 = false;
			}
			else
			{
				_999_795 = _993_795;
			};
			if(_999_795 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_795 ) = rd;
			var(spec[nothing ], float3, param_18_795 ) = cp_795;
			var(spec[nothing ], float3, param_19_795 ) = cr_795;
			var(spec[nothing ], float3, param_20_795 ) = cn_795;
			var(spec[nothing ], float, param_21_795 ) = cd;
			var(spec[nothing ], float3, param_22_795 ) = oc;
			var(spec[nothing ], float, param_23_795 ) = oa;
			var(spec[nothing ], float, param_24_795 ) = io;
			var(spec[nothing ], float3, param_25_795 ) = ss;
			var(spec[nothing ], float3, param_26_795 ) = vb;
			var(spec[nothing ], int, param_27_795 ) = ec;
			var(spec[nothing ], float3, _1033_795 ) = px(param_17_795, param_18_795, param_19_795, param_20_795, param_21_795, param_22_795, param_23_795, param_24_795, param_25_795, param_26_795, param_27_795 );
			oc = param_22_795;
			oa = param_23_795;
			io = param_24_795;
			ss = param_25_795;
			vb = param_26_795;
			ec = param_27_795;
			var(spec[nothing ], float3, cc_795 ) = _1033_795;
			fc += (float4(cc_795 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 23;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_804 ) = ro;
			var(spec[nothing ], float3, param_1_804 ) = rd;
			var(spec[nothing ], float3, param_2_804 ) = oc;
			var(spec[nothing ], float, param_3_804 ) = oa;
			var(spec[nothing ], float, param_4_804 ) = cd;
			var(spec[nothing ], float, param_5_804 ) = td;
			var(spec[nothing ], float, param_6_804 ) = io;
			var(spec[nothing ], float3, param_7_804 ) = ss;
			var(spec[nothing ], float3, param_8_804 ) = vb;
			var(spec[nothing ], int, param_9_804 ) = ec;
			tr(param_804, param_1_804, param_2_804, param_3_804, param_4_804, param_5_804, param_6_804, param_7_804, param_8_804, param_9_804 );
			oc = param_2_804;
			oa = param_3_804;
			cd = param_4_804;
			td = param_5_804;
			io = param_6_804;
			ss = param_7_804;
			vb = param_8_804;
			ec = param_9_804;
			var(spec[nothing ], float3, cp_804 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_804 ) = cp_804;
			var(spec[nothing ], float3, param_11_804 ) = oc;
			var(spec[nothing ], float, param_12_804 ) = oa;
			var(spec[nothing ], float, param_13_804 ) = io;
			var(spec[nothing ], float3, param_14_804 ) = ss;
			var(spec[nothing ], float3, param_15_804 ) = vb;
			var(spec[nothing ], int, param_16_804 ) = ec;
			var(spec[nothing ], float3, _940_804 ) = nm(param_10_804, param_11_804, param_12_804, param_13_804, param_14_804, param_15_804, param_16_804 );
			oc = param_11_804;
			oa = param_12_804;
			io = param_13_804;
			ss = param_14_804;
			vb = param_15_804;
			ec = param_16_804;
			var(spec[nothing ], float3, cn_804 ) = _940_804;
			ro = cp_804 - (cn_804 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_804 ) = refract(rd, cn_804, _958 );
			if((length(cr_804 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_804 = reflect(rd, cn_804 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_804;
			};
			es -- ;
			var(spec[nothing ], bool, _993_804 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_804 );
			if(_993_804 )
			{
				_999_804 = true;
			}
			else
			{
				_999_804 = _993_804;
			};
			if(_999_804 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_804 ) = rd;
			var(spec[nothing ], float3, param_18_804 ) = cp_804;
			var(spec[nothing ], float3, param_19_804 ) = cr_804;
			var(spec[nothing ], float3, param_20_804 ) = cn_804;
			var(spec[nothing ], float, param_21_804 ) = cd;
			var(spec[nothing ], float3, param_22_804 ) = oc;
			var(spec[nothing ], float, param_23_804 ) = oa;
			var(spec[nothing ], float, param_24_804 ) = io;
			var(spec[nothing ], float3, param_25_804 ) = ss;
			var(spec[nothing ], float3, param_26_804 ) = vb;
			var(spec[nothing ], int, param_27_804 ) = ec;
			var(spec[nothing ], float3, _1033_804 ) = px(param_17_804, param_18_804, param_19_804, param_20_804, param_21_804, param_22_804, param_23_804, param_24_804, param_25_804, param_26_804, param_27_804 );
			oc = param_22_804;
			oa = param_23_804;
			io = param_24_804;
			ss = param_25_804;
			vb = param_26_804;
			ec = param_27_804;
			var(spec[nothing ], float3, cc_804 ) = _1033_804;
			fc += (float4(cc_804 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 24;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_813 ) = ro;
			var(spec[nothing ], float3, param_1_813 ) = rd;
			var(spec[nothing ], float3, param_2_813 ) = oc;
			var(spec[nothing ], float, param_3_813 ) = oa;
			var(spec[nothing ], float, param_4_813 ) = cd;
			var(spec[nothing ], float, param_5_813 ) = td;
			var(spec[nothing ], float, param_6_813 ) = io;
			var(spec[nothing ], float3, param_7_813 ) = ss;
			var(spec[nothing ], float3, param_8_813 ) = vb;
			var(spec[nothing ], int, param_9_813 ) = ec;
			tr(param_813, param_1_813, param_2_813, param_3_813, param_4_813, param_5_813, param_6_813, param_7_813, param_8_813, param_9_813 );
			oc = param_2_813;
			oa = param_3_813;
			cd = param_4_813;
			td = param_5_813;
			io = param_6_813;
			ss = param_7_813;
			vb = param_8_813;
			ec = param_9_813;
			var(spec[nothing ], float3, cp_813 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_813 ) = cp_813;
			var(spec[nothing ], float3, param_11_813 ) = oc;
			var(spec[nothing ], float, param_12_813 ) = oa;
			var(spec[nothing ], float, param_13_813 ) = io;
			var(spec[nothing ], float3, param_14_813 ) = ss;
			var(spec[nothing ], float3, param_15_813 ) = vb;
			var(spec[nothing ], int, param_16_813 ) = ec;
			var(spec[nothing ], float3, _940_813 ) = nm(param_10_813, param_11_813, param_12_813, param_13_813, param_14_813, param_15_813, param_16_813 );
			oc = param_11_813;
			oa = param_12_813;
			io = param_13_813;
			ss = param_14_813;
			vb = param_15_813;
			ec = param_16_813;
			var(spec[nothing ], float3, cn_813 ) = _940_813;
			ro = cp_813 - (cn_813 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_813 ) = refract(rd, cn_813, _958 );
			if((length(cr_813 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_813 = reflect(rd, cn_813 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_813;
			};
			es -- ;
			var(spec[nothing ], bool, _993_813 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_813 );
			if(_993_813 )
			{
				_999_813 = false;
			}
			else
			{
				_999_813 = _993_813;
			};
			if(_999_813 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_813 ) = rd;
			var(spec[nothing ], float3, param_18_813 ) = cp_813;
			var(spec[nothing ], float3, param_19_813 ) = cr_813;
			var(spec[nothing ], float3, param_20_813 ) = cn_813;
			var(spec[nothing ], float, param_21_813 ) = cd;
			var(spec[nothing ], float3, param_22_813 ) = oc;
			var(spec[nothing ], float, param_23_813 ) = oa;
			var(spec[nothing ], float, param_24_813 ) = io;
			var(spec[nothing ], float3, param_25_813 ) = ss;
			var(spec[nothing ], float3, param_26_813 ) = vb;
			var(spec[nothing ], int, param_27_813 ) = ec;
			var(spec[nothing ], float3, _1033_813 ) = px(param_17_813, param_18_813, param_19_813, param_20_813, param_21_813, param_22_813, param_23_813, param_24_813, param_25_813, param_26_813, param_27_813 );
			oc = param_22_813;
			oa = param_23_813;
			io = param_24_813;
			ss = param_25_813;
			vb = param_26_813;
			ec = param_27_813;
			var(spec[nothing ], float3, cc_813 ) = _1033_813;
			fc += (float4(cc_813 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 25;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_822 ) = ro;
			var(spec[nothing ], float3, param_1_822 ) = rd;
			var(spec[nothing ], float3, param_2_822 ) = oc;
			var(spec[nothing ], float, param_3_822 ) = oa;
			var(spec[nothing ], float, param_4_822 ) = cd;
			var(spec[nothing ], float, param_5_822 ) = td;
			var(spec[nothing ], float, param_6_822 ) = io;
			var(spec[nothing ], float3, param_7_822 ) = ss;
			var(spec[nothing ], float3, param_8_822 ) = vb;
			var(spec[nothing ], int, param_9_822 ) = ec;
			tr(param_822, param_1_822, param_2_822, param_3_822, param_4_822, param_5_822, param_6_822, param_7_822, param_8_822, param_9_822 );
			oc = param_2_822;
			oa = param_3_822;
			cd = param_4_822;
			td = param_5_822;
			io = param_6_822;
			ss = param_7_822;
			vb = param_8_822;
			ec = param_9_822;
			var(spec[nothing ], float3, cp_822 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_822 ) = cp_822;
			var(spec[nothing ], float3, param_11_822 ) = oc;
			var(spec[nothing ], float, param_12_822 ) = oa;
			var(spec[nothing ], float, param_13_822 ) = io;
			var(spec[nothing ], float3, param_14_822 ) = ss;
			var(spec[nothing ], float3, param_15_822 ) = vb;
			var(spec[nothing ], int, param_16_822 ) = ec;
			var(spec[nothing ], float3, _940_822 ) = nm(param_10_822, param_11_822, param_12_822, param_13_822, param_14_822, param_15_822, param_16_822 );
			oc = param_11_822;
			oa = param_12_822;
			io = param_13_822;
			ss = param_14_822;
			vb = param_15_822;
			ec = param_16_822;
			var(spec[nothing ], float3, cn_822 ) = _940_822;
			ro = cp_822 - (cn_822 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_822 ) = refract(rd, cn_822, _958 );
			if((length(cr_822 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_822 = reflect(rd, cn_822 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_822;
			};
			es -- ;
			var(spec[nothing ], bool, _993_822 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_822 );
			if(_993_822 )
			{
				_999_822 = true;
			}
			else
			{
				_999_822 = _993_822;
			};
			if(_999_822 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_822 ) = rd;
			var(spec[nothing ], float3, param_18_822 ) = cp_822;
			var(spec[nothing ], float3, param_19_822 ) = cr_822;
			var(spec[nothing ], float3, param_20_822 ) = cn_822;
			var(spec[nothing ], float, param_21_822 ) = cd;
			var(spec[nothing ], float3, param_22_822 ) = oc;
			var(spec[nothing ], float, param_23_822 ) = oa;
			var(spec[nothing ], float, param_24_822 ) = io;
			var(spec[nothing ], float3, param_25_822 ) = ss;
			var(spec[nothing ], float3, param_26_822 ) = vb;
			var(spec[nothing ], int, param_27_822 ) = ec;
			var(spec[nothing ], float3, _1033_822 ) = px(param_17_822, param_18_822, param_19_822, param_20_822, param_21_822, param_22_822, param_23_822, param_24_822, param_25_822, param_26_822, param_27_822 );
			oc = param_22_822;
			oa = param_23_822;
			io = param_24_822;
			ss = param_25_822;
			vb = param_26_822;
			ec = param_27_822;
			var(spec[nothing ], float3, cc_822 ) = _1033_822;
			fc += (float4(cc_822 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 26;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_831 ) = ro;
			var(spec[nothing ], float3, param_1_831 ) = rd;
			var(spec[nothing ], float3, param_2_831 ) = oc;
			var(spec[nothing ], float, param_3_831 ) = oa;
			var(spec[nothing ], float, param_4_831 ) = cd;
			var(spec[nothing ], float, param_5_831 ) = td;
			var(spec[nothing ], float, param_6_831 ) = io;
			var(spec[nothing ], float3, param_7_831 ) = ss;
			var(spec[nothing ], float3, param_8_831 ) = vb;
			var(spec[nothing ], int, param_9_831 ) = ec;
			tr(param_831, param_1_831, param_2_831, param_3_831, param_4_831, param_5_831, param_6_831, param_7_831, param_8_831, param_9_831 );
			oc = param_2_831;
			oa = param_3_831;
			cd = param_4_831;
			td = param_5_831;
			io = param_6_831;
			ss = param_7_831;
			vb = param_8_831;
			ec = param_9_831;
			var(spec[nothing ], float3, cp_831 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_831 ) = cp_831;
			var(spec[nothing ], float3, param_11_831 ) = oc;
			var(spec[nothing ], float, param_12_831 ) = oa;
			var(spec[nothing ], float, param_13_831 ) = io;
			var(spec[nothing ], float3, param_14_831 ) = ss;
			var(spec[nothing ], float3, param_15_831 ) = vb;
			var(spec[nothing ], int, param_16_831 ) = ec;
			var(spec[nothing ], float3, _940_831 ) = nm(param_10_831, param_11_831, param_12_831, param_13_831, param_14_831, param_15_831, param_16_831 );
			oc = param_11_831;
			oa = param_12_831;
			io = param_13_831;
			ss = param_14_831;
			vb = param_15_831;
			ec = param_16_831;
			var(spec[nothing ], float3, cn_831 ) = _940_831;
			ro = cp_831 - (cn_831 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_831 ) = refract(rd, cn_831, _958 );
			if((length(cr_831 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_831 = reflect(rd, cn_831 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_831;
			};
			es -- ;
			var(spec[nothing ], bool, _993_831 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_831 );
			if(_993_831 )
			{
				_999_831 = false;
			}
			else
			{
				_999_831 = _993_831;
			};
			if(_999_831 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_831 ) = rd;
			var(spec[nothing ], float3, param_18_831 ) = cp_831;
			var(spec[nothing ], float3, param_19_831 ) = cr_831;
			var(spec[nothing ], float3, param_20_831 ) = cn_831;
			var(spec[nothing ], float, param_21_831 ) = cd;
			var(spec[nothing ], float3, param_22_831 ) = oc;
			var(spec[nothing ], float, param_23_831 ) = oa;
			var(spec[nothing ], float, param_24_831 ) = io;
			var(spec[nothing ], float3, param_25_831 ) = ss;
			var(spec[nothing ], float3, param_26_831 ) = vb;
			var(spec[nothing ], int, param_27_831 ) = ec;
			var(spec[nothing ], float3, _1033_831 ) = px(param_17_831, param_18_831, param_19_831, param_20_831, param_21_831, param_22_831, param_23_831, param_24_831, param_25_831, param_26_831, param_27_831 );
			oc = param_22_831;
			oa = param_23_831;
			io = param_24_831;
			ss = param_25_831;
			vb = param_26_831;
			ec = param_27_831;
			var(spec[nothing ], float3, cc_831 ) = _1033_831;
			fc += (float4(cc_831 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 27;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_840 ) = ro;
			var(spec[nothing ], float3, param_1_840 ) = rd;
			var(spec[nothing ], float3, param_2_840 ) = oc;
			var(spec[nothing ], float, param_3_840 ) = oa;
			var(spec[nothing ], float, param_4_840 ) = cd;
			var(spec[nothing ], float, param_5_840 ) = td;
			var(spec[nothing ], float, param_6_840 ) = io;
			var(spec[nothing ], float3, param_7_840 ) = ss;
			var(spec[nothing ], float3, param_8_840 ) = vb;
			var(spec[nothing ], int, param_9_840 ) = ec;
			tr(param_840, param_1_840, param_2_840, param_3_840, param_4_840, param_5_840, param_6_840, param_7_840, param_8_840, param_9_840 );
			oc = param_2_840;
			oa = param_3_840;
			cd = param_4_840;
			td = param_5_840;
			io = param_6_840;
			ss = param_7_840;
			vb = param_8_840;
			ec = param_9_840;
			var(spec[nothing ], float3, cp_840 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_840 ) = cp_840;
			var(spec[nothing ], float3, param_11_840 ) = oc;
			var(spec[nothing ], float, param_12_840 ) = oa;
			var(spec[nothing ], float, param_13_840 ) = io;
			var(spec[nothing ], float3, param_14_840 ) = ss;
			var(spec[nothing ], float3, param_15_840 ) = vb;
			var(spec[nothing ], int, param_16_840 ) = ec;
			var(spec[nothing ], float3, _940_840 ) = nm(param_10_840, param_11_840, param_12_840, param_13_840, param_14_840, param_15_840, param_16_840 );
			oc = param_11_840;
			oa = param_12_840;
			io = param_13_840;
			ss = param_14_840;
			vb = param_15_840;
			ec = param_16_840;
			var(spec[nothing ], float3, cn_840 ) = _940_840;
			ro = cp_840 - (cn_840 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_840 ) = refract(rd, cn_840, _958 );
			if((length(cr_840 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_840 = reflect(rd, cn_840 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_840;
			};
			es -- ;
			var(spec[nothing ], bool, _993_840 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_840 );
			if(_993_840 )
			{
				_999_840 = true;
			}
			else
			{
				_999_840 = _993_840;
			};
			if(_999_840 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_840 ) = rd;
			var(spec[nothing ], float3, param_18_840 ) = cp_840;
			var(spec[nothing ], float3, param_19_840 ) = cr_840;
			var(spec[nothing ], float3, param_20_840 ) = cn_840;
			var(spec[nothing ], float, param_21_840 ) = cd;
			var(spec[nothing ], float3, param_22_840 ) = oc;
			var(spec[nothing ], float, param_23_840 ) = oa;
			var(spec[nothing ], float, param_24_840 ) = io;
			var(spec[nothing ], float3, param_25_840 ) = ss;
			var(spec[nothing ], float3, param_26_840 ) = vb;
			var(spec[nothing ], int, param_27_840 ) = ec;
			var(spec[nothing ], float3, _1033_840 ) = px(param_17_840, param_18_840, param_19_840, param_20_840, param_21_840, param_22_840, param_23_840, param_24_840, param_25_840, param_26_840, param_27_840 );
			oc = param_22_840;
			oa = param_23_840;
			io = param_24_840;
			ss = param_25_840;
			vb = param_26_840;
			ec = param_27_840;
			var(spec[nothing ], float3, cc_840 ) = _1033_840;
			fc += (float4(cc_840 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 28;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_849 ) = ro;
			var(spec[nothing ], float3, param_1_849 ) = rd;
			var(spec[nothing ], float3, param_2_849 ) = oc;
			var(spec[nothing ], float, param_3_849 ) = oa;
			var(spec[nothing ], float, param_4_849 ) = cd;
			var(spec[nothing ], float, param_5_849 ) = td;
			var(spec[nothing ], float, param_6_849 ) = io;
			var(spec[nothing ], float3, param_7_849 ) = ss;
			var(spec[nothing ], float3, param_8_849 ) = vb;
			var(spec[nothing ], int, param_9_849 ) = ec;
			tr(param_849, param_1_849, param_2_849, param_3_849, param_4_849, param_5_849, param_6_849, param_7_849, param_8_849, param_9_849 );
			oc = param_2_849;
			oa = param_3_849;
			cd = param_4_849;
			td = param_5_849;
			io = param_6_849;
			ss = param_7_849;
			vb = param_8_849;
			ec = param_9_849;
			var(spec[nothing ], float3, cp_849 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_849 ) = cp_849;
			var(spec[nothing ], float3, param_11_849 ) = oc;
			var(spec[nothing ], float, param_12_849 ) = oa;
			var(spec[nothing ], float, param_13_849 ) = io;
			var(spec[nothing ], float3, param_14_849 ) = ss;
			var(spec[nothing ], float3, param_15_849 ) = vb;
			var(spec[nothing ], int, param_16_849 ) = ec;
			var(spec[nothing ], float3, _940_849 ) = nm(param_10_849, param_11_849, param_12_849, param_13_849, param_14_849, param_15_849, param_16_849 );
			oc = param_11_849;
			oa = param_12_849;
			io = param_13_849;
			ss = param_14_849;
			vb = param_15_849;
			ec = param_16_849;
			var(spec[nothing ], float3, cn_849 ) = _940_849;
			ro = cp_849 - (cn_849 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_849 ) = refract(rd, cn_849, _958 );
			if((length(cr_849 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_849 = reflect(rd, cn_849 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_849;
			};
			es -- ;
			var(spec[nothing ], bool, _993_849 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_849 );
			if(_993_849 )
			{
				_999_849 = false;
			}
			else
			{
				_999_849 = _993_849;
			};
			if(_999_849 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_849 ) = rd;
			var(spec[nothing ], float3, param_18_849 ) = cp_849;
			var(spec[nothing ], float3, param_19_849 ) = cr_849;
			var(spec[nothing ], float3, param_20_849 ) = cn_849;
			var(spec[nothing ], float, param_21_849 ) = cd;
			var(spec[nothing ], float3, param_22_849 ) = oc;
			var(spec[nothing ], float, param_23_849 ) = oa;
			var(spec[nothing ], float, param_24_849 ) = io;
			var(spec[nothing ], float3, param_25_849 ) = ss;
			var(spec[nothing ], float3, param_26_849 ) = vb;
			var(spec[nothing ], int, param_27_849 ) = ec;
			var(spec[nothing ], float3, _1033_849 ) = px(param_17_849, param_18_849, param_19_849, param_20_849, param_21_849, param_22_849, param_23_849, param_24_849, param_25_849, param_26_849, param_27_849 );
			oc = param_22_849;
			oa = param_23_849;
			io = param_24_849;
			ss = param_25_849;
			vb = param_26_849;
			ec = param_27_849;
			var(spec[nothing ], float3, cc_849 ) = _1033_849;
			fc += (float4(cc_849 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 29;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_858 ) = ro;
			var(spec[nothing ], float3, param_1_858 ) = rd;
			var(spec[nothing ], float3, param_2_858 ) = oc;
			var(spec[nothing ], float, param_3_858 ) = oa;
			var(spec[nothing ], float, param_4_858 ) = cd;
			var(spec[nothing ], float, param_5_858 ) = td;
			var(spec[nothing ], float, param_6_858 ) = io;
			var(spec[nothing ], float3, param_7_858 ) = ss;
			var(spec[nothing ], float3, param_8_858 ) = vb;
			var(spec[nothing ], int, param_9_858 ) = ec;
			tr(param_858, param_1_858, param_2_858, param_3_858, param_4_858, param_5_858, param_6_858, param_7_858, param_8_858, param_9_858 );
			oc = param_2_858;
			oa = param_3_858;
			cd = param_4_858;
			td = param_5_858;
			io = param_6_858;
			ss = param_7_858;
			vb = param_8_858;
			ec = param_9_858;
			var(spec[nothing ], float3, cp_858 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_858 ) = cp_858;
			var(spec[nothing ], float3, param_11_858 ) = oc;
			var(spec[nothing ], float, param_12_858 ) = oa;
			var(spec[nothing ], float, param_13_858 ) = io;
			var(spec[nothing ], float3, param_14_858 ) = ss;
			var(spec[nothing ], float3, param_15_858 ) = vb;
			var(spec[nothing ], int, param_16_858 ) = ec;
			var(spec[nothing ], float3, _940_858 ) = nm(param_10_858, param_11_858, param_12_858, param_13_858, param_14_858, param_15_858, param_16_858 );
			oc = param_11_858;
			oa = param_12_858;
			io = param_13_858;
			ss = param_14_858;
			vb = param_15_858;
			ec = param_16_858;
			var(spec[nothing ], float3, cn_858 ) = _940_858;
			ro = cp_858 - (cn_858 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_858 ) = refract(rd, cn_858, _958 );
			if((length(cr_858 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_858 = reflect(rd, cn_858 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_858;
			};
			es -- ;
			var(spec[nothing ], bool, _993_858 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_858 );
			if(_993_858 )
			{
				_999_858 = true;
			}
			else
			{
				_999_858 = _993_858;
			};
			if(_999_858 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_858 ) = rd;
			var(spec[nothing ], float3, param_18_858 ) = cp_858;
			var(spec[nothing ], float3, param_19_858 ) = cr_858;
			var(spec[nothing ], float3, param_20_858 ) = cn_858;
			var(spec[nothing ], float, param_21_858 ) = cd;
			var(spec[nothing ], float3, param_22_858 ) = oc;
			var(spec[nothing ], float, param_23_858 ) = oa;
			var(spec[nothing ], float, param_24_858 ) = io;
			var(spec[nothing ], float3, param_25_858 ) = ss;
			var(spec[nothing ], float3, param_26_858 ) = vb;
			var(spec[nothing ], int, param_27_858 ) = ec;
			var(spec[nothing ], float3, _1033_858 ) = px(param_17_858, param_18_858, param_19_858, param_20_858, param_21_858, param_22_858, param_23_858, param_24_858, param_25_858, param_26_858, param_27_858 );
			oc = param_22_858;
			oa = param_23_858;
			io = param_24_858;
			ss = param_25_858;
			vb = param_26_858;
			ec = param_27_858;
			var(spec[nothing ], float3, cc_858 ) = _1033_858;
			fc += (float4(cc_858 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 30;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_867 ) = ro;
			var(spec[nothing ], float3, param_1_867 ) = rd;
			var(spec[nothing ], float3, param_2_867 ) = oc;
			var(spec[nothing ], float, param_3_867 ) = oa;
			var(spec[nothing ], float, param_4_867 ) = cd;
			var(spec[nothing ], float, param_5_867 ) = td;
			var(spec[nothing ], float, param_6_867 ) = io;
			var(spec[nothing ], float3, param_7_867 ) = ss;
			var(spec[nothing ], float3, param_8_867 ) = vb;
			var(spec[nothing ], int, param_9_867 ) = ec;
			tr(param_867, param_1_867, param_2_867, param_3_867, param_4_867, param_5_867, param_6_867, param_7_867, param_8_867, param_9_867 );
			oc = param_2_867;
			oa = param_3_867;
			cd = param_4_867;
			td = param_5_867;
			io = param_6_867;
			ss = param_7_867;
			vb = param_8_867;
			ec = param_9_867;
			var(spec[nothing ], float3, cp_867 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_867 ) = cp_867;
			var(spec[nothing ], float3, param_11_867 ) = oc;
			var(spec[nothing ], float, param_12_867 ) = oa;
			var(spec[nothing ], float, param_13_867 ) = io;
			var(spec[nothing ], float3, param_14_867 ) = ss;
			var(spec[nothing ], float3, param_15_867 ) = vb;
			var(spec[nothing ], int, param_16_867 ) = ec;
			var(spec[nothing ], float3, _940_867 ) = nm(param_10_867, param_11_867, param_12_867, param_13_867, param_14_867, param_15_867, param_16_867 );
			oc = param_11_867;
			oa = param_12_867;
			io = param_13_867;
			ss = param_14_867;
			vb = param_15_867;
			ec = param_16_867;
			var(spec[nothing ], float3, cn_867 ) = _940_867;
			ro = cp_867 - (cn_867 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_867 ) = refract(rd, cn_867, _958 );
			if((length(cr_867 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_867 = reflect(rd, cn_867 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_867;
			};
			es -- ;
			var(spec[nothing ], bool, _993_867 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_867 );
			if(_993_867 )
			{
				_999_867 = false;
			}
			else
			{
				_999_867 = _993_867;
			};
			if(_999_867 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_867 ) = rd;
			var(spec[nothing ], float3, param_18_867 ) = cp_867;
			var(spec[nothing ], float3, param_19_867 ) = cr_867;
			var(spec[nothing ], float3, param_20_867 ) = cn_867;
			var(spec[nothing ], float, param_21_867 ) = cd;
			var(spec[nothing ], float3, param_22_867 ) = oc;
			var(spec[nothing ], float, param_23_867 ) = oa;
			var(spec[nothing ], float, param_24_867 ) = io;
			var(spec[nothing ], float3, param_25_867 ) = ss;
			var(spec[nothing ], float3, param_26_867 ) = vb;
			var(spec[nothing ], int, param_27_867 ) = ec;
			var(spec[nothing ], float3, _1033_867 ) = px(param_17_867, param_18_867, param_19_867, param_20_867, param_21_867, param_22_867, param_23_867, param_24_867, param_25_867, param_26_867, param_27_867 );
			oc = param_22_867;
			oa = param_23_867;
			io = param_24_867;
			ss = param_25_867;
			vb = param_26_867;
			ec = param_27_867;
			var(spec[nothing ], float3, cc_867 ) = _1033_867;
			fc += (float4(cc_867 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 31;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_876 ) = ro;
			var(spec[nothing ], float3, param_1_876 ) = rd;
			var(spec[nothing ], float3, param_2_876 ) = oc;
			var(spec[nothing ], float, param_3_876 ) = oa;
			var(spec[nothing ], float, param_4_876 ) = cd;
			var(spec[nothing ], float, param_5_876 ) = td;
			var(spec[nothing ], float, param_6_876 ) = io;
			var(spec[nothing ], float3, param_7_876 ) = ss;
			var(spec[nothing ], float3, param_8_876 ) = vb;
			var(spec[nothing ], int, param_9_876 ) = ec;
			tr(param_876, param_1_876, param_2_876, param_3_876, param_4_876, param_5_876, param_6_876, param_7_876, param_8_876, param_9_876 );
			oc = param_2_876;
			oa = param_3_876;
			cd = param_4_876;
			td = param_5_876;
			io = param_6_876;
			ss = param_7_876;
			vb = param_8_876;
			ec = param_9_876;
			var(spec[nothing ], float3, cp_876 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_876 ) = cp_876;
			var(spec[nothing ], float3, param_11_876 ) = oc;
			var(spec[nothing ], float, param_12_876 ) = oa;
			var(spec[nothing ], float, param_13_876 ) = io;
			var(spec[nothing ], float3, param_14_876 ) = ss;
			var(spec[nothing ], float3, param_15_876 ) = vb;
			var(spec[nothing ], int, param_16_876 ) = ec;
			var(spec[nothing ], float3, _940_876 ) = nm(param_10_876, param_11_876, param_12_876, param_13_876, param_14_876, param_15_876, param_16_876 );
			oc = param_11_876;
			oa = param_12_876;
			io = param_13_876;
			ss = param_14_876;
			vb = param_15_876;
			ec = param_16_876;
			var(spec[nothing ], float3, cn_876 ) = _940_876;
			ro = cp_876 - (cn_876 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_876 ) = refract(rd, cn_876, _958 );
			if((length(cr_876 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_876 = reflect(rd, cn_876 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_876;
			};
			es -- ;
			var(spec[nothing ], bool, _993_876 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_876 );
			if(_993_876 )
			{
				_999_876 = true;
			}
			else
			{
				_999_876 = _993_876;
			};
			if(_999_876 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_876 ) = rd;
			var(spec[nothing ], float3, param_18_876 ) = cp_876;
			var(spec[nothing ], float3, param_19_876 ) = cr_876;
			var(spec[nothing ], float3, param_20_876 ) = cn_876;
			var(spec[nothing ], float, param_21_876 ) = cd;
			var(spec[nothing ], float3, param_22_876 ) = oc;
			var(spec[nothing ], float, param_23_876 ) = oa;
			var(spec[nothing ], float, param_24_876 ) = io;
			var(spec[nothing ], float3, param_25_876 ) = ss;
			var(spec[nothing ], float3, param_26_876 ) = vb;
			var(spec[nothing ], int, param_27_876 ) = ec;
			var(spec[nothing ], float3, _1033_876 ) = px(param_17_876, param_18_876, param_19_876, param_20_876, param_21_876, param_22_876, param_23_876, param_24_876, param_25_876, param_26_876, param_27_876 );
			oc = param_22_876;
			oa = param_23_876;
			io = param_24_876;
			ss = param_25_876;
			vb = param_26_876;
			ec = param_27_876;
			var(spec[nothing ], float3, cc_876 ) = _1033_876;
			fc += (float4(cc_876 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 32;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_885 ) = ro;
			var(spec[nothing ], float3, param_1_885 ) = rd;
			var(spec[nothing ], float3, param_2_885 ) = oc;
			var(spec[nothing ], float, param_3_885 ) = oa;
			var(spec[nothing ], float, param_4_885 ) = cd;
			var(spec[nothing ], float, param_5_885 ) = td;
			var(spec[nothing ], float, param_6_885 ) = io;
			var(spec[nothing ], float3, param_7_885 ) = ss;
			var(spec[nothing ], float3, param_8_885 ) = vb;
			var(spec[nothing ], int, param_9_885 ) = ec;
			tr(param_885, param_1_885, param_2_885, param_3_885, param_4_885, param_5_885, param_6_885, param_7_885, param_8_885, param_9_885 );
			oc = param_2_885;
			oa = param_3_885;
			cd = param_4_885;
			td = param_5_885;
			io = param_6_885;
			ss = param_7_885;
			vb = param_8_885;
			ec = param_9_885;
			var(spec[nothing ], float3, cp_885 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_885 ) = cp_885;
			var(spec[nothing ], float3, param_11_885 ) = oc;
			var(spec[nothing ], float, param_12_885 ) = oa;
			var(spec[nothing ], float, param_13_885 ) = io;
			var(spec[nothing ], float3, param_14_885 ) = ss;
			var(spec[nothing ], float3, param_15_885 ) = vb;
			var(spec[nothing ], int, param_16_885 ) = ec;
			var(spec[nothing ], float3, _940_885 ) = nm(param_10_885, param_11_885, param_12_885, param_13_885, param_14_885, param_15_885, param_16_885 );
			oc = param_11_885;
			oa = param_12_885;
			io = param_13_885;
			ss = param_14_885;
			vb = param_15_885;
			ec = param_16_885;
			var(spec[nothing ], float3, cn_885 ) = _940_885;
			ro = cp_885 - (cn_885 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_885 ) = refract(rd, cn_885, _958 );
			if((length(cr_885 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_885 = reflect(rd, cn_885 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_885;
			};
			es -- ;
			var(spec[nothing ], bool, _993_885 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_885 );
			if(_993_885 )
			{
				_999_885 = false;
			}
			else
			{
				_999_885 = _993_885;
			};
			if(_999_885 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_885 ) = rd;
			var(spec[nothing ], float3, param_18_885 ) = cp_885;
			var(spec[nothing ], float3, param_19_885 ) = cr_885;
			var(spec[nothing ], float3, param_20_885 ) = cn_885;
			var(spec[nothing ], float, param_21_885 ) = cd;
			var(spec[nothing ], float3, param_22_885 ) = oc;
			var(spec[nothing ], float, param_23_885 ) = oa;
			var(spec[nothing ], float, param_24_885 ) = io;
			var(spec[nothing ], float3, param_25_885 ) = ss;
			var(spec[nothing ], float3, param_26_885 ) = vb;
			var(spec[nothing ], int, param_27_885 ) = ec;
			var(spec[nothing ], float3, _1033_885 ) = px(param_17_885, param_18_885, param_19_885, param_20_885, param_21_885, param_22_885, param_23_885, param_24_885, param_25_885, param_26_885, param_27_885 );
			oc = param_22_885;
			oa = param_23_885;
			io = param_24_885;
			ss = param_25_885;
			vb = param_26_885;
			ec = param_27_885;
			var(spec[nothing ], float3, cc_885 ) = _1033_885;
			fc += (float4(cc_885 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 33;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_894 ) = ro;
			var(spec[nothing ], float3, param_1_894 ) = rd;
			var(spec[nothing ], float3, param_2_894 ) = oc;
			var(spec[nothing ], float, param_3_894 ) = oa;
			var(spec[nothing ], float, param_4_894 ) = cd;
			var(spec[nothing ], float, param_5_894 ) = td;
			var(spec[nothing ], float, param_6_894 ) = io;
			var(spec[nothing ], float3, param_7_894 ) = ss;
			var(spec[nothing ], float3, param_8_894 ) = vb;
			var(spec[nothing ], int, param_9_894 ) = ec;
			tr(param_894, param_1_894, param_2_894, param_3_894, param_4_894, param_5_894, param_6_894, param_7_894, param_8_894, param_9_894 );
			oc = param_2_894;
			oa = param_3_894;
			cd = param_4_894;
			td = param_5_894;
			io = param_6_894;
			ss = param_7_894;
			vb = param_8_894;
			ec = param_9_894;
			var(spec[nothing ], float3, cp_894 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_894 ) = cp_894;
			var(spec[nothing ], float3, param_11_894 ) = oc;
			var(spec[nothing ], float, param_12_894 ) = oa;
			var(spec[nothing ], float, param_13_894 ) = io;
			var(spec[nothing ], float3, param_14_894 ) = ss;
			var(spec[nothing ], float3, param_15_894 ) = vb;
			var(spec[nothing ], int, param_16_894 ) = ec;
			var(spec[nothing ], float3, _940_894 ) = nm(param_10_894, param_11_894, param_12_894, param_13_894, param_14_894, param_15_894, param_16_894 );
			oc = param_11_894;
			oa = param_12_894;
			io = param_13_894;
			ss = param_14_894;
			vb = param_15_894;
			ec = param_16_894;
			var(spec[nothing ], float3, cn_894 ) = _940_894;
			ro = cp_894 - (cn_894 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_894 ) = refract(rd, cn_894, _958 );
			if((length(cr_894 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_894 = reflect(rd, cn_894 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_894;
			};
			es -- ;
			var(spec[nothing ], bool, _993_894 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_894 );
			if(_993_894 )
			{
				_999_894 = true;
			}
			else
			{
				_999_894 = _993_894;
			};
			if(_999_894 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_894 ) = rd;
			var(spec[nothing ], float3, param_18_894 ) = cp_894;
			var(spec[nothing ], float3, param_19_894 ) = cr_894;
			var(spec[nothing ], float3, param_20_894 ) = cn_894;
			var(spec[nothing ], float, param_21_894 ) = cd;
			var(spec[nothing ], float3, param_22_894 ) = oc;
			var(spec[nothing ], float, param_23_894 ) = oa;
			var(spec[nothing ], float, param_24_894 ) = io;
			var(spec[nothing ], float3, param_25_894 ) = ss;
			var(spec[nothing ], float3, param_26_894 ) = vb;
			var(spec[nothing ], int, param_27_894 ) = ec;
			var(spec[nothing ], float3, _1033_894 ) = px(param_17_894, param_18_894, param_19_894, param_20_894, param_21_894, param_22_894, param_23_894, param_24_894, param_25_894, param_26_894, param_27_894 );
			oc = param_22_894;
			oa = param_23_894;
			io = param_24_894;
			ss = param_25_894;
			vb = param_26_894;
			ec = param_27_894;
			var(spec[nothing ], float3, cc_894 ) = _1033_894;
			fc += (float4(cc_894 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 34;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_903 ) = ro;
			var(spec[nothing ], float3, param_1_903 ) = rd;
			var(spec[nothing ], float3, param_2_903 ) = oc;
			var(spec[nothing ], float, param_3_903 ) = oa;
			var(spec[nothing ], float, param_4_903 ) = cd;
			var(spec[nothing ], float, param_5_903 ) = td;
			var(spec[nothing ], float, param_6_903 ) = io;
			var(spec[nothing ], float3, param_7_903 ) = ss;
			var(spec[nothing ], float3, param_8_903 ) = vb;
			var(spec[nothing ], int, param_9_903 ) = ec;
			tr(param_903, param_1_903, param_2_903, param_3_903, param_4_903, param_5_903, param_6_903, param_7_903, param_8_903, param_9_903 );
			oc = param_2_903;
			oa = param_3_903;
			cd = param_4_903;
			td = param_5_903;
			io = param_6_903;
			ss = param_7_903;
			vb = param_8_903;
			ec = param_9_903;
			var(spec[nothing ], float3, cp_903 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_903 ) = cp_903;
			var(spec[nothing ], float3, param_11_903 ) = oc;
			var(spec[nothing ], float, param_12_903 ) = oa;
			var(spec[nothing ], float, param_13_903 ) = io;
			var(spec[nothing ], float3, param_14_903 ) = ss;
			var(spec[nothing ], float3, param_15_903 ) = vb;
			var(spec[nothing ], int, param_16_903 ) = ec;
			var(spec[nothing ], float3, _940_903 ) = nm(param_10_903, param_11_903, param_12_903, param_13_903, param_14_903, param_15_903, param_16_903 );
			oc = param_11_903;
			oa = param_12_903;
			io = param_13_903;
			ss = param_14_903;
			vb = param_15_903;
			ec = param_16_903;
			var(spec[nothing ], float3, cn_903 ) = _940_903;
			ro = cp_903 - (cn_903 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_903 ) = refract(rd, cn_903, _958 );
			if((length(cr_903 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_903 = reflect(rd, cn_903 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_903;
			};
			es -- ;
			var(spec[nothing ], bool, _993_903 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_903 );
			if(_993_903 )
			{
				_999_903 = false;
			}
			else
			{
				_999_903 = _993_903;
			};
			if(_999_903 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_903 ) = rd;
			var(spec[nothing ], float3, param_18_903 ) = cp_903;
			var(spec[nothing ], float3, param_19_903 ) = cr_903;
			var(spec[nothing ], float3, param_20_903 ) = cn_903;
			var(spec[nothing ], float, param_21_903 ) = cd;
			var(spec[nothing ], float3, param_22_903 ) = oc;
			var(spec[nothing ], float, param_23_903 ) = oa;
			var(spec[nothing ], float, param_24_903 ) = io;
			var(spec[nothing ], float3, param_25_903 ) = ss;
			var(spec[nothing ], float3, param_26_903 ) = vb;
			var(spec[nothing ], int, param_27_903 ) = ec;
			var(spec[nothing ], float3, _1033_903 ) = px(param_17_903, param_18_903, param_19_903, param_20_903, param_21_903, param_22_903, param_23_903, param_24_903, param_25_903, param_26_903, param_27_903 );
			oc = param_22_903;
			oa = param_23_903;
			io = param_24_903;
			ss = param_25_903;
			vb = param_26_903;
			ec = param_27_903;
			var(spec[nothing ], float3, cc_903 ) = _1033_903;
			fc += (float4(cc_903 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 35;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_912 ) = ro;
			var(spec[nothing ], float3, param_1_912 ) = rd;
			var(spec[nothing ], float3, param_2_912 ) = oc;
			var(spec[nothing ], float, param_3_912 ) = oa;
			var(spec[nothing ], float, param_4_912 ) = cd;
			var(spec[nothing ], float, param_5_912 ) = td;
			var(spec[nothing ], float, param_6_912 ) = io;
			var(spec[nothing ], float3, param_7_912 ) = ss;
			var(spec[nothing ], float3, param_8_912 ) = vb;
			var(spec[nothing ], int, param_9_912 ) = ec;
			tr(param_912, param_1_912, param_2_912, param_3_912, param_4_912, param_5_912, param_6_912, param_7_912, param_8_912, param_9_912 );
			oc = param_2_912;
			oa = param_3_912;
			cd = param_4_912;
			td = param_5_912;
			io = param_6_912;
			ss = param_7_912;
			vb = param_8_912;
			ec = param_9_912;
			var(spec[nothing ], float3, cp_912 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_912 ) = cp_912;
			var(spec[nothing ], float3, param_11_912 ) = oc;
			var(spec[nothing ], float, param_12_912 ) = oa;
			var(spec[nothing ], float, param_13_912 ) = io;
			var(spec[nothing ], float3, param_14_912 ) = ss;
			var(spec[nothing ], float3, param_15_912 ) = vb;
			var(spec[nothing ], int, param_16_912 ) = ec;
			var(spec[nothing ], float3, _940_912 ) = nm(param_10_912, param_11_912, param_12_912, param_13_912, param_14_912, param_15_912, param_16_912 );
			oc = param_11_912;
			oa = param_12_912;
			io = param_13_912;
			ss = param_14_912;
			vb = param_15_912;
			ec = param_16_912;
			var(spec[nothing ], float3, cn_912 ) = _940_912;
			ro = cp_912 - (cn_912 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_912 ) = refract(rd, cn_912, _958 );
			if((length(cr_912 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_912 = reflect(rd, cn_912 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_912;
			};
			es -- ;
			var(spec[nothing ], bool, _993_912 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_912 );
			if(_993_912 )
			{
				_999_912 = true;
			}
			else
			{
				_999_912 = _993_912;
			};
			if(_999_912 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_912 ) = rd;
			var(spec[nothing ], float3, param_18_912 ) = cp_912;
			var(spec[nothing ], float3, param_19_912 ) = cr_912;
			var(spec[nothing ], float3, param_20_912 ) = cn_912;
			var(spec[nothing ], float, param_21_912 ) = cd;
			var(spec[nothing ], float3, param_22_912 ) = oc;
			var(spec[nothing ], float, param_23_912 ) = oa;
			var(spec[nothing ], float, param_24_912 ) = io;
			var(spec[nothing ], float3, param_25_912 ) = ss;
			var(spec[nothing ], float3, param_26_912 ) = vb;
			var(spec[nothing ], int, param_27_912 ) = ec;
			var(spec[nothing ], float3, _1033_912 ) = px(param_17_912, param_18_912, param_19_912, param_20_912, param_21_912, param_22_912, param_23_912, param_24_912, param_25_912, param_26_912, param_27_912 );
			oc = param_22_912;
			oa = param_23_912;
			io = param_24_912;
			ss = param_25_912;
			vb = param_26_912;
			ec = param_27_912;
			var(spec[nothing ], float3, cc_912 ) = _1033_912;
			fc += (float4(cc_912 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 36;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_921 ) = ro;
			var(spec[nothing ], float3, param_1_921 ) = rd;
			var(spec[nothing ], float3, param_2_921 ) = oc;
			var(spec[nothing ], float, param_3_921 ) = oa;
			var(spec[nothing ], float, param_4_921 ) = cd;
			var(spec[nothing ], float, param_5_921 ) = td;
			var(spec[nothing ], float, param_6_921 ) = io;
			var(spec[nothing ], float3, param_7_921 ) = ss;
			var(spec[nothing ], float3, param_8_921 ) = vb;
			var(spec[nothing ], int, param_9_921 ) = ec;
			tr(param_921, param_1_921, param_2_921, param_3_921, param_4_921, param_5_921, param_6_921, param_7_921, param_8_921, param_9_921 );
			oc = param_2_921;
			oa = param_3_921;
			cd = param_4_921;
			td = param_5_921;
			io = param_6_921;
			ss = param_7_921;
			vb = param_8_921;
			ec = param_9_921;
			var(spec[nothing ], float3, cp_921 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_921 ) = cp_921;
			var(spec[nothing ], float3, param_11_921 ) = oc;
			var(spec[nothing ], float, param_12_921 ) = oa;
			var(spec[nothing ], float, param_13_921 ) = io;
			var(spec[nothing ], float3, param_14_921 ) = ss;
			var(spec[nothing ], float3, param_15_921 ) = vb;
			var(spec[nothing ], int, param_16_921 ) = ec;
			var(spec[nothing ], float3, _940_921 ) = nm(param_10_921, param_11_921, param_12_921, param_13_921, param_14_921, param_15_921, param_16_921 );
			oc = param_11_921;
			oa = param_12_921;
			io = param_13_921;
			ss = param_14_921;
			vb = param_15_921;
			ec = param_16_921;
			var(spec[nothing ], float3, cn_921 ) = _940_921;
			ro = cp_921 - (cn_921 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_921 ) = refract(rd, cn_921, _958 );
			if((length(cr_921 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_921 = reflect(rd, cn_921 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_921;
			};
			es -- ;
			var(spec[nothing ], bool, _993_921 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_921 );
			if(_993_921 )
			{
				_999_921 = false;
			}
			else
			{
				_999_921 = _993_921;
			};
			if(_999_921 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_921 ) = rd;
			var(spec[nothing ], float3, param_18_921 ) = cp_921;
			var(spec[nothing ], float3, param_19_921 ) = cr_921;
			var(spec[nothing ], float3, param_20_921 ) = cn_921;
			var(spec[nothing ], float, param_21_921 ) = cd;
			var(spec[nothing ], float3, param_22_921 ) = oc;
			var(spec[nothing ], float, param_23_921 ) = oa;
			var(spec[nothing ], float, param_24_921 ) = io;
			var(spec[nothing ], float3, param_25_921 ) = ss;
			var(spec[nothing ], float3, param_26_921 ) = vb;
			var(spec[nothing ], int, param_27_921 ) = ec;
			var(spec[nothing ], float3, _1033_921 ) = px(param_17_921, param_18_921, param_19_921, param_20_921, param_21_921, param_22_921, param_23_921, param_24_921, param_25_921, param_26_921, param_27_921 );
			oc = param_22_921;
			oa = param_23_921;
			io = param_24_921;
			ss = param_25_921;
			vb = param_26_921;
			ec = param_27_921;
			var(spec[nothing ], float3, cc_921 ) = _1033_921;
			fc += (float4(cc_921 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 37;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_930 ) = ro;
			var(spec[nothing ], float3, param_1_930 ) = rd;
			var(spec[nothing ], float3, param_2_930 ) = oc;
			var(spec[nothing ], float, param_3_930 ) = oa;
			var(spec[nothing ], float, param_4_930 ) = cd;
			var(spec[nothing ], float, param_5_930 ) = td;
			var(spec[nothing ], float, param_6_930 ) = io;
			var(spec[nothing ], float3, param_7_930 ) = ss;
			var(spec[nothing ], float3, param_8_930 ) = vb;
			var(spec[nothing ], int, param_9_930 ) = ec;
			tr(param_930, param_1_930, param_2_930, param_3_930, param_4_930, param_5_930, param_6_930, param_7_930, param_8_930, param_9_930 );
			oc = param_2_930;
			oa = param_3_930;
			cd = param_4_930;
			td = param_5_930;
			io = param_6_930;
			ss = param_7_930;
			vb = param_8_930;
			ec = param_9_930;
			var(spec[nothing ], float3, cp_930 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_930 ) = cp_930;
			var(spec[nothing ], float3, param_11_930 ) = oc;
			var(spec[nothing ], float, param_12_930 ) = oa;
			var(spec[nothing ], float, param_13_930 ) = io;
			var(spec[nothing ], float3, param_14_930 ) = ss;
			var(spec[nothing ], float3, param_15_930 ) = vb;
			var(spec[nothing ], int, param_16_930 ) = ec;
			var(spec[nothing ], float3, _940_930 ) = nm(param_10_930, param_11_930, param_12_930, param_13_930, param_14_930, param_15_930, param_16_930 );
			oc = param_11_930;
			oa = param_12_930;
			io = param_13_930;
			ss = param_14_930;
			vb = param_15_930;
			ec = param_16_930;
			var(spec[nothing ], float3, cn_930 ) = _940_930;
			ro = cp_930 - (cn_930 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_930 ) = refract(rd, cn_930, _958 );
			if((length(cr_930 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_930 = reflect(rd, cn_930 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_930;
			};
			es -- ;
			var(spec[nothing ], bool, _993_930 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_930 );
			if(_993_930 )
			{
				_999_930 = true;
			}
			else
			{
				_999_930 = _993_930;
			};
			if(_999_930 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_930 ) = rd;
			var(spec[nothing ], float3, param_18_930 ) = cp_930;
			var(spec[nothing ], float3, param_19_930 ) = cr_930;
			var(spec[nothing ], float3, param_20_930 ) = cn_930;
			var(spec[nothing ], float, param_21_930 ) = cd;
			var(spec[nothing ], float3, param_22_930 ) = oc;
			var(spec[nothing ], float, param_23_930 ) = oa;
			var(spec[nothing ], float, param_24_930 ) = io;
			var(spec[nothing ], float3, param_25_930 ) = ss;
			var(spec[nothing ], float3, param_26_930 ) = vb;
			var(spec[nothing ], int, param_27_930 ) = ec;
			var(spec[nothing ], float3, _1033_930 ) = px(param_17_930, param_18_930, param_19_930, param_20_930, param_21_930, param_22_930, param_23_930, param_24_930, param_25_930, param_26_930, param_27_930 );
			oc = param_22_930;
			oa = param_23_930;
			io = param_24_930;
			ss = param_25_930;
			vb = param_26_930;
			ec = param_27_930;
			var(spec[nothing ], float3, cc_930 ) = _1033_930;
			fc += (float4(cc_930 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 38;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_939 ) = ro;
			var(spec[nothing ], float3, param_1_939 ) = rd;
			var(spec[nothing ], float3, param_2_939 ) = oc;
			var(spec[nothing ], float, param_3_939 ) = oa;
			var(spec[nothing ], float, param_4_939 ) = cd;
			var(spec[nothing ], float, param_5_939 ) = td;
			var(spec[nothing ], float, param_6_939 ) = io;
			var(spec[nothing ], float3, param_7_939 ) = ss;
			var(spec[nothing ], float3, param_8_939 ) = vb;
			var(spec[nothing ], int, param_9_939 ) = ec;
			tr(param_939, param_1_939, param_2_939, param_3_939, param_4_939, param_5_939, param_6_939, param_7_939, param_8_939, param_9_939 );
			oc = param_2_939;
			oa = param_3_939;
			cd = param_4_939;
			td = param_5_939;
			io = param_6_939;
			ss = param_7_939;
			vb = param_8_939;
			ec = param_9_939;
			var(spec[nothing ], float3, cp_939 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_939 ) = cp_939;
			var(spec[nothing ], float3, param_11_939 ) = oc;
			var(spec[nothing ], float, param_12_939 ) = oa;
			var(spec[nothing ], float, param_13_939 ) = io;
			var(spec[nothing ], float3, param_14_939 ) = ss;
			var(spec[nothing ], float3, param_15_939 ) = vb;
			var(spec[nothing ], int, param_16_939 ) = ec;
			var(spec[nothing ], float3, _940_939 ) = nm(param_10_939, param_11_939, param_12_939, param_13_939, param_14_939, param_15_939, param_16_939 );
			oc = param_11_939;
			oa = param_12_939;
			io = param_13_939;
			ss = param_14_939;
			vb = param_15_939;
			ec = param_16_939;
			var(spec[nothing ], float3, cn_939 ) = _940_939;
			ro = cp_939 - (cn_939 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_939 ) = refract(rd, cn_939, _958 );
			if((length(cr_939 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_939 = reflect(rd, cn_939 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_939;
			};
			es -- ;
			var(spec[nothing ], bool, _993_939 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_939 );
			if(_993_939 )
			{
				_999_939 = false;
			}
			else
			{
				_999_939 = _993_939;
			};
			if(_999_939 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_939 ) = rd;
			var(spec[nothing ], float3, param_18_939 ) = cp_939;
			var(spec[nothing ], float3, param_19_939 ) = cr_939;
			var(spec[nothing ], float3, param_20_939 ) = cn_939;
			var(spec[nothing ], float, param_21_939 ) = cd;
			var(spec[nothing ], float3, param_22_939 ) = oc;
			var(spec[nothing ], float, param_23_939 ) = oa;
			var(spec[nothing ], float, param_24_939 ) = io;
			var(spec[nothing ], float3, param_25_939 ) = ss;
			var(spec[nothing ], float3, param_26_939 ) = vb;
			var(spec[nothing ], int, param_27_939 ) = ec;
			var(spec[nothing ], float3, _1033_939 ) = px(param_17_939, param_18_939, param_19_939, param_20_939, param_21_939, param_22_939, param_23_939, param_24_939, param_25_939, param_26_939, param_27_939 );
			oc = param_22_939;
			oa = param_23_939;
			io = param_24_939;
			ss = param_25_939;
			vb = param_26_939;
			ec = param_27_939;
			var(spec[nothing ], float3, cc_939 ) = _1033_939;
			fc += (float4(cc_939 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 39;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_948 ) = ro;
			var(spec[nothing ], float3, param_1_948 ) = rd;
			var(spec[nothing ], float3, param_2_948 ) = oc;
			var(spec[nothing ], float, param_3_948 ) = oa;
			var(spec[nothing ], float, param_4_948 ) = cd;
			var(spec[nothing ], float, param_5_948 ) = td;
			var(spec[nothing ], float, param_6_948 ) = io;
			var(spec[nothing ], float3, param_7_948 ) = ss;
			var(spec[nothing ], float3, param_8_948 ) = vb;
			var(spec[nothing ], int, param_9_948 ) = ec;
			tr(param_948, param_1_948, param_2_948, param_3_948, param_4_948, param_5_948, param_6_948, param_7_948, param_8_948, param_9_948 );
			oc = param_2_948;
			oa = param_3_948;
			cd = param_4_948;
			td = param_5_948;
			io = param_6_948;
			ss = param_7_948;
			vb = param_8_948;
			ec = param_9_948;
			var(spec[nothing ], float3, cp_948 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_948 ) = cp_948;
			var(spec[nothing ], float3, param_11_948 ) = oc;
			var(spec[nothing ], float, param_12_948 ) = oa;
			var(spec[nothing ], float, param_13_948 ) = io;
			var(spec[nothing ], float3, param_14_948 ) = ss;
			var(spec[nothing ], float3, param_15_948 ) = vb;
			var(spec[nothing ], int, param_16_948 ) = ec;
			var(spec[nothing ], float3, _940_948 ) = nm(param_10_948, param_11_948, param_12_948, param_13_948, param_14_948, param_15_948, param_16_948 );
			oc = param_11_948;
			oa = param_12_948;
			io = param_13_948;
			ss = param_14_948;
			vb = param_15_948;
			ec = param_16_948;
			var(spec[nothing ], float3, cn_948 ) = _940_948;
			ro = cp_948 - (cn_948 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_948 ) = refract(rd, cn_948, _958 );
			if((length(cr_948 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_948 = reflect(rd, cn_948 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_948;
			};
			es -- ;
			var(spec[nothing ], bool, _993_948 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_948 );
			if(_993_948 )
			{
				_999_948 = true;
			}
			else
			{
				_999_948 = _993_948;
			};
			if(_999_948 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_948 ) = rd;
			var(spec[nothing ], float3, param_18_948 ) = cp_948;
			var(spec[nothing ], float3, param_19_948 ) = cr_948;
			var(spec[nothing ], float3, param_20_948 ) = cn_948;
			var(spec[nothing ], float, param_21_948 ) = cd;
			var(spec[nothing ], float3, param_22_948 ) = oc;
			var(spec[nothing ], float, param_23_948 ) = oa;
			var(spec[nothing ], float, param_24_948 ) = io;
			var(spec[nothing ], float3, param_25_948 ) = ss;
			var(spec[nothing ], float3, param_26_948 ) = vb;
			var(spec[nothing ], int, param_27_948 ) = ec;
			var(spec[nothing ], float3, _1033_948 ) = px(param_17_948, param_18_948, param_19_948, param_20_948, param_21_948, param_22_948, param_23_948, param_24_948, param_25_948, param_26_948, param_27_948 );
			oc = param_22_948;
			oa = param_23_948;
			io = param_24_948;
			ss = param_25_948;
			vb = param_26_948;
			ec = param_27_948;
			var(spec[nothing ], float3, cc_948 ) = _1033_948;
			fc += (float4(cc_948 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 40;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_957 ) = ro;
			var(spec[nothing ], float3, param_1_957 ) = rd;
			var(spec[nothing ], float3, param_2_957 ) = oc;
			var(spec[nothing ], float, param_3_957 ) = oa;
			var(spec[nothing ], float, param_4_957 ) = cd;
			var(spec[nothing ], float, param_5_957 ) = td;
			var(spec[nothing ], float, param_6_957 ) = io;
			var(spec[nothing ], float3, param_7_957 ) = ss;
			var(spec[nothing ], float3, param_8_957 ) = vb;
			var(spec[nothing ], int, param_9_957 ) = ec;
			tr(param_957, param_1_957, param_2_957, param_3_957, param_4_957, param_5_957, param_6_957, param_7_957, param_8_957, param_9_957 );
			oc = param_2_957;
			oa = param_3_957;
			cd = param_4_957;
			td = param_5_957;
			io = param_6_957;
			ss = param_7_957;
			vb = param_8_957;
			ec = param_9_957;
			var(spec[nothing ], float3, cp_957 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_957 ) = cp_957;
			var(spec[nothing ], float3, param_11_957 ) = oc;
			var(spec[nothing ], float, param_12_957 ) = oa;
			var(spec[nothing ], float, param_13_957 ) = io;
			var(spec[nothing ], float3, param_14_957 ) = ss;
			var(spec[nothing ], float3, param_15_957 ) = vb;
			var(spec[nothing ], int, param_16_957 ) = ec;
			var(spec[nothing ], float3, _940_957 ) = nm(param_10_957, param_11_957, param_12_957, param_13_957, param_14_957, param_15_957, param_16_957 );
			oc = param_11_957;
			oa = param_12_957;
			io = param_13_957;
			ss = param_14_957;
			vb = param_15_957;
			ec = param_16_957;
			var(spec[nothing ], float3, cn_957 ) = _940_957;
			ro = cp_957 - (cn_957 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_957 ) = refract(rd, cn_957, _958 );
			if((length(cr_957 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_957 = reflect(rd, cn_957 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_957;
			};
			es -- ;
			var(spec[nothing ], bool, _993_957 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_957 );
			if(_993_957 )
			{
				_999_957 = false;
			}
			else
			{
				_999_957 = _993_957;
			};
			if(_999_957 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_957 ) = rd;
			var(spec[nothing ], float3, param_18_957 ) = cp_957;
			var(spec[nothing ], float3, param_19_957 ) = cr_957;
			var(spec[nothing ], float3, param_20_957 ) = cn_957;
			var(spec[nothing ], float, param_21_957 ) = cd;
			var(spec[nothing ], float3, param_22_957 ) = oc;
			var(spec[nothing ], float, param_23_957 ) = oa;
			var(spec[nothing ], float, param_24_957 ) = io;
			var(spec[nothing ], float3, param_25_957 ) = ss;
			var(spec[nothing ], float3, param_26_957 ) = vb;
			var(spec[nothing ], int, param_27_957 ) = ec;
			var(spec[nothing ], float3, _1033_957 ) = px(param_17_957, param_18_957, param_19_957, param_20_957, param_21_957, param_22_957, param_23_957, param_24_957, param_25_957, param_26_957, param_27_957 );
			oc = param_22_957;
			oa = param_23_957;
			io = param_24_957;
			ss = param_25_957;
			vb = param_26_957;
			ec = param_27_957;
			var(spec[nothing ], float3, cc_957 ) = _1033_957;
			fc += (float4(cc_957 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 41;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_966 ) = ro;
			var(spec[nothing ], float3, param_1_966 ) = rd;
			var(spec[nothing ], float3, param_2_966 ) = oc;
			var(spec[nothing ], float, param_3_966 ) = oa;
			var(spec[nothing ], float, param_4_966 ) = cd;
			var(spec[nothing ], float, param_5_966 ) = td;
			var(spec[nothing ], float, param_6_966 ) = io;
			var(spec[nothing ], float3, param_7_966 ) = ss;
			var(spec[nothing ], float3, param_8_966 ) = vb;
			var(spec[nothing ], int, param_9_966 ) = ec;
			tr(param_966, param_1_966, param_2_966, param_3_966, param_4_966, param_5_966, param_6_966, param_7_966, param_8_966, param_9_966 );
			oc = param_2_966;
			oa = param_3_966;
			cd = param_4_966;
			td = param_5_966;
			io = param_6_966;
			ss = param_7_966;
			vb = param_8_966;
			ec = param_9_966;
			var(spec[nothing ], float3, cp_966 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_966 ) = cp_966;
			var(spec[nothing ], float3, param_11_966 ) = oc;
			var(spec[nothing ], float, param_12_966 ) = oa;
			var(spec[nothing ], float, param_13_966 ) = io;
			var(spec[nothing ], float3, param_14_966 ) = ss;
			var(spec[nothing ], float3, param_15_966 ) = vb;
			var(spec[nothing ], int, param_16_966 ) = ec;
			var(spec[nothing ], float3, _940_966 ) = nm(param_10_966, param_11_966, param_12_966, param_13_966, param_14_966, param_15_966, param_16_966 );
			oc = param_11_966;
			oa = param_12_966;
			io = param_13_966;
			ss = param_14_966;
			vb = param_15_966;
			ec = param_16_966;
			var(spec[nothing ], float3, cn_966 ) = _940_966;
			ro = cp_966 - (cn_966 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_966 ) = refract(rd, cn_966, _958 );
			if((length(cr_966 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_966 = reflect(rd, cn_966 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_966;
			};
			es -- ;
			var(spec[nothing ], bool, _993_966 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_966 );
			if(_993_966 )
			{
				_999_966 = true;
			}
			else
			{
				_999_966 = _993_966;
			};
			if(_999_966 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_966 ) = rd;
			var(spec[nothing ], float3, param_18_966 ) = cp_966;
			var(spec[nothing ], float3, param_19_966 ) = cr_966;
			var(spec[nothing ], float3, param_20_966 ) = cn_966;
			var(spec[nothing ], float, param_21_966 ) = cd;
			var(spec[nothing ], float3, param_22_966 ) = oc;
			var(spec[nothing ], float, param_23_966 ) = oa;
			var(spec[nothing ], float, param_24_966 ) = io;
			var(spec[nothing ], float3, param_25_966 ) = ss;
			var(spec[nothing ], float3, param_26_966 ) = vb;
			var(spec[nothing ], int, param_27_966 ) = ec;
			var(spec[nothing ], float3, _1033_966 ) = px(param_17_966, param_18_966, param_19_966, param_20_966, param_21_966, param_22_966, param_23_966, param_24_966, param_25_966, param_26_966, param_27_966 );
			oc = param_22_966;
			oa = param_23_966;
			io = param_24_966;
			ss = param_25_966;
			vb = param_26_966;
			ec = param_27_966;
			var(spec[nothing ], float3, cc_966 ) = _1033_966;
			fc += (float4(cc_966 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 42;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_975 ) = ro;
			var(spec[nothing ], float3, param_1_975 ) = rd;
			var(spec[nothing ], float3, param_2_975 ) = oc;
			var(spec[nothing ], float, param_3_975 ) = oa;
			var(spec[nothing ], float, param_4_975 ) = cd;
			var(spec[nothing ], float, param_5_975 ) = td;
			var(spec[nothing ], float, param_6_975 ) = io;
			var(spec[nothing ], float3, param_7_975 ) = ss;
			var(spec[nothing ], float3, param_8_975 ) = vb;
			var(spec[nothing ], int, param_9_975 ) = ec;
			tr(param_975, param_1_975, param_2_975, param_3_975, param_4_975, param_5_975, param_6_975, param_7_975, param_8_975, param_9_975 );
			oc = param_2_975;
			oa = param_3_975;
			cd = param_4_975;
			td = param_5_975;
			io = param_6_975;
			ss = param_7_975;
			vb = param_8_975;
			ec = param_9_975;
			var(spec[nothing ], float3, cp_975 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_975 ) = cp_975;
			var(spec[nothing ], float3, param_11_975 ) = oc;
			var(spec[nothing ], float, param_12_975 ) = oa;
			var(spec[nothing ], float, param_13_975 ) = io;
			var(spec[nothing ], float3, param_14_975 ) = ss;
			var(spec[nothing ], float3, param_15_975 ) = vb;
			var(spec[nothing ], int, param_16_975 ) = ec;
			var(spec[nothing ], float3, _940_975 ) = nm(param_10_975, param_11_975, param_12_975, param_13_975, param_14_975, param_15_975, param_16_975 );
			oc = param_11_975;
			oa = param_12_975;
			io = param_13_975;
			ss = param_14_975;
			vb = param_15_975;
			ec = param_16_975;
			var(spec[nothing ], float3, cn_975 ) = _940_975;
			ro = cp_975 - (cn_975 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_975 ) = refract(rd, cn_975, _958 );
			if((length(cr_975 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_975 = reflect(rd, cn_975 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_975;
			};
			es -- ;
			var(spec[nothing ], bool, _993_975 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_975 );
			if(_993_975 )
			{
				_999_975 = false;
			}
			else
			{
				_999_975 = _993_975;
			};
			if(_999_975 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_975 ) = rd;
			var(spec[nothing ], float3, param_18_975 ) = cp_975;
			var(spec[nothing ], float3, param_19_975 ) = cr_975;
			var(spec[nothing ], float3, param_20_975 ) = cn_975;
			var(spec[nothing ], float, param_21_975 ) = cd;
			var(spec[nothing ], float3, param_22_975 ) = oc;
			var(spec[nothing ], float, param_23_975 ) = oa;
			var(spec[nothing ], float, param_24_975 ) = io;
			var(spec[nothing ], float3, param_25_975 ) = ss;
			var(spec[nothing ], float3, param_26_975 ) = vb;
			var(spec[nothing ], int, param_27_975 ) = ec;
			var(spec[nothing ], float3, _1033_975 ) = px(param_17_975, param_18_975, param_19_975, param_20_975, param_21_975, param_22_975, param_23_975, param_24_975, param_25_975, param_26_975, param_27_975 );
			oc = param_22_975;
			oa = param_23_975;
			io = param_24_975;
			ss = param_25_975;
			vb = param_26_975;
			ec = param_27_975;
			var(spec[nothing ], float3, cc_975 ) = _1033_975;
			fc += (float4(cc_975 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 43;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_984 ) = ro;
			var(spec[nothing ], float3, param_1_984 ) = rd;
			var(spec[nothing ], float3, param_2_984 ) = oc;
			var(spec[nothing ], float, param_3_984 ) = oa;
			var(spec[nothing ], float, param_4_984 ) = cd;
			var(spec[nothing ], float, param_5_984 ) = td;
			var(spec[nothing ], float, param_6_984 ) = io;
			var(spec[nothing ], float3, param_7_984 ) = ss;
			var(spec[nothing ], float3, param_8_984 ) = vb;
			var(spec[nothing ], int, param_9_984 ) = ec;
			tr(param_984, param_1_984, param_2_984, param_3_984, param_4_984, param_5_984, param_6_984, param_7_984, param_8_984, param_9_984 );
			oc = param_2_984;
			oa = param_3_984;
			cd = param_4_984;
			td = param_5_984;
			io = param_6_984;
			ss = param_7_984;
			vb = param_8_984;
			ec = param_9_984;
			var(spec[nothing ], float3, cp_984 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_984 ) = cp_984;
			var(spec[nothing ], float3, param_11_984 ) = oc;
			var(spec[nothing ], float, param_12_984 ) = oa;
			var(spec[nothing ], float, param_13_984 ) = io;
			var(spec[nothing ], float3, param_14_984 ) = ss;
			var(spec[nothing ], float3, param_15_984 ) = vb;
			var(spec[nothing ], int, param_16_984 ) = ec;
			var(spec[nothing ], float3, _940_984 ) = nm(param_10_984, param_11_984, param_12_984, param_13_984, param_14_984, param_15_984, param_16_984 );
			oc = param_11_984;
			oa = param_12_984;
			io = param_13_984;
			ss = param_14_984;
			vb = param_15_984;
			ec = param_16_984;
			var(spec[nothing ], float3, cn_984 ) = _940_984;
			ro = cp_984 - (cn_984 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_984 ) = refract(rd, cn_984, _958 );
			if((length(cr_984 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_984 = reflect(rd, cn_984 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_984;
			};
			es -- ;
			var(spec[nothing ], bool, _993_984 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_984 );
			if(_993_984 )
			{
				_999_984 = true;
			}
			else
			{
				_999_984 = _993_984;
			};
			if(_999_984 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_984 ) = rd;
			var(spec[nothing ], float3, param_18_984 ) = cp_984;
			var(spec[nothing ], float3, param_19_984 ) = cr_984;
			var(spec[nothing ], float3, param_20_984 ) = cn_984;
			var(spec[nothing ], float, param_21_984 ) = cd;
			var(spec[nothing ], float3, param_22_984 ) = oc;
			var(spec[nothing ], float, param_23_984 ) = oa;
			var(spec[nothing ], float, param_24_984 ) = io;
			var(spec[nothing ], float3, param_25_984 ) = ss;
			var(spec[nothing ], float3, param_26_984 ) = vb;
			var(spec[nothing ], int, param_27_984 ) = ec;
			var(spec[nothing ], float3, _1033_984 ) = px(param_17_984, param_18_984, param_19_984, param_20_984, param_21_984, param_22_984, param_23_984, param_24_984, param_25_984, param_26_984, param_27_984 );
			oc = param_22_984;
			oa = param_23_984;
			io = param_24_984;
			ss = param_25_984;
			vb = param_26_984;
			ec = param_27_984;
			var(spec[nothing ], float3, cc_984 ) = _1033_984;
			fc += (float4(cc_984 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 44;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_993 ) = ro;
			var(spec[nothing ], float3, param_1_993 ) = rd;
			var(spec[nothing ], float3, param_2_993 ) = oc;
			var(spec[nothing ], float, param_3_993 ) = oa;
			var(spec[nothing ], float, param_4_993 ) = cd;
			var(spec[nothing ], float, param_5_993 ) = td;
			var(spec[nothing ], float, param_6_993 ) = io;
			var(spec[nothing ], float3, param_7_993 ) = ss;
			var(spec[nothing ], float3, param_8_993 ) = vb;
			var(spec[nothing ], int, param_9_993 ) = ec;
			tr(param_993, param_1_993, param_2_993, param_3_993, param_4_993, param_5_993, param_6_993, param_7_993, param_8_993, param_9_993 );
			oc = param_2_993;
			oa = param_3_993;
			cd = param_4_993;
			td = param_5_993;
			io = param_6_993;
			ss = param_7_993;
			vb = param_8_993;
			ec = param_9_993;
			var(spec[nothing ], float3, cp_993 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_993 ) = cp_993;
			var(spec[nothing ], float3, param_11_993 ) = oc;
			var(spec[nothing ], float, param_12_993 ) = oa;
			var(spec[nothing ], float, param_13_993 ) = io;
			var(spec[nothing ], float3, param_14_993 ) = ss;
			var(spec[nothing ], float3, param_15_993 ) = vb;
			var(spec[nothing ], int, param_16_993 ) = ec;
			var(spec[nothing ], float3, _940_993 ) = nm(param_10_993, param_11_993, param_12_993, param_13_993, param_14_993, param_15_993, param_16_993 );
			oc = param_11_993;
			oa = param_12_993;
			io = param_13_993;
			ss = param_14_993;
			vb = param_15_993;
			ec = param_16_993;
			var(spec[nothing ], float3, cn_993 ) = _940_993;
			ro = cp_993 - (cn_993 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_993 ) = refract(rd, cn_993, _958 );
			if((length(cr_993 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_993 = reflect(rd, cn_993 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_993;
			};
			es -- ;
			var(spec[nothing ], bool, _993_993 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_993 );
			if(_993_993 )
			{
				_999_993 = false;
			}
			else
			{
				_999_993 = _993_993;
			};
			if(_999_993 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_993 ) = rd;
			var(spec[nothing ], float3, param_18_993 ) = cp_993;
			var(spec[nothing ], float3, param_19_993 ) = cr_993;
			var(spec[nothing ], float3, param_20_993 ) = cn_993;
			var(spec[nothing ], float, param_21_993 ) = cd;
			var(spec[nothing ], float3, param_22_993 ) = oc;
			var(spec[nothing ], float, param_23_993 ) = oa;
			var(spec[nothing ], float, param_24_993 ) = io;
			var(spec[nothing ], float3, param_25_993 ) = ss;
			var(spec[nothing ], float3, param_26_993 ) = vb;
			var(spec[nothing ], int, param_27_993 ) = ec;
			var(spec[nothing ], float3, _1033_993 ) = px(param_17_993, param_18_993, param_19_993, param_20_993, param_21_993, param_22_993, param_23_993, param_24_993, param_25_993, param_26_993, param_27_993 );
			oc = param_22_993;
			oa = param_23_993;
			io = param_24_993;
			ss = param_25_993;
			vb = param_26_993;
			ec = param_27_993;
			var(spec[nothing ], float3, cc_993 ) = _1033_993;
			fc += (float4(cc_993 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 45;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1002 ) = ro;
			var(spec[nothing ], float3, param_1_1002 ) = rd;
			var(spec[nothing ], float3, param_2_1002 ) = oc;
			var(spec[nothing ], float, param_3_1002 ) = oa;
			var(spec[nothing ], float, param_4_1002 ) = cd;
			var(spec[nothing ], float, param_5_1002 ) = td;
			var(spec[nothing ], float, param_6_1002 ) = io;
			var(spec[nothing ], float3, param_7_1002 ) = ss;
			var(spec[nothing ], float3, param_8_1002 ) = vb;
			var(spec[nothing ], int, param_9_1002 ) = ec;
			tr(param_1002, param_1_1002, param_2_1002, param_3_1002, param_4_1002, param_5_1002, param_6_1002, param_7_1002, param_8_1002, param_9_1002 );
			oc = param_2_1002;
			oa = param_3_1002;
			cd = param_4_1002;
			td = param_5_1002;
			io = param_6_1002;
			ss = param_7_1002;
			vb = param_8_1002;
			ec = param_9_1002;
			var(spec[nothing ], float3, cp_1002 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1002 ) = cp_1002;
			var(spec[nothing ], float3, param_11_1002 ) = oc;
			var(spec[nothing ], float, param_12_1002 ) = oa;
			var(spec[nothing ], float, param_13_1002 ) = io;
			var(spec[nothing ], float3, param_14_1002 ) = ss;
			var(spec[nothing ], float3, param_15_1002 ) = vb;
			var(spec[nothing ], int, param_16_1002 ) = ec;
			var(spec[nothing ], float3, _940_1002 ) = nm(param_10_1002, param_11_1002, param_12_1002, param_13_1002, param_14_1002, param_15_1002, param_16_1002 );
			oc = param_11_1002;
			oa = param_12_1002;
			io = param_13_1002;
			ss = param_14_1002;
			vb = param_15_1002;
			ec = param_16_1002;
			var(spec[nothing ], float3, cn_1002 ) = _940_1002;
			ro = cp_1002 - (cn_1002 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1002 ) = refract(rd, cn_1002, _958 );
			if((length(cr_1002 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1002 = reflect(rd, cn_1002 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1002;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1002 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1002 );
			if(_993_1002 )
			{
				_999_1002 = true;
			}
			else
			{
				_999_1002 = _993_1002;
			};
			if(_999_1002 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1002 ) = rd;
			var(spec[nothing ], float3, param_18_1002 ) = cp_1002;
			var(spec[nothing ], float3, param_19_1002 ) = cr_1002;
			var(spec[nothing ], float3, param_20_1002 ) = cn_1002;
			var(spec[nothing ], float, param_21_1002 ) = cd;
			var(spec[nothing ], float3, param_22_1002 ) = oc;
			var(spec[nothing ], float, param_23_1002 ) = oa;
			var(spec[nothing ], float, param_24_1002 ) = io;
			var(spec[nothing ], float3, param_25_1002 ) = ss;
			var(spec[nothing ], float3, param_26_1002 ) = vb;
			var(spec[nothing ], int, param_27_1002 ) = ec;
			var(spec[nothing ], float3, _1033_1002 ) = px(param_17_1002, param_18_1002, param_19_1002, param_20_1002, param_21_1002, param_22_1002, param_23_1002, param_24_1002, param_25_1002, param_26_1002, param_27_1002 );
			oc = param_22_1002;
			oa = param_23_1002;
			io = param_24_1002;
			ss = param_25_1002;
			vb = param_26_1002;
			ec = param_27_1002;
			var(spec[nothing ], float3, cc_1002 ) = _1033_1002;
			fc += (float4(cc_1002 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 46;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1011 ) = ro;
			var(spec[nothing ], float3, param_1_1011 ) = rd;
			var(spec[nothing ], float3, param_2_1011 ) = oc;
			var(spec[nothing ], float, param_3_1011 ) = oa;
			var(spec[nothing ], float, param_4_1011 ) = cd;
			var(spec[nothing ], float, param_5_1011 ) = td;
			var(spec[nothing ], float, param_6_1011 ) = io;
			var(spec[nothing ], float3, param_7_1011 ) = ss;
			var(spec[nothing ], float3, param_8_1011 ) = vb;
			var(spec[nothing ], int, param_9_1011 ) = ec;
			tr(param_1011, param_1_1011, param_2_1011, param_3_1011, param_4_1011, param_5_1011, param_6_1011, param_7_1011, param_8_1011, param_9_1011 );
			oc = param_2_1011;
			oa = param_3_1011;
			cd = param_4_1011;
			td = param_5_1011;
			io = param_6_1011;
			ss = param_7_1011;
			vb = param_8_1011;
			ec = param_9_1011;
			var(spec[nothing ], float3, cp_1011 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1011 ) = cp_1011;
			var(spec[nothing ], float3, param_11_1011 ) = oc;
			var(spec[nothing ], float, param_12_1011 ) = oa;
			var(spec[nothing ], float, param_13_1011 ) = io;
			var(spec[nothing ], float3, param_14_1011 ) = ss;
			var(spec[nothing ], float3, param_15_1011 ) = vb;
			var(spec[nothing ], int, param_16_1011 ) = ec;
			var(spec[nothing ], float3, _940_1011 ) = nm(param_10_1011, param_11_1011, param_12_1011, param_13_1011, param_14_1011, param_15_1011, param_16_1011 );
			oc = param_11_1011;
			oa = param_12_1011;
			io = param_13_1011;
			ss = param_14_1011;
			vb = param_15_1011;
			ec = param_16_1011;
			var(spec[nothing ], float3, cn_1011 ) = _940_1011;
			ro = cp_1011 - (cn_1011 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1011 ) = refract(rd, cn_1011, _958 );
			if((length(cr_1011 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1011 = reflect(rd, cn_1011 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1011;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1011 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1011 );
			if(_993_1011 )
			{
				_999_1011 = false;
			}
			else
			{
				_999_1011 = _993_1011;
			};
			if(_999_1011 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1011 ) = rd;
			var(spec[nothing ], float3, param_18_1011 ) = cp_1011;
			var(spec[nothing ], float3, param_19_1011 ) = cr_1011;
			var(spec[nothing ], float3, param_20_1011 ) = cn_1011;
			var(spec[nothing ], float, param_21_1011 ) = cd;
			var(spec[nothing ], float3, param_22_1011 ) = oc;
			var(spec[nothing ], float, param_23_1011 ) = oa;
			var(spec[nothing ], float, param_24_1011 ) = io;
			var(spec[nothing ], float3, param_25_1011 ) = ss;
			var(spec[nothing ], float3, param_26_1011 ) = vb;
			var(spec[nothing ], int, param_27_1011 ) = ec;
			var(spec[nothing ], float3, _1033_1011 ) = px(param_17_1011, param_18_1011, param_19_1011, param_20_1011, param_21_1011, param_22_1011, param_23_1011, param_24_1011, param_25_1011, param_26_1011, param_27_1011 );
			oc = param_22_1011;
			oa = param_23_1011;
			io = param_24_1011;
			ss = param_25_1011;
			vb = param_26_1011;
			ec = param_27_1011;
			var(spec[nothing ], float3, cc_1011 ) = _1033_1011;
			fc += (float4(cc_1011 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 47;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1020 ) = ro;
			var(spec[nothing ], float3, param_1_1020 ) = rd;
			var(spec[nothing ], float3, param_2_1020 ) = oc;
			var(spec[nothing ], float, param_3_1020 ) = oa;
			var(spec[nothing ], float, param_4_1020 ) = cd;
			var(spec[nothing ], float, param_5_1020 ) = td;
			var(spec[nothing ], float, param_6_1020 ) = io;
			var(spec[nothing ], float3, param_7_1020 ) = ss;
			var(spec[nothing ], float3, param_8_1020 ) = vb;
			var(spec[nothing ], int, param_9_1020 ) = ec;
			tr(param_1020, param_1_1020, param_2_1020, param_3_1020, param_4_1020, param_5_1020, param_6_1020, param_7_1020, param_8_1020, param_9_1020 );
			oc = param_2_1020;
			oa = param_3_1020;
			cd = param_4_1020;
			td = param_5_1020;
			io = param_6_1020;
			ss = param_7_1020;
			vb = param_8_1020;
			ec = param_9_1020;
			var(spec[nothing ], float3, cp_1020 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1020 ) = cp_1020;
			var(spec[nothing ], float3, param_11_1020 ) = oc;
			var(spec[nothing ], float, param_12_1020 ) = oa;
			var(spec[nothing ], float, param_13_1020 ) = io;
			var(spec[nothing ], float3, param_14_1020 ) = ss;
			var(spec[nothing ], float3, param_15_1020 ) = vb;
			var(spec[nothing ], int, param_16_1020 ) = ec;
			var(spec[nothing ], float3, _940_1020 ) = nm(param_10_1020, param_11_1020, param_12_1020, param_13_1020, param_14_1020, param_15_1020, param_16_1020 );
			oc = param_11_1020;
			oa = param_12_1020;
			io = param_13_1020;
			ss = param_14_1020;
			vb = param_15_1020;
			ec = param_16_1020;
			var(spec[nothing ], float3, cn_1020 ) = _940_1020;
			ro = cp_1020 - (cn_1020 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1020 ) = refract(rd, cn_1020, _958 );
			if((length(cr_1020 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1020 = reflect(rd, cn_1020 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1020;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1020 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1020 );
			if(_993_1020 )
			{
				_999_1020 = true;
			}
			else
			{
				_999_1020 = _993_1020;
			};
			if(_999_1020 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1020 ) = rd;
			var(spec[nothing ], float3, param_18_1020 ) = cp_1020;
			var(spec[nothing ], float3, param_19_1020 ) = cr_1020;
			var(spec[nothing ], float3, param_20_1020 ) = cn_1020;
			var(spec[nothing ], float, param_21_1020 ) = cd;
			var(spec[nothing ], float3, param_22_1020 ) = oc;
			var(spec[nothing ], float, param_23_1020 ) = oa;
			var(spec[nothing ], float, param_24_1020 ) = io;
			var(spec[nothing ], float3, param_25_1020 ) = ss;
			var(spec[nothing ], float3, param_26_1020 ) = vb;
			var(spec[nothing ], int, param_27_1020 ) = ec;
			var(spec[nothing ], float3, _1033_1020 ) = px(param_17_1020, param_18_1020, param_19_1020, param_20_1020, param_21_1020, param_22_1020, param_23_1020, param_24_1020, param_25_1020, param_26_1020, param_27_1020 );
			oc = param_22_1020;
			oa = param_23_1020;
			io = param_24_1020;
			ss = param_25_1020;
			vb = param_26_1020;
			ec = param_27_1020;
			var(spec[nothing ], float3, cc_1020 ) = _1033_1020;
			fc += (float4(cc_1020 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 48;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1029 ) = ro;
			var(spec[nothing ], float3, param_1_1029 ) = rd;
			var(spec[nothing ], float3, param_2_1029 ) = oc;
			var(spec[nothing ], float, param_3_1029 ) = oa;
			var(spec[nothing ], float, param_4_1029 ) = cd;
			var(spec[nothing ], float, param_5_1029 ) = td;
			var(spec[nothing ], float, param_6_1029 ) = io;
			var(spec[nothing ], float3, param_7_1029 ) = ss;
			var(spec[nothing ], float3, param_8_1029 ) = vb;
			var(spec[nothing ], int, param_9_1029 ) = ec;
			tr(param_1029, param_1_1029, param_2_1029, param_3_1029, param_4_1029, param_5_1029, param_6_1029, param_7_1029, param_8_1029, param_9_1029 );
			oc = param_2_1029;
			oa = param_3_1029;
			cd = param_4_1029;
			td = param_5_1029;
			io = param_6_1029;
			ss = param_7_1029;
			vb = param_8_1029;
			ec = param_9_1029;
			var(spec[nothing ], float3, cp_1029 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1029 ) = cp_1029;
			var(spec[nothing ], float3, param_11_1029 ) = oc;
			var(spec[nothing ], float, param_12_1029 ) = oa;
			var(spec[nothing ], float, param_13_1029 ) = io;
			var(spec[nothing ], float3, param_14_1029 ) = ss;
			var(spec[nothing ], float3, param_15_1029 ) = vb;
			var(spec[nothing ], int, param_16_1029 ) = ec;
			var(spec[nothing ], float3, _940_1029 ) = nm(param_10_1029, param_11_1029, param_12_1029, param_13_1029, param_14_1029, param_15_1029, param_16_1029 );
			oc = param_11_1029;
			oa = param_12_1029;
			io = param_13_1029;
			ss = param_14_1029;
			vb = param_15_1029;
			ec = param_16_1029;
			var(spec[nothing ], float3, cn_1029 ) = _940_1029;
			ro = cp_1029 - (cn_1029 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1029 ) = refract(rd, cn_1029, _958 );
			if((length(cr_1029 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1029 = reflect(rd, cn_1029 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1029;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1029 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1029 );
			if(_993_1029 )
			{
				_999_1029 = false;
			}
			else
			{
				_999_1029 = _993_1029;
			};
			if(_999_1029 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1029 ) = rd;
			var(spec[nothing ], float3, param_18_1029 ) = cp_1029;
			var(spec[nothing ], float3, param_19_1029 ) = cr_1029;
			var(spec[nothing ], float3, param_20_1029 ) = cn_1029;
			var(spec[nothing ], float, param_21_1029 ) = cd;
			var(spec[nothing ], float3, param_22_1029 ) = oc;
			var(spec[nothing ], float, param_23_1029 ) = oa;
			var(spec[nothing ], float, param_24_1029 ) = io;
			var(spec[nothing ], float3, param_25_1029 ) = ss;
			var(spec[nothing ], float3, param_26_1029 ) = vb;
			var(spec[nothing ], int, param_27_1029 ) = ec;
			var(spec[nothing ], float3, _1033_1029 ) = px(param_17_1029, param_18_1029, param_19_1029, param_20_1029, param_21_1029, param_22_1029, param_23_1029, param_24_1029, param_25_1029, param_26_1029, param_27_1029 );
			oc = param_22_1029;
			oa = param_23_1029;
			io = param_24_1029;
			ss = param_25_1029;
			vb = param_26_1029;
			ec = param_27_1029;
			var(spec[nothing ], float3, cc_1029 ) = _1033_1029;
			fc += (float4(cc_1029 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 49;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1038 ) = ro;
			var(spec[nothing ], float3, param_1_1038 ) = rd;
			var(spec[nothing ], float3, param_2_1038 ) = oc;
			var(spec[nothing ], float, param_3_1038 ) = oa;
			var(spec[nothing ], float, param_4_1038 ) = cd;
			var(spec[nothing ], float, param_5_1038 ) = td;
			var(spec[nothing ], float, param_6_1038 ) = io;
			var(spec[nothing ], float3, param_7_1038 ) = ss;
			var(spec[nothing ], float3, param_8_1038 ) = vb;
			var(spec[nothing ], int, param_9_1038 ) = ec;
			tr(param_1038, param_1_1038, param_2_1038, param_3_1038, param_4_1038, param_5_1038, param_6_1038, param_7_1038, param_8_1038, param_9_1038 );
			oc = param_2_1038;
			oa = param_3_1038;
			cd = param_4_1038;
			td = param_5_1038;
			io = param_6_1038;
			ss = param_7_1038;
			vb = param_8_1038;
			ec = param_9_1038;
			var(spec[nothing ], float3, cp_1038 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1038 ) = cp_1038;
			var(spec[nothing ], float3, param_11_1038 ) = oc;
			var(spec[nothing ], float, param_12_1038 ) = oa;
			var(spec[nothing ], float, param_13_1038 ) = io;
			var(spec[nothing ], float3, param_14_1038 ) = ss;
			var(spec[nothing ], float3, param_15_1038 ) = vb;
			var(spec[nothing ], int, param_16_1038 ) = ec;
			var(spec[nothing ], float3, _940_1038 ) = nm(param_10_1038, param_11_1038, param_12_1038, param_13_1038, param_14_1038, param_15_1038, param_16_1038 );
			oc = param_11_1038;
			oa = param_12_1038;
			io = param_13_1038;
			ss = param_14_1038;
			vb = param_15_1038;
			ec = param_16_1038;
			var(spec[nothing ], float3, cn_1038 ) = _940_1038;
			ro = cp_1038 - (cn_1038 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1038 ) = refract(rd, cn_1038, _958 );
			if((length(cr_1038 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1038 = reflect(rd, cn_1038 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1038;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1038 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1038 );
			if(_993_1038 )
			{
				_999_1038 = true;
			}
			else
			{
				_999_1038 = _993_1038;
			};
			if(_999_1038 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1038 ) = rd;
			var(spec[nothing ], float3, param_18_1038 ) = cp_1038;
			var(spec[nothing ], float3, param_19_1038 ) = cr_1038;
			var(spec[nothing ], float3, param_20_1038 ) = cn_1038;
			var(spec[nothing ], float, param_21_1038 ) = cd;
			var(spec[nothing ], float3, param_22_1038 ) = oc;
			var(spec[nothing ], float, param_23_1038 ) = oa;
			var(spec[nothing ], float, param_24_1038 ) = io;
			var(spec[nothing ], float3, param_25_1038 ) = ss;
			var(spec[nothing ], float3, param_26_1038 ) = vb;
			var(spec[nothing ], int, param_27_1038 ) = ec;
			var(spec[nothing ], float3, _1033_1038 ) = px(param_17_1038, param_18_1038, param_19_1038, param_20_1038, param_21_1038, param_22_1038, param_23_1038, param_24_1038, param_25_1038, param_26_1038, param_27_1038 );
			oc = param_22_1038;
			oa = param_23_1038;
			io = param_24_1038;
			ss = param_25_1038;
			vb = param_26_1038;
			ec = param_27_1038;
			var(spec[nothing ], float3, cc_1038 ) = _1033_1038;
			fc += (float4(cc_1038 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 50;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1047 ) = ro;
			var(spec[nothing ], float3, param_1_1047 ) = rd;
			var(spec[nothing ], float3, param_2_1047 ) = oc;
			var(spec[nothing ], float, param_3_1047 ) = oa;
			var(spec[nothing ], float, param_4_1047 ) = cd;
			var(spec[nothing ], float, param_5_1047 ) = td;
			var(spec[nothing ], float, param_6_1047 ) = io;
			var(spec[nothing ], float3, param_7_1047 ) = ss;
			var(spec[nothing ], float3, param_8_1047 ) = vb;
			var(spec[nothing ], int, param_9_1047 ) = ec;
			tr(param_1047, param_1_1047, param_2_1047, param_3_1047, param_4_1047, param_5_1047, param_6_1047, param_7_1047, param_8_1047, param_9_1047 );
			oc = param_2_1047;
			oa = param_3_1047;
			cd = param_4_1047;
			td = param_5_1047;
			io = param_6_1047;
			ss = param_7_1047;
			vb = param_8_1047;
			ec = param_9_1047;
			var(spec[nothing ], float3, cp_1047 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1047 ) = cp_1047;
			var(spec[nothing ], float3, param_11_1047 ) = oc;
			var(spec[nothing ], float, param_12_1047 ) = oa;
			var(spec[nothing ], float, param_13_1047 ) = io;
			var(spec[nothing ], float3, param_14_1047 ) = ss;
			var(spec[nothing ], float3, param_15_1047 ) = vb;
			var(spec[nothing ], int, param_16_1047 ) = ec;
			var(spec[nothing ], float3, _940_1047 ) = nm(param_10_1047, param_11_1047, param_12_1047, param_13_1047, param_14_1047, param_15_1047, param_16_1047 );
			oc = param_11_1047;
			oa = param_12_1047;
			io = param_13_1047;
			ss = param_14_1047;
			vb = param_15_1047;
			ec = param_16_1047;
			var(spec[nothing ], float3, cn_1047 ) = _940_1047;
			ro = cp_1047 - (cn_1047 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1047 ) = refract(rd, cn_1047, _958 );
			if((length(cr_1047 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1047 = reflect(rd, cn_1047 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1047;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1047 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1047 );
			if(_993_1047 )
			{
				_999_1047 = false;
			}
			else
			{
				_999_1047 = _993_1047;
			};
			if(_999_1047 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1047 ) = rd;
			var(spec[nothing ], float3, param_18_1047 ) = cp_1047;
			var(spec[nothing ], float3, param_19_1047 ) = cr_1047;
			var(spec[nothing ], float3, param_20_1047 ) = cn_1047;
			var(spec[nothing ], float, param_21_1047 ) = cd;
			var(spec[nothing ], float3, param_22_1047 ) = oc;
			var(spec[nothing ], float, param_23_1047 ) = oa;
			var(spec[nothing ], float, param_24_1047 ) = io;
			var(spec[nothing ], float3, param_25_1047 ) = ss;
			var(spec[nothing ], float3, param_26_1047 ) = vb;
			var(spec[nothing ], int, param_27_1047 ) = ec;
			var(spec[nothing ], float3, _1033_1047 ) = px(param_17_1047, param_18_1047, param_19_1047, param_20_1047, param_21_1047, param_22_1047, param_23_1047, param_24_1047, param_25_1047, param_26_1047, param_27_1047 );
			oc = param_22_1047;
			oa = param_23_1047;
			io = param_24_1047;
			ss = param_25_1047;
			vb = param_26_1047;
			ec = param_27_1047;
			var(spec[nothing ], float3, cc_1047 ) = _1033_1047;
			fc += (float4(cc_1047 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 51;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1056 ) = ro;
			var(spec[nothing ], float3, param_1_1056 ) = rd;
			var(spec[nothing ], float3, param_2_1056 ) = oc;
			var(spec[nothing ], float, param_3_1056 ) = oa;
			var(spec[nothing ], float, param_4_1056 ) = cd;
			var(spec[nothing ], float, param_5_1056 ) = td;
			var(spec[nothing ], float, param_6_1056 ) = io;
			var(spec[nothing ], float3, param_7_1056 ) = ss;
			var(spec[nothing ], float3, param_8_1056 ) = vb;
			var(spec[nothing ], int, param_9_1056 ) = ec;
			tr(param_1056, param_1_1056, param_2_1056, param_3_1056, param_4_1056, param_5_1056, param_6_1056, param_7_1056, param_8_1056, param_9_1056 );
			oc = param_2_1056;
			oa = param_3_1056;
			cd = param_4_1056;
			td = param_5_1056;
			io = param_6_1056;
			ss = param_7_1056;
			vb = param_8_1056;
			ec = param_9_1056;
			var(spec[nothing ], float3, cp_1056 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1056 ) = cp_1056;
			var(spec[nothing ], float3, param_11_1056 ) = oc;
			var(spec[nothing ], float, param_12_1056 ) = oa;
			var(spec[nothing ], float, param_13_1056 ) = io;
			var(spec[nothing ], float3, param_14_1056 ) = ss;
			var(spec[nothing ], float3, param_15_1056 ) = vb;
			var(spec[nothing ], int, param_16_1056 ) = ec;
			var(spec[nothing ], float3, _940_1056 ) = nm(param_10_1056, param_11_1056, param_12_1056, param_13_1056, param_14_1056, param_15_1056, param_16_1056 );
			oc = param_11_1056;
			oa = param_12_1056;
			io = param_13_1056;
			ss = param_14_1056;
			vb = param_15_1056;
			ec = param_16_1056;
			var(spec[nothing ], float3, cn_1056 ) = _940_1056;
			ro = cp_1056 - (cn_1056 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1056 ) = refract(rd, cn_1056, _958 );
			if((length(cr_1056 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1056 = reflect(rd, cn_1056 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1056;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1056 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1056 );
			if(_993_1056 )
			{
				_999_1056 = true;
			}
			else
			{
				_999_1056 = _993_1056;
			};
			if(_999_1056 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1056 ) = rd;
			var(spec[nothing ], float3, param_18_1056 ) = cp_1056;
			var(spec[nothing ], float3, param_19_1056 ) = cr_1056;
			var(spec[nothing ], float3, param_20_1056 ) = cn_1056;
			var(spec[nothing ], float, param_21_1056 ) = cd;
			var(spec[nothing ], float3, param_22_1056 ) = oc;
			var(spec[nothing ], float, param_23_1056 ) = oa;
			var(spec[nothing ], float, param_24_1056 ) = io;
			var(spec[nothing ], float3, param_25_1056 ) = ss;
			var(spec[nothing ], float3, param_26_1056 ) = vb;
			var(spec[nothing ], int, param_27_1056 ) = ec;
			var(spec[nothing ], float3, _1033_1056 ) = px(param_17_1056, param_18_1056, param_19_1056, param_20_1056, param_21_1056, param_22_1056, param_23_1056, param_24_1056, param_25_1056, param_26_1056, param_27_1056 );
			oc = param_22_1056;
			oa = param_23_1056;
			io = param_24_1056;
			ss = param_25_1056;
			vb = param_26_1056;
			ec = param_27_1056;
			var(spec[nothing ], float3, cc_1056 ) = _1033_1056;
			fc += (float4(cc_1056 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 52;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1065 ) = ro;
			var(spec[nothing ], float3, param_1_1065 ) = rd;
			var(spec[nothing ], float3, param_2_1065 ) = oc;
			var(spec[nothing ], float, param_3_1065 ) = oa;
			var(spec[nothing ], float, param_4_1065 ) = cd;
			var(spec[nothing ], float, param_5_1065 ) = td;
			var(spec[nothing ], float, param_6_1065 ) = io;
			var(spec[nothing ], float3, param_7_1065 ) = ss;
			var(spec[nothing ], float3, param_8_1065 ) = vb;
			var(spec[nothing ], int, param_9_1065 ) = ec;
			tr(param_1065, param_1_1065, param_2_1065, param_3_1065, param_4_1065, param_5_1065, param_6_1065, param_7_1065, param_8_1065, param_9_1065 );
			oc = param_2_1065;
			oa = param_3_1065;
			cd = param_4_1065;
			td = param_5_1065;
			io = param_6_1065;
			ss = param_7_1065;
			vb = param_8_1065;
			ec = param_9_1065;
			var(spec[nothing ], float3, cp_1065 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1065 ) = cp_1065;
			var(spec[nothing ], float3, param_11_1065 ) = oc;
			var(spec[nothing ], float, param_12_1065 ) = oa;
			var(spec[nothing ], float, param_13_1065 ) = io;
			var(spec[nothing ], float3, param_14_1065 ) = ss;
			var(spec[nothing ], float3, param_15_1065 ) = vb;
			var(spec[nothing ], int, param_16_1065 ) = ec;
			var(spec[nothing ], float3, _940_1065 ) = nm(param_10_1065, param_11_1065, param_12_1065, param_13_1065, param_14_1065, param_15_1065, param_16_1065 );
			oc = param_11_1065;
			oa = param_12_1065;
			io = param_13_1065;
			ss = param_14_1065;
			vb = param_15_1065;
			ec = param_16_1065;
			var(spec[nothing ], float3, cn_1065 ) = _940_1065;
			ro = cp_1065 - (cn_1065 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1065 ) = refract(rd, cn_1065, _958 );
			if((length(cr_1065 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1065 = reflect(rd, cn_1065 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1065;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1065 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1065 );
			if(_993_1065 )
			{
				_999_1065 = false;
			}
			else
			{
				_999_1065 = _993_1065;
			};
			if(_999_1065 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1065 ) = rd;
			var(spec[nothing ], float3, param_18_1065 ) = cp_1065;
			var(spec[nothing ], float3, param_19_1065 ) = cr_1065;
			var(spec[nothing ], float3, param_20_1065 ) = cn_1065;
			var(spec[nothing ], float, param_21_1065 ) = cd;
			var(spec[nothing ], float3, param_22_1065 ) = oc;
			var(spec[nothing ], float, param_23_1065 ) = oa;
			var(spec[nothing ], float, param_24_1065 ) = io;
			var(spec[nothing ], float3, param_25_1065 ) = ss;
			var(spec[nothing ], float3, param_26_1065 ) = vb;
			var(spec[nothing ], int, param_27_1065 ) = ec;
			var(spec[nothing ], float3, _1033_1065 ) = px(param_17_1065, param_18_1065, param_19_1065, param_20_1065, param_21_1065, param_22_1065, param_23_1065, param_24_1065, param_25_1065, param_26_1065, param_27_1065 );
			oc = param_22_1065;
			oa = param_23_1065;
			io = param_24_1065;
			ss = param_25_1065;
			vb = param_26_1065;
			ec = param_27_1065;
			var(spec[nothing ], float3, cc_1065 ) = _1033_1065;
			fc += (float4(cc_1065 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 53;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1074 ) = ro;
			var(spec[nothing ], float3, param_1_1074 ) = rd;
			var(spec[nothing ], float3, param_2_1074 ) = oc;
			var(spec[nothing ], float, param_3_1074 ) = oa;
			var(spec[nothing ], float, param_4_1074 ) = cd;
			var(spec[nothing ], float, param_5_1074 ) = td;
			var(spec[nothing ], float, param_6_1074 ) = io;
			var(spec[nothing ], float3, param_7_1074 ) = ss;
			var(spec[nothing ], float3, param_8_1074 ) = vb;
			var(spec[nothing ], int, param_9_1074 ) = ec;
			tr(param_1074, param_1_1074, param_2_1074, param_3_1074, param_4_1074, param_5_1074, param_6_1074, param_7_1074, param_8_1074, param_9_1074 );
			oc = param_2_1074;
			oa = param_3_1074;
			cd = param_4_1074;
			td = param_5_1074;
			io = param_6_1074;
			ss = param_7_1074;
			vb = param_8_1074;
			ec = param_9_1074;
			var(spec[nothing ], float3, cp_1074 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1074 ) = cp_1074;
			var(spec[nothing ], float3, param_11_1074 ) = oc;
			var(spec[nothing ], float, param_12_1074 ) = oa;
			var(spec[nothing ], float, param_13_1074 ) = io;
			var(spec[nothing ], float3, param_14_1074 ) = ss;
			var(spec[nothing ], float3, param_15_1074 ) = vb;
			var(spec[nothing ], int, param_16_1074 ) = ec;
			var(spec[nothing ], float3, _940_1074 ) = nm(param_10_1074, param_11_1074, param_12_1074, param_13_1074, param_14_1074, param_15_1074, param_16_1074 );
			oc = param_11_1074;
			oa = param_12_1074;
			io = param_13_1074;
			ss = param_14_1074;
			vb = param_15_1074;
			ec = param_16_1074;
			var(spec[nothing ], float3, cn_1074 ) = _940_1074;
			ro = cp_1074 - (cn_1074 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1074 ) = refract(rd, cn_1074, _958 );
			if((length(cr_1074 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1074 = reflect(rd, cn_1074 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1074;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1074 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1074 );
			if(_993_1074 )
			{
				_999_1074 = true;
			}
			else
			{
				_999_1074 = _993_1074;
			};
			if(_999_1074 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1074 ) = rd;
			var(spec[nothing ], float3, param_18_1074 ) = cp_1074;
			var(spec[nothing ], float3, param_19_1074 ) = cr_1074;
			var(spec[nothing ], float3, param_20_1074 ) = cn_1074;
			var(spec[nothing ], float, param_21_1074 ) = cd;
			var(spec[nothing ], float3, param_22_1074 ) = oc;
			var(spec[nothing ], float, param_23_1074 ) = oa;
			var(spec[nothing ], float, param_24_1074 ) = io;
			var(spec[nothing ], float3, param_25_1074 ) = ss;
			var(spec[nothing ], float3, param_26_1074 ) = vb;
			var(spec[nothing ], int, param_27_1074 ) = ec;
			var(spec[nothing ], float3, _1033_1074 ) = px(param_17_1074, param_18_1074, param_19_1074, param_20_1074, param_21_1074, param_22_1074, param_23_1074, param_24_1074, param_25_1074, param_26_1074, param_27_1074 );
			oc = param_22_1074;
			oa = param_23_1074;
			io = param_24_1074;
			ss = param_25_1074;
			vb = param_26_1074;
			ec = param_27_1074;
			var(spec[nothing ], float3, cc_1074 ) = _1033_1074;
			fc += (float4(cc_1074 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 54;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1083 ) = ro;
			var(spec[nothing ], float3, param_1_1083 ) = rd;
			var(spec[nothing ], float3, param_2_1083 ) = oc;
			var(spec[nothing ], float, param_3_1083 ) = oa;
			var(spec[nothing ], float, param_4_1083 ) = cd;
			var(spec[nothing ], float, param_5_1083 ) = td;
			var(spec[nothing ], float, param_6_1083 ) = io;
			var(spec[nothing ], float3, param_7_1083 ) = ss;
			var(spec[nothing ], float3, param_8_1083 ) = vb;
			var(spec[nothing ], int, param_9_1083 ) = ec;
			tr(param_1083, param_1_1083, param_2_1083, param_3_1083, param_4_1083, param_5_1083, param_6_1083, param_7_1083, param_8_1083, param_9_1083 );
			oc = param_2_1083;
			oa = param_3_1083;
			cd = param_4_1083;
			td = param_5_1083;
			io = param_6_1083;
			ss = param_7_1083;
			vb = param_8_1083;
			ec = param_9_1083;
			var(spec[nothing ], float3, cp_1083 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1083 ) = cp_1083;
			var(spec[nothing ], float3, param_11_1083 ) = oc;
			var(spec[nothing ], float, param_12_1083 ) = oa;
			var(spec[nothing ], float, param_13_1083 ) = io;
			var(spec[nothing ], float3, param_14_1083 ) = ss;
			var(spec[nothing ], float3, param_15_1083 ) = vb;
			var(spec[nothing ], int, param_16_1083 ) = ec;
			var(spec[nothing ], float3, _940_1083 ) = nm(param_10_1083, param_11_1083, param_12_1083, param_13_1083, param_14_1083, param_15_1083, param_16_1083 );
			oc = param_11_1083;
			oa = param_12_1083;
			io = param_13_1083;
			ss = param_14_1083;
			vb = param_15_1083;
			ec = param_16_1083;
			var(spec[nothing ], float3, cn_1083 ) = _940_1083;
			ro = cp_1083 - (cn_1083 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1083 ) = refract(rd, cn_1083, _958 );
			if((length(cr_1083 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1083 = reflect(rd, cn_1083 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1083;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1083 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1083 );
			if(_993_1083 )
			{
				_999_1083 = false;
			}
			else
			{
				_999_1083 = _993_1083;
			};
			if(_999_1083 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1083 ) = rd;
			var(spec[nothing ], float3, param_18_1083 ) = cp_1083;
			var(spec[nothing ], float3, param_19_1083 ) = cr_1083;
			var(spec[nothing ], float3, param_20_1083 ) = cn_1083;
			var(spec[nothing ], float, param_21_1083 ) = cd;
			var(spec[nothing ], float3, param_22_1083 ) = oc;
			var(spec[nothing ], float, param_23_1083 ) = oa;
			var(spec[nothing ], float, param_24_1083 ) = io;
			var(spec[nothing ], float3, param_25_1083 ) = ss;
			var(spec[nothing ], float3, param_26_1083 ) = vb;
			var(spec[nothing ], int, param_27_1083 ) = ec;
			var(spec[nothing ], float3, _1033_1083 ) = px(param_17_1083, param_18_1083, param_19_1083, param_20_1083, param_21_1083, param_22_1083, param_23_1083, param_24_1083, param_25_1083, param_26_1083, param_27_1083 );
			oc = param_22_1083;
			oa = param_23_1083;
			io = param_24_1083;
			ss = param_25_1083;
			vb = param_26_1083;
			ec = param_27_1083;
			var(spec[nothing ], float3, cc_1083 ) = _1033_1083;
			fc += (float4(cc_1083 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 55;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1092 ) = ro;
			var(spec[nothing ], float3, param_1_1092 ) = rd;
			var(spec[nothing ], float3, param_2_1092 ) = oc;
			var(spec[nothing ], float, param_3_1092 ) = oa;
			var(spec[nothing ], float, param_4_1092 ) = cd;
			var(spec[nothing ], float, param_5_1092 ) = td;
			var(spec[nothing ], float, param_6_1092 ) = io;
			var(spec[nothing ], float3, param_7_1092 ) = ss;
			var(spec[nothing ], float3, param_8_1092 ) = vb;
			var(spec[nothing ], int, param_9_1092 ) = ec;
			tr(param_1092, param_1_1092, param_2_1092, param_3_1092, param_4_1092, param_5_1092, param_6_1092, param_7_1092, param_8_1092, param_9_1092 );
			oc = param_2_1092;
			oa = param_3_1092;
			cd = param_4_1092;
			td = param_5_1092;
			io = param_6_1092;
			ss = param_7_1092;
			vb = param_8_1092;
			ec = param_9_1092;
			var(spec[nothing ], float3, cp_1092 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1092 ) = cp_1092;
			var(spec[nothing ], float3, param_11_1092 ) = oc;
			var(spec[nothing ], float, param_12_1092 ) = oa;
			var(spec[nothing ], float, param_13_1092 ) = io;
			var(spec[nothing ], float3, param_14_1092 ) = ss;
			var(spec[nothing ], float3, param_15_1092 ) = vb;
			var(spec[nothing ], int, param_16_1092 ) = ec;
			var(spec[nothing ], float3, _940_1092 ) = nm(param_10_1092, param_11_1092, param_12_1092, param_13_1092, param_14_1092, param_15_1092, param_16_1092 );
			oc = param_11_1092;
			oa = param_12_1092;
			io = param_13_1092;
			ss = param_14_1092;
			vb = param_15_1092;
			ec = param_16_1092;
			var(spec[nothing ], float3, cn_1092 ) = _940_1092;
			ro = cp_1092 - (cn_1092 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1092 ) = refract(rd, cn_1092, _958 );
			if((length(cr_1092 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1092 = reflect(rd, cn_1092 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1092;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1092 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1092 );
			if(_993_1092 )
			{
				_999_1092 = true;
			}
			else
			{
				_999_1092 = _993_1092;
			};
			if(_999_1092 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1092 ) = rd;
			var(spec[nothing ], float3, param_18_1092 ) = cp_1092;
			var(spec[nothing ], float3, param_19_1092 ) = cr_1092;
			var(spec[nothing ], float3, param_20_1092 ) = cn_1092;
			var(spec[nothing ], float, param_21_1092 ) = cd;
			var(spec[nothing ], float3, param_22_1092 ) = oc;
			var(spec[nothing ], float, param_23_1092 ) = oa;
			var(spec[nothing ], float, param_24_1092 ) = io;
			var(spec[nothing ], float3, param_25_1092 ) = ss;
			var(spec[nothing ], float3, param_26_1092 ) = vb;
			var(spec[nothing ], int, param_27_1092 ) = ec;
			var(spec[nothing ], float3, _1033_1092 ) = px(param_17_1092, param_18_1092, param_19_1092, param_20_1092, param_21_1092, param_22_1092, param_23_1092, param_24_1092, param_25_1092, param_26_1092, param_27_1092 );
			oc = param_22_1092;
			oa = param_23_1092;
			io = param_24_1092;
			ss = param_25_1092;
			vb = param_26_1092;
			ec = param_27_1092;
			var(spec[nothing ], float3, cc_1092 ) = _1033_1092;
			fc += (float4(cc_1092 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 56;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1101 ) = ro;
			var(spec[nothing ], float3, param_1_1101 ) = rd;
			var(spec[nothing ], float3, param_2_1101 ) = oc;
			var(spec[nothing ], float, param_3_1101 ) = oa;
			var(spec[nothing ], float, param_4_1101 ) = cd;
			var(spec[nothing ], float, param_5_1101 ) = td;
			var(spec[nothing ], float, param_6_1101 ) = io;
			var(spec[nothing ], float3, param_7_1101 ) = ss;
			var(spec[nothing ], float3, param_8_1101 ) = vb;
			var(spec[nothing ], int, param_9_1101 ) = ec;
			tr(param_1101, param_1_1101, param_2_1101, param_3_1101, param_4_1101, param_5_1101, param_6_1101, param_7_1101, param_8_1101, param_9_1101 );
			oc = param_2_1101;
			oa = param_3_1101;
			cd = param_4_1101;
			td = param_5_1101;
			io = param_6_1101;
			ss = param_7_1101;
			vb = param_8_1101;
			ec = param_9_1101;
			var(spec[nothing ], float3, cp_1101 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1101 ) = cp_1101;
			var(spec[nothing ], float3, param_11_1101 ) = oc;
			var(spec[nothing ], float, param_12_1101 ) = oa;
			var(spec[nothing ], float, param_13_1101 ) = io;
			var(spec[nothing ], float3, param_14_1101 ) = ss;
			var(spec[nothing ], float3, param_15_1101 ) = vb;
			var(spec[nothing ], int, param_16_1101 ) = ec;
			var(spec[nothing ], float3, _940_1101 ) = nm(param_10_1101, param_11_1101, param_12_1101, param_13_1101, param_14_1101, param_15_1101, param_16_1101 );
			oc = param_11_1101;
			oa = param_12_1101;
			io = param_13_1101;
			ss = param_14_1101;
			vb = param_15_1101;
			ec = param_16_1101;
			var(spec[nothing ], float3, cn_1101 ) = _940_1101;
			ro = cp_1101 - (cn_1101 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1101 ) = refract(rd, cn_1101, _958 );
			if((length(cr_1101 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1101 = reflect(rd, cn_1101 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1101;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1101 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1101 );
			if(_993_1101 )
			{
				_999_1101 = false;
			}
			else
			{
				_999_1101 = _993_1101;
			};
			if(_999_1101 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1101 ) = rd;
			var(spec[nothing ], float3, param_18_1101 ) = cp_1101;
			var(spec[nothing ], float3, param_19_1101 ) = cr_1101;
			var(spec[nothing ], float3, param_20_1101 ) = cn_1101;
			var(spec[nothing ], float, param_21_1101 ) = cd;
			var(spec[nothing ], float3, param_22_1101 ) = oc;
			var(spec[nothing ], float, param_23_1101 ) = oa;
			var(spec[nothing ], float, param_24_1101 ) = io;
			var(spec[nothing ], float3, param_25_1101 ) = ss;
			var(spec[nothing ], float3, param_26_1101 ) = vb;
			var(spec[nothing ], int, param_27_1101 ) = ec;
			var(spec[nothing ], float3, _1033_1101 ) = px(param_17_1101, param_18_1101, param_19_1101, param_20_1101, param_21_1101, param_22_1101, param_23_1101, param_24_1101, param_25_1101, param_26_1101, param_27_1101 );
			oc = param_22_1101;
			oa = param_23_1101;
			io = param_24_1101;
			ss = param_25_1101;
			vb = param_26_1101;
			ec = param_27_1101;
			var(spec[nothing ], float3, cc_1101 ) = _1033_1101;
			fc += (float4(cc_1101 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 57;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1110 ) = ro;
			var(spec[nothing ], float3, param_1_1110 ) = rd;
			var(spec[nothing ], float3, param_2_1110 ) = oc;
			var(spec[nothing ], float, param_3_1110 ) = oa;
			var(spec[nothing ], float, param_4_1110 ) = cd;
			var(spec[nothing ], float, param_5_1110 ) = td;
			var(spec[nothing ], float, param_6_1110 ) = io;
			var(spec[nothing ], float3, param_7_1110 ) = ss;
			var(spec[nothing ], float3, param_8_1110 ) = vb;
			var(spec[nothing ], int, param_9_1110 ) = ec;
			tr(param_1110, param_1_1110, param_2_1110, param_3_1110, param_4_1110, param_5_1110, param_6_1110, param_7_1110, param_8_1110, param_9_1110 );
			oc = param_2_1110;
			oa = param_3_1110;
			cd = param_4_1110;
			td = param_5_1110;
			io = param_6_1110;
			ss = param_7_1110;
			vb = param_8_1110;
			ec = param_9_1110;
			var(spec[nothing ], float3, cp_1110 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1110 ) = cp_1110;
			var(spec[nothing ], float3, param_11_1110 ) = oc;
			var(spec[nothing ], float, param_12_1110 ) = oa;
			var(spec[nothing ], float, param_13_1110 ) = io;
			var(spec[nothing ], float3, param_14_1110 ) = ss;
			var(spec[nothing ], float3, param_15_1110 ) = vb;
			var(spec[nothing ], int, param_16_1110 ) = ec;
			var(spec[nothing ], float3, _940_1110 ) = nm(param_10_1110, param_11_1110, param_12_1110, param_13_1110, param_14_1110, param_15_1110, param_16_1110 );
			oc = param_11_1110;
			oa = param_12_1110;
			io = param_13_1110;
			ss = param_14_1110;
			vb = param_15_1110;
			ec = param_16_1110;
			var(spec[nothing ], float3, cn_1110 ) = _940_1110;
			ro = cp_1110 - (cn_1110 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1110 ) = refract(rd, cn_1110, _958 );
			if((length(cr_1110 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1110 = reflect(rd, cn_1110 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1110;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1110 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1110 );
			if(_993_1110 )
			{
				_999_1110 = true;
			}
			else
			{
				_999_1110 = _993_1110;
			};
			if(_999_1110 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1110 ) = rd;
			var(spec[nothing ], float3, param_18_1110 ) = cp_1110;
			var(spec[nothing ], float3, param_19_1110 ) = cr_1110;
			var(spec[nothing ], float3, param_20_1110 ) = cn_1110;
			var(spec[nothing ], float, param_21_1110 ) = cd;
			var(spec[nothing ], float3, param_22_1110 ) = oc;
			var(spec[nothing ], float, param_23_1110 ) = oa;
			var(spec[nothing ], float, param_24_1110 ) = io;
			var(spec[nothing ], float3, param_25_1110 ) = ss;
			var(spec[nothing ], float3, param_26_1110 ) = vb;
			var(spec[nothing ], int, param_27_1110 ) = ec;
			var(spec[nothing ], float3, _1033_1110 ) = px(param_17_1110, param_18_1110, param_19_1110, param_20_1110, param_21_1110, param_22_1110, param_23_1110, param_24_1110, param_25_1110, param_26_1110, param_27_1110 );
			oc = param_22_1110;
			oa = param_23_1110;
			io = param_24_1110;
			ss = param_25_1110;
			vb = param_26_1110;
			ec = param_27_1110;
			var(spec[nothing ], float3, cc_1110 ) = _1033_1110;
			fc += (float4(cc_1110 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 58;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1119 ) = ro;
			var(spec[nothing ], float3, param_1_1119 ) = rd;
			var(spec[nothing ], float3, param_2_1119 ) = oc;
			var(spec[nothing ], float, param_3_1119 ) = oa;
			var(spec[nothing ], float, param_4_1119 ) = cd;
			var(spec[nothing ], float, param_5_1119 ) = td;
			var(spec[nothing ], float, param_6_1119 ) = io;
			var(spec[nothing ], float3, param_7_1119 ) = ss;
			var(spec[nothing ], float3, param_8_1119 ) = vb;
			var(spec[nothing ], int, param_9_1119 ) = ec;
			tr(param_1119, param_1_1119, param_2_1119, param_3_1119, param_4_1119, param_5_1119, param_6_1119, param_7_1119, param_8_1119, param_9_1119 );
			oc = param_2_1119;
			oa = param_3_1119;
			cd = param_4_1119;
			td = param_5_1119;
			io = param_6_1119;
			ss = param_7_1119;
			vb = param_8_1119;
			ec = param_9_1119;
			var(spec[nothing ], float3, cp_1119 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1119 ) = cp_1119;
			var(spec[nothing ], float3, param_11_1119 ) = oc;
			var(spec[nothing ], float, param_12_1119 ) = oa;
			var(spec[nothing ], float, param_13_1119 ) = io;
			var(spec[nothing ], float3, param_14_1119 ) = ss;
			var(spec[nothing ], float3, param_15_1119 ) = vb;
			var(spec[nothing ], int, param_16_1119 ) = ec;
			var(spec[nothing ], float3, _940_1119 ) = nm(param_10_1119, param_11_1119, param_12_1119, param_13_1119, param_14_1119, param_15_1119, param_16_1119 );
			oc = param_11_1119;
			oa = param_12_1119;
			io = param_13_1119;
			ss = param_14_1119;
			vb = param_15_1119;
			ec = param_16_1119;
			var(spec[nothing ], float3, cn_1119 ) = _940_1119;
			ro = cp_1119 - (cn_1119 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1119 ) = refract(rd, cn_1119, _958 );
			if((length(cr_1119 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1119 = reflect(rd, cn_1119 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1119;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1119 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1119 );
			if(_993_1119 )
			{
				_999_1119 = false;
			}
			else
			{
				_999_1119 = _993_1119;
			};
			if(_999_1119 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1119 ) = rd;
			var(spec[nothing ], float3, param_18_1119 ) = cp_1119;
			var(spec[nothing ], float3, param_19_1119 ) = cr_1119;
			var(spec[nothing ], float3, param_20_1119 ) = cn_1119;
			var(spec[nothing ], float, param_21_1119 ) = cd;
			var(spec[nothing ], float3, param_22_1119 ) = oc;
			var(spec[nothing ], float, param_23_1119 ) = oa;
			var(spec[nothing ], float, param_24_1119 ) = io;
			var(spec[nothing ], float3, param_25_1119 ) = ss;
			var(spec[nothing ], float3, param_26_1119 ) = vb;
			var(spec[nothing ], int, param_27_1119 ) = ec;
			var(spec[nothing ], float3, _1033_1119 ) = px(param_17_1119, param_18_1119, param_19_1119, param_20_1119, param_21_1119, param_22_1119, param_23_1119, param_24_1119, param_25_1119, param_26_1119, param_27_1119 );
			oc = param_22_1119;
			oa = param_23_1119;
			io = param_24_1119;
			ss = param_25_1119;
			vb = param_26_1119;
			ec = param_27_1119;
			var(spec[nothing ], float3, cc_1119 ) = _1033_1119;
			fc += (float4(cc_1119 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 59;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1128 ) = ro;
			var(spec[nothing ], float3, param_1_1128 ) = rd;
			var(spec[nothing ], float3, param_2_1128 ) = oc;
			var(spec[nothing ], float, param_3_1128 ) = oa;
			var(spec[nothing ], float, param_4_1128 ) = cd;
			var(spec[nothing ], float, param_5_1128 ) = td;
			var(spec[nothing ], float, param_6_1128 ) = io;
			var(spec[nothing ], float3, param_7_1128 ) = ss;
			var(spec[nothing ], float3, param_8_1128 ) = vb;
			var(spec[nothing ], int, param_9_1128 ) = ec;
			tr(param_1128, param_1_1128, param_2_1128, param_3_1128, param_4_1128, param_5_1128, param_6_1128, param_7_1128, param_8_1128, param_9_1128 );
			oc = param_2_1128;
			oa = param_3_1128;
			cd = param_4_1128;
			td = param_5_1128;
			io = param_6_1128;
			ss = param_7_1128;
			vb = param_8_1128;
			ec = param_9_1128;
			var(spec[nothing ], float3, cp_1128 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1128 ) = cp_1128;
			var(spec[nothing ], float3, param_11_1128 ) = oc;
			var(spec[nothing ], float, param_12_1128 ) = oa;
			var(spec[nothing ], float, param_13_1128 ) = io;
			var(spec[nothing ], float3, param_14_1128 ) = ss;
			var(spec[nothing ], float3, param_15_1128 ) = vb;
			var(spec[nothing ], int, param_16_1128 ) = ec;
			var(spec[nothing ], float3, _940_1128 ) = nm(param_10_1128, param_11_1128, param_12_1128, param_13_1128, param_14_1128, param_15_1128, param_16_1128 );
			oc = param_11_1128;
			oa = param_12_1128;
			io = param_13_1128;
			ss = param_14_1128;
			vb = param_15_1128;
			ec = param_16_1128;
			var(spec[nothing ], float3, cn_1128 ) = _940_1128;
			ro = cp_1128 - (cn_1128 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1128 ) = refract(rd, cn_1128, _958 );
			if((length(cr_1128 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1128 = reflect(rd, cn_1128 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1128;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1128 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1128 );
			if(_993_1128 )
			{
				_999_1128 = true;
			}
			else
			{
				_999_1128 = _993_1128;
			};
			if(_999_1128 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1128 ) = rd;
			var(spec[nothing ], float3, param_18_1128 ) = cp_1128;
			var(spec[nothing ], float3, param_19_1128 ) = cr_1128;
			var(spec[nothing ], float3, param_20_1128 ) = cn_1128;
			var(spec[nothing ], float, param_21_1128 ) = cd;
			var(spec[nothing ], float3, param_22_1128 ) = oc;
			var(spec[nothing ], float, param_23_1128 ) = oa;
			var(spec[nothing ], float, param_24_1128 ) = io;
			var(spec[nothing ], float3, param_25_1128 ) = ss;
			var(spec[nothing ], float3, param_26_1128 ) = vb;
			var(spec[nothing ], int, param_27_1128 ) = ec;
			var(spec[nothing ], float3, _1033_1128 ) = px(param_17_1128, param_18_1128, param_19_1128, param_20_1128, param_21_1128, param_22_1128, param_23_1128, param_24_1128, param_25_1128, param_26_1128, param_27_1128 );
			oc = param_22_1128;
			oa = param_23_1128;
			io = param_24_1128;
			ss = param_25_1128;
			vb = param_26_1128;
			ec = param_27_1128;
			var(spec[nothing ], float3, cc_1128 ) = _1033_1128;
			fc += (float4(cc_1128 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 60;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1137 ) = ro;
			var(spec[nothing ], float3, param_1_1137 ) = rd;
			var(spec[nothing ], float3, param_2_1137 ) = oc;
			var(spec[nothing ], float, param_3_1137 ) = oa;
			var(spec[nothing ], float, param_4_1137 ) = cd;
			var(spec[nothing ], float, param_5_1137 ) = td;
			var(spec[nothing ], float, param_6_1137 ) = io;
			var(spec[nothing ], float3, param_7_1137 ) = ss;
			var(spec[nothing ], float3, param_8_1137 ) = vb;
			var(spec[nothing ], int, param_9_1137 ) = ec;
			tr(param_1137, param_1_1137, param_2_1137, param_3_1137, param_4_1137, param_5_1137, param_6_1137, param_7_1137, param_8_1137, param_9_1137 );
			oc = param_2_1137;
			oa = param_3_1137;
			cd = param_4_1137;
			td = param_5_1137;
			io = param_6_1137;
			ss = param_7_1137;
			vb = param_8_1137;
			ec = param_9_1137;
			var(spec[nothing ], float3, cp_1137 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1137 ) = cp_1137;
			var(spec[nothing ], float3, param_11_1137 ) = oc;
			var(spec[nothing ], float, param_12_1137 ) = oa;
			var(spec[nothing ], float, param_13_1137 ) = io;
			var(spec[nothing ], float3, param_14_1137 ) = ss;
			var(spec[nothing ], float3, param_15_1137 ) = vb;
			var(spec[nothing ], int, param_16_1137 ) = ec;
			var(spec[nothing ], float3, _940_1137 ) = nm(param_10_1137, param_11_1137, param_12_1137, param_13_1137, param_14_1137, param_15_1137, param_16_1137 );
			oc = param_11_1137;
			oa = param_12_1137;
			io = param_13_1137;
			ss = param_14_1137;
			vb = param_15_1137;
			ec = param_16_1137;
			var(spec[nothing ], float3, cn_1137 ) = _940_1137;
			ro = cp_1137 - (cn_1137 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1137 ) = refract(rd, cn_1137, _958 );
			if((length(cr_1137 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1137 = reflect(rd, cn_1137 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1137;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1137 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1137 );
			if(_993_1137 )
			{
				_999_1137 = false;
			}
			else
			{
				_999_1137 = _993_1137;
			};
			if(_999_1137 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1137 ) = rd;
			var(spec[nothing ], float3, param_18_1137 ) = cp_1137;
			var(spec[nothing ], float3, param_19_1137 ) = cr_1137;
			var(spec[nothing ], float3, param_20_1137 ) = cn_1137;
			var(spec[nothing ], float, param_21_1137 ) = cd;
			var(spec[nothing ], float3, param_22_1137 ) = oc;
			var(spec[nothing ], float, param_23_1137 ) = oa;
			var(spec[nothing ], float, param_24_1137 ) = io;
			var(spec[nothing ], float3, param_25_1137 ) = ss;
			var(spec[nothing ], float3, param_26_1137 ) = vb;
			var(spec[nothing ], int, param_27_1137 ) = ec;
			var(spec[nothing ], float3, _1033_1137 ) = px(param_17_1137, param_18_1137, param_19_1137, param_20_1137, param_21_1137, param_22_1137, param_23_1137, param_24_1137, param_25_1137, param_26_1137, param_27_1137 );
			oc = param_22_1137;
			oa = param_23_1137;
			io = param_24_1137;
			ss = param_25_1137;
			vb = param_26_1137;
			ec = param_27_1137;
			var(spec[nothing ], float3, cc_1137 ) = _1033_1137;
			fc += (float4(cc_1137 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 61;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1146 ) = ro;
			var(spec[nothing ], float3, param_1_1146 ) = rd;
			var(spec[nothing ], float3, param_2_1146 ) = oc;
			var(spec[nothing ], float, param_3_1146 ) = oa;
			var(spec[nothing ], float, param_4_1146 ) = cd;
			var(spec[nothing ], float, param_5_1146 ) = td;
			var(spec[nothing ], float, param_6_1146 ) = io;
			var(spec[nothing ], float3, param_7_1146 ) = ss;
			var(spec[nothing ], float3, param_8_1146 ) = vb;
			var(spec[nothing ], int, param_9_1146 ) = ec;
			tr(param_1146, param_1_1146, param_2_1146, param_3_1146, param_4_1146, param_5_1146, param_6_1146, param_7_1146, param_8_1146, param_9_1146 );
			oc = param_2_1146;
			oa = param_3_1146;
			cd = param_4_1146;
			td = param_5_1146;
			io = param_6_1146;
			ss = param_7_1146;
			vb = param_8_1146;
			ec = param_9_1146;
			var(spec[nothing ], float3, cp_1146 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1146 ) = cp_1146;
			var(spec[nothing ], float3, param_11_1146 ) = oc;
			var(spec[nothing ], float, param_12_1146 ) = oa;
			var(spec[nothing ], float, param_13_1146 ) = io;
			var(spec[nothing ], float3, param_14_1146 ) = ss;
			var(spec[nothing ], float3, param_15_1146 ) = vb;
			var(spec[nothing ], int, param_16_1146 ) = ec;
			var(spec[nothing ], float3, _940_1146 ) = nm(param_10_1146, param_11_1146, param_12_1146, param_13_1146, param_14_1146, param_15_1146, param_16_1146 );
			oc = param_11_1146;
			oa = param_12_1146;
			io = param_13_1146;
			ss = param_14_1146;
			vb = param_15_1146;
			ec = param_16_1146;
			var(spec[nothing ], float3, cn_1146 ) = _940_1146;
			ro = cp_1146 - (cn_1146 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1146 ) = refract(rd, cn_1146, _958 );
			if((length(cr_1146 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1146 = reflect(rd, cn_1146 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1146;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1146 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1146 );
			if(_993_1146 )
			{
				_999_1146 = true;
			}
			else
			{
				_999_1146 = _993_1146;
			};
			if(_999_1146 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1146 ) = rd;
			var(spec[nothing ], float3, param_18_1146 ) = cp_1146;
			var(spec[nothing ], float3, param_19_1146 ) = cr_1146;
			var(spec[nothing ], float3, param_20_1146 ) = cn_1146;
			var(spec[nothing ], float, param_21_1146 ) = cd;
			var(spec[nothing ], float3, param_22_1146 ) = oc;
			var(spec[nothing ], float, param_23_1146 ) = oa;
			var(spec[nothing ], float, param_24_1146 ) = io;
			var(spec[nothing ], float3, param_25_1146 ) = ss;
			var(spec[nothing ], float3, param_26_1146 ) = vb;
			var(spec[nothing ], int, param_27_1146 ) = ec;
			var(spec[nothing ], float3, _1033_1146 ) = px(param_17_1146, param_18_1146, param_19_1146, param_20_1146, param_21_1146, param_22_1146, param_23_1146, param_24_1146, param_25_1146, param_26_1146, param_27_1146 );
			oc = param_22_1146;
			oa = param_23_1146;
			io = param_24_1146;
			ss = param_25_1146;
			vb = param_26_1146;
			ec = param_27_1146;
			var(spec[nothing ], float3, cc_1146 ) = _1033_1146;
			fc += (float4(cc_1146 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 62;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1155 ) = ro;
			var(spec[nothing ], float3, param_1_1155 ) = rd;
			var(spec[nothing ], float3, param_2_1155 ) = oc;
			var(spec[nothing ], float, param_3_1155 ) = oa;
			var(spec[nothing ], float, param_4_1155 ) = cd;
			var(spec[nothing ], float, param_5_1155 ) = td;
			var(spec[nothing ], float, param_6_1155 ) = io;
			var(spec[nothing ], float3, param_7_1155 ) = ss;
			var(spec[nothing ], float3, param_8_1155 ) = vb;
			var(spec[nothing ], int, param_9_1155 ) = ec;
			tr(param_1155, param_1_1155, param_2_1155, param_3_1155, param_4_1155, param_5_1155, param_6_1155, param_7_1155, param_8_1155, param_9_1155 );
			oc = param_2_1155;
			oa = param_3_1155;
			cd = param_4_1155;
			td = param_5_1155;
			io = param_6_1155;
			ss = param_7_1155;
			vb = param_8_1155;
			ec = param_9_1155;
			var(spec[nothing ], float3, cp_1155 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1155 ) = cp_1155;
			var(spec[nothing ], float3, param_11_1155 ) = oc;
			var(spec[nothing ], float, param_12_1155 ) = oa;
			var(spec[nothing ], float, param_13_1155 ) = io;
			var(spec[nothing ], float3, param_14_1155 ) = ss;
			var(spec[nothing ], float3, param_15_1155 ) = vb;
			var(spec[nothing ], int, param_16_1155 ) = ec;
			var(spec[nothing ], float3, _940_1155 ) = nm(param_10_1155, param_11_1155, param_12_1155, param_13_1155, param_14_1155, param_15_1155, param_16_1155 );
			oc = param_11_1155;
			oa = param_12_1155;
			io = param_13_1155;
			ss = param_14_1155;
			vb = param_15_1155;
			ec = param_16_1155;
			var(spec[nothing ], float3, cn_1155 ) = _940_1155;
			ro = cp_1155 - (cn_1155 * 0.00999999977 );
			if(0 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1155 ) = refract(rd, cn_1155, _958 );
			if((length(cr_1155 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1155 = reflect(rd, cn_1155 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1155;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1155 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1155 );
			if(_993_1155 )
			{
				_999_1155 = false;
			}
			else
			{
				_999_1155 = _993_1155;
			};
			if(_999_1155 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1155 ) = rd;
			var(spec[nothing ], float3, param_18_1155 ) = cp_1155;
			var(spec[nothing ], float3, param_19_1155 ) = cr_1155;
			var(spec[nothing ], float3, param_20_1155 ) = cn_1155;
			var(spec[nothing ], float, param_21_1155 ) = cd;
			var(spec[nothing ], float3, param_22_1155 ) = oc;
			var(spec[nothing ], float, param_23_1155 ) = oa;
			var(spec[nothing ], float, param_24_1155 ) = io;
			var(spec[nothing ], float3, param_25_1155 ) = ss;
			var(spec[nothing ], float3, param_26_1155 ) = vb;
			var(spec[nothing ], int, param_27_1155 ) = ec;
			var(spec[nothing ], float3, _1033_1155 ) = px(param_17_1155, param_18_1155, param_19_1155, param_20_1155, param_21_1155, param_22_1155, param_23_1155, param_24_1155, param_25_1155, param_26_1155, param_27_1155 );
			oc = param_22_1155;
			oa = param_23_1155;
			io = param_24_1155;
			ss = param_25_1155;
			vb = param_26_1155;
			ec = param_27_1155;
			var(spec[nothing ], float3, cc_1155 ) = _1033_1155;
			fc += (float4(cc_1155 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
		i = 63;
		if(! _br_flag_17 )
		{
			var(spec[nothing ], float3, param_1164 ) = ro;
			var(spec[nothing ], float3, param_1_1164 ) = rd;
			var(spec[nothing ], float3, param_2_1164 ) = oc;
			var(spec[nothing ], float, param_3_1164 ) = oa;
			var(spec[nothing ], float, param_4_1164 ) = cd;
			var(spec[nothing ], float, param_5_1164 ) = td;
			var(spec[nothing ], float, param_6_1164 ) = io;
			var(spec[nothing ], float3, param_7_1164 ) = ss;
			var(spec[nothing ], float3, param_8_1164 ) = vb;
			var(spec[nothing ], int, param_9_1164 ) = ec;
			tr(param_1164, param_1_1164, param_2_1164, param_3_1164, param_4_1164, param_5_1164, param_6_1164, param_7_1164, param_8_1164, param_9_1164 );
			oc = param_2_1164;
			oa = param_3_1164;
			cd = param_4_1164;
			td = param_5_1164;
			io = param_6_1164;
			ss = param_7_1164;
			vb = param_8_1164;
			ec = param_9_1164;
			var(spec[nothing ], float3, cp_1164 ) = ro + (rd * cd );
			var(spec[nothing ], float3, param_10_1164 ) = cp_1164;
			var(spec[nothing ], float3, param_11_1164 ) = oc;
			var(spec[nothing ], float, param_12_1164 ) = oa;
			var(spec[nothing ], float, param_13_1164 ) = io;
			var(spec[nothing ], float3, param_14_1164 ) = ss;
			var(spec[nothing ], float3, param_15_1164 ) = vb;
			var(spec[nothing ], int, param_16_1164 ) = ec;
			var(spec[nothing ], float3, _940_1164 ) = nm(param_10_1164, param_11_1164, param_12_1164, param_13_1164, param_14_1164, param_15_1164, param_16_1164 );
			oc = param_11_1164;
			oa = param_12_1164;
			io = param_13_1164;
			ss = param_14_1164;
			vb = param_15_1164;
			ec = param_16_1164;
			var(spec[nothing ], float3, cn_1164 ) = _940_1164;
			ro = cp_1164 - (cn_1164 * 0.00999999977 );
			if(1 == 0 )
			{
				_958 = 1.0 / io;
			}
			else
			{
				_958 = io;
			};
			var(spec[nothing ], float3, cr_1164 ) = refract(rd, cn_1164, _958 );
			if((length(cr_1164 ) == 0.0 ) && (es <= 0 ) )
			{
				cr_1164 = reflect(rd, cn_1164 );
				es = ec;
			};
			if(((max(es, 0 ) % 3 ) == 0 ) && (cd < 128.0 ) )
			{
				rd = cr_1164;
			};
			es -- ;
			var(spec[nothing ], bool, _993_1164 ) = vb.x  > 0.0;
			var(spec[nothing ], bool, _999_1164 );
			if(_993_1164 )
			{
				_999_1164 = true;
			}
			else
			{
				_999_1164 = _993_1164;
			};
			if(_999_1164 )
			{
				oa = pow(clamp(cd / vb.y , 0.0, 1.0 ), vb.z  );
			};
			var(spec[nothing ], float3, param_17_1164 ) = rd;
			var(spec[nothing ], float3, param_18_1164 ) = cp_1164;
			var(spec[nothing ], float3, param_19_1164 ) = cr_1164;
			var(spec[nothing ], float3, param_20_1164 ) = cn_1164;
			var(spec[nothing ], float, param_21_1164 ) = cd;
			var(spec[nothing ], float3, param_22_1164 ) = oc;
			var(spec[nothing ], float, param_23_1164 ) = oa;
			var(spec[nothing ], float, param_24_1164 ) = io;
			var(spec[nothing ], float3, param_25_1164 ) = ss;
			var(spec[nothing ], float3, param_26_1164 ) = vb;
			var(spec[nothing ], int, param_27_1164 ) = ec;
			var(spec[nothing ], float3, _1033_1164 ) = px(param_17_1164, param_18_1164, param_19_1164, param_20_1164, param_21_1164, param_22_1164, param_23_1164, param_24_1164, param_25_1164, param_26_1164, param_27_1164 );
			oc = param_22_1164;
			oa = param_23_1164;
			io = param_24_1164;
			ss = param_25_1164;
			vb = param_26_1164;
			ec = param_27_1164;
			var(spec[nothing ], float3, cc_1164 ) = _1033_1164;
			fc += (float4(cc_1164 * oa, oa ) * (1.0 - fc.w  ) );
			if((fc.w  >= 1.0 ) || (cd > 128.0 ) )
			{
				_br_flag_17 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
	var(spec[nothing ], float4, col ) = fc / clamp(fc.w , 0.00999999977, 1.0 ).xxxx ;
	return <- col;
};
func(spec[nothing ], void, mainImage )
params(var(spec[out, nothing ], float4, fragColor ), var(spec[nothing ], float2, fragCoord ) )
{
	var(spec[nothing ], float2, coord ) = fragCoord;
	var(spec[nothing ], float2, param ) = coord;
	var(spec[nothing ], float2, param_1 ) = iResolution.xy ;
	var(spec[nothing ], float, param_2 ) = iTime;
	var(spec[nothing ], float4, _1086 ) = render(param, param_1, param_2 );
	fragColor = _1086;
};
func(spec[nothing ], void, frag_main )
params()
{
};
func(spec[nothing ], SPIRV_Cross_Output, main )
params(var(spec[nothing ], SPIRV_Cross_Input, stage_input ) )
{
	inCoord = stage_input.inCoord ;
	frag_main();
	var(spec[nothing ], SPIRV_Cross_Output, stage_output );
	stage_output.outColor  = outColor;
	return <- stage_output;
};
