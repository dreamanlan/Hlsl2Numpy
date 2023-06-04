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
var(spec[static, nothing ], float, focalDistance );
var(spec[static, nothing ], float, aperture );
var(spec[static, nothing ], float, shadowCone );
var(spec[static, nothing ], float, pixelSize );
var(spec[static, nothing ], float, iTime );
var(spec[static, nothing ], float3, iResolution );
var(spec[static, nothing ], float, iTimeDelta );
var(spec[static, nothing ], float, iFrameRate );
var(spec[static, nothing ], int, iFrame );
var(spec[static, nothing ], float, iChannelTime[4 ] );
var(spec[static, nothing ], float3, iChannelResolution[4 ] );
var(spec[static, nothing ], float4, iMouse );
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
func(spec[nothing ], float3x3, lookat )
params(var(spec[inout, nothing ], float3, fw ), var(spec[nothing ], float3, up ) )
{
	fw = normalize(fw );
	var(spec[nothing ], float3, rt ) = normalize(cross(fw, normalize(up ) ) );
	return <- float3x3(float3(rt ), float3(cross(rt, fw ) ), float3(fw ) );
};
func(spec[nothing ], float, hash )
params(var(spec[nothing ], float, n ) )
{
	return <- frac(sin(n ) * 4378.54541F );
};
func(spec[nothing ], float, noyz )
params(var(spec[nothing ], float3, x ) )
{
	var(spec[nothing ], float3, p ) = floor(x );
	var(spec[nothing ], float3, j ) = frac(x );
	var(spec[nothing ], float, n ) = (p.x  + (p.y  * 7.0F ) ) + (p.z  * 13.0F );
	var(spec[nothing ], float, param ) = n;
	var(spec[nothing ], float, a ) = hash(param );
	var(spec[nothing ], float, param_1 ) = n + 1.0F;
	var(spec[nothing ], float, b ) = hash(param_1 );
	var(spec[nothing ], float, param_2 ) = n + 7.0F;
	var(spec[nothing ], float, c ) = hash(param_2 );
	var(spec[nothing ], float, param_3 ) = (n + 7.0F ) + 1.0F;
	var(spec[nothing ], float, d ) = hash(param_3 );
	var(spec[nothing ], float, param_4 ) = n + 13.0F;
	var(spec[nothing ], float, e ) = hash(param_4 );
	var(spec[nothing ], float, param_5 ) = (n + 1.0F ) + 13.0F;
	var(spec[nothing ], float, f ) = hash(param_5 );
	var(spec[nothing ], float, param_6 ) = (n + 7.0F ) + 13.0F;
	var(spec[nothing ], float, g ) = hash(param_6 );
	var(spec[nothing ], float, param_7 ) = ((n + 1.0F ) + 7.0F ) + 13.0F;
	var(spec[nothing ], float, h ) = hash(param_7 );
	var(spec[nothing ], float3, u ) = (j * j ) * (3.0F.xxx  - (j * 2.0F ) );
	return <- lerp(((a + ((b - a ) * u.x  ) ) + ((c - a ) * u.y  ) ) + (((((a - b ) - c ) + d ) * u.x  ) * u.y  ), ((e + ((f - e ) * u.x  ) ) + ((g - e ) * u.y  ) ) + (((((e - f ) - g ) + h ) * u.x  ) * u.y  ), u.z  );
};
func(spec[nothing ], float, fbm )
params(var(spec[inout, nothing ], float3, p ) )
{
	var(spec[nothing ], float3, param ) = p;
	var(spec[nothing ], float, h ) = noyz(param );
	var(spec[nothing ], float3, _285 ) = p;
	var(spec[nothing ], float3, _286 ) = _285 * 2.29999995F;
	p = _286;
	var(spec[nothing ], float3, param_1 ) = _286;
	h += (0.5F * noyz(param_1 ) );
	var(spec[nothing ], float3, param_2 ) = p * 2.29999995F;
	return <- h + (0.25F * noyz(param_2 ) );
};
func(spec[nothing ], void, Kaleido )
params(var(spec[inout, nothing ], float2, v ), var(spec[nothing ], float, power ) )
{
	var(spec[nothing ], float, a ) = (floor(0.5F + ((atan2(v.x , - v.y  ) * power ) / 6.28299999F ) ) * 6.28299999F ) / power;
	v = (v * cos(a ) ) + (float2(v.y , - v.x  ) * sin(a ) );
};
func(spec[nothing ], float, Rect )
params(var(spec[nothing ], float3, z ), var(spec[nothing ], float3, r ) )
{
	return <- max(abs(z.x  ) - r.x , max(abs(z.y  ) - r.y , abs(z.z  ) - r.z  ) );
};
func(spec[nothing ], float, DE )
params(var(spec[inout, nothing ], float3, z0 ), var(spec[inout, nothing ], float4, mcol ) )
{
	var(spec[nothing ], float, dW ) = 100.0F;
	var(spec[nothing ], float, dD ) = 100.0F;
	var(spec[nothing ], float3, param ) = (z0 * 0.25F ) + 100.0F.xxx ;
	var(spec[nothing ], float, _311 ) = fbm(param );
	var(spec[nothing ], float, dC ) = (((_311 * 0.5F ) + (sin(z0.y  ) * 0.100000001F ) ) + (sin(z0.z  * 0.400000006F ) * 0.100000001F ) ) + min((z0.y  * 0.0399999991F ) + 0.100000001F, 0.100000001F );
	var(spec[nothing ], float2, v ) = floor((float2(z0.x , abs(z0.z  ) ) * 0.5F ) + 0.5F.xx  );
	var(spec[nothing ], float3, _344 ) = z0;
	var(spec[nothing ], float3, _351 ) = z0;
	var(spec[nothing ], float2, _353 ) = (clamp(_344.xz , (-2.0F ).xx , 2.0F.xx  ) * 2.0F ) - _351.xz ;
	z0.x  = _353.x ;
	z0.z  = _353.y ;
	var(spec[nothing ], float, r ) = length(z0.xz  );
	var(spec[nothing ], float, dS ) = r - 0.600000024F;
	if(r < 1.0F )
	{
		var(spec[nothing ], float, shape ) = 0.284999996F - (v.x  * 0.0199999996F );
		z0.y  += (v.y  * 0.200000003F );
		var(spec[nothing ], float3, z ) = z0 * 10.0F;
		dS = max(z0.y  - 2.5F, r - max(0.109999999F - (z0.y  * 0.100000001F ), 0.00999999977F ) );
		var(spec[nothing ], float, y2 ) = max(abs(abs(mod(z.y  + 0.5F, 2.0F ) - 1.0F ) - 0.5F ) - 0.0500000007F, abs(z.y  - 7.0999999F ) - 8.30000019F );
		var(spec[nothing ], float, y ) = sin(clamp(floor(z.y  ) * shape, -0.400000006F, 3.4000001F ) ) * 40.0F;
		var(spec[nothing ], float2, param_1 ) = z.xz ;
		var(spec[nothing ], float, param_2 ) = 8.0F + floor(y );
		Kaleido(param_1, param_2 );
		z.x  = param_1.x ;
		z.z  = param_1.y ;
		var(spec[nothing ], float3, param_3 ) = z;
		var(spec[nothing ], float3, param_4 ) = float3(0.899999976F + (y * 0.100000001F ), 22.0F, 0.899999976F + (y * 0.100000001F ) );
		dW = Rect(param_3, param_4 ) * 0.0799999982F;
		dD = max(z0.y  - 1.37F, max(y2, ((r * 10.0F ) - 1.75F ) - (sin(clamp((z.y  - 0.5F ) * shape, -0.0500000007F, 3.49000001F ) ) * 4.0F ) ) ) * 0.0799999982F;
		dS = min(dS, min(dW, dD ) );
	};
	dS = min(dS, dC );
	if(dS == dW )
	{
		mcol += float4(0.800000011F, 0.899999976F, 0.899999976F, 1.0F );
	}
	else
	{
		if(dS == dD )
		{
			mcol += float4(0.600000024F, 0.400000006F, 0.300000012F, 0.0F );
		}
		else
		{
			if(dS == dC )
			{
				mcol += float4(1.0F, 1.0F, 1.0F, -1.0F );
			}
			else
			{
				mcol += float4(0.699999988F + (sin(z0.y  * 100.0F ) * 0.300000012F ), 1.0F, 0.800000011F, 0.0F );
			};
		};
	};
	return <- dS;
};
func(spec[nothing ], float, CircleOfConfusion )
params(var(spec[nothing ], float, t ) )
{
	return <- max(abs(focalDistance - t ) * aperture, pixelSize * (1.0F + t ) );
};
func(spec[nothing ], float, linstep )
params(var(spec[nothing ], float, a ), var(spec[nothing ], float, b ), var(spec[nothing ], float, t ) )
{
	return <- clamp((t - a ) / (b - a ), 0.0F, 1.0F );
};
func(spec[nothing ], float, randStep )
params(var(spec[inout, nothing ], float, randSeed ) )
{
	randSeed += 1.0F;
	return <- 0.800000011F + (0.200000003F * frac(sin(randSeed ) * 4375.54541F ) );
};
func(spec[nothing ], float, FuzzyShadow )
params(var(spec[nothing ], float3, ro ), var(spec[nothing ], float3, rd ), var(spec[nothing ], float, coneGrad ), var(spec[nothing ], float, rCoC ), var(spec[inout, nothing ], float4, mcol ), var(spec[inout, nothing ], float, randSeed ) )
{
	var(spec[nothing ], float, t ) = rCoC * 2.0F;
	var(spec[nothing ], float, d ) = 1.0F;
	var(spec[nothing ], float, s ) = 1.0F;
	var(spec[nothing ], bool, _br_flag_16 ) = false;
	var(spec[nothing ], bool, _cont_flag_16 ) = false;
	for([var(spec[nothing ], int, i ) = 0 ], [], [i ++  ] )
	{
		if(! _br_flag_16 )
		{
			_cont_flag_16 = false;
			if(i < 6 )
			{
				if(s < 0.100000001F )
				{
					_cont_flag_16 = true;
				};
				if(! _cont_flag_16 )
				{
					var(spec[nothing ], float, r ) = rCoC + (t * coneGrad );
					var(spec[nothing ], float3, param ) = ro + (rd * t );
					var(spec[nothing ], float4, param_1 ) = mcol;
					var(spec[nothing ], float, _637 ) = DE(param, param_1 );
					mcol = param_1;
					d = _637 + (r * 0.400000006F );
					var(spec[nothing ], float, param_2 ) = - r;
					var(spec[nothing ], float, param_3 ) = r;
					var(spec[nothing ], float, param_4 ) = d;
					s *= linstep(param_2, param_3, param_4 );
					var(spec[nothing ], float, param_5 ) = randSeed;
					var(spec[nothing ], float, _656 ) = randStep(param_5 );
					randSeed = param_5;
					t += (abs(d ) * _656 );
				};
			}
			else_all_if_false_in_loop
			{
				_br_flag_16 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
	return <- clamp((s * 0.75F ) + 0.25F, 0.0F, 1.0F );
};
func(spec[nothing ], void, mainImage )
params(var(spec[inout, nothing ], float4, O ), var(spec[nothing ], float2, U ) )
{
	var(spec[nothing ], float4, mcol ) = 0.0F.xxxx ;
	var(spec[nothing ], float, randSeed ) = frac(sin(iTime + dot(U, float2(9.12300014F, 13.4309998F ) ) ) * 473.719238F );
	pixelSize = 2.0F / iResolution.y ;
	var(spec[nothing ], float, tim ) = iTime * 0.25F;
	var(spec[nothing ], float3, ro ) = float3(cos(tim ), (sin(tim * 0.699999988F ) * 0.5F ) + 0.300000012F, sin(tim ) ) * (1.79999995F + (0.5F * sin(tim * 0.409999996F ) ) );
	var(spec[nothing ], float3, param ) = float3(0.0F, 0.600000024F, sin(tim * 2.29999995F ) ) - ro;
	var(spec[nothing ], float3, param_1 ) = float3(0.100000001F, 1.0F, 0.0F );
	var(spec[nothing ], float3x3, _723 ) = lookat(param, param_1 );
	var(spec[nothing ], float3, rd ) = mul(normalize(float3(((U * 2.0F ) - iResolution.xy  ) / iResolution.y .xx , 2.0F ) ), _723 );
	var(spec[nothing ], float3, L ) = float3(0.485071242F, 0.727606893F, -0.485071242F );
	var(spec[nothing ], float4, col ) = 0.0F.xxxx ;
	var(spec[nothing ], float3, param_2 ) = ro;
	var(spec[nothing ], float4, param_3 ) = mcol;
	var(spec[nothing ], float, _749 ) = DE(param_2, param_3 );
	mcol = param_3;
	var(spec[nothing ], float, t ) = (_749 * randSeed ) * 0.800000011F;
	ro += (rd * t );
	var(spec[nothing ], float, alpha );
	var(spec[nothing ], float3, scol );
	var(spec[nothing ], bool, _br_flag_18 ) = false;
	var(spec[nothing ], bool, _cont_flag_18 ) = false;
	for([var(spec[nothing ], int, i ) = 0 ], [], [i ++  ] )
	{
		if(! _br_flag_18 )
		{
			_cont_flag_18 = false;
			if(i < 72 )
			{
				if((col.w  > 0.899999976F ) || (t > 20.0F ) )
				{
					_cont_flag_18 = true;
				};
				if(! _cont_flag_18 )
				{
					var(spec[nothing ], float, param_4 ) = t;
					var(spec[nothing ], float, rCoC ) = CircleOfConfusion(param_4 );
					var(spec[nothing ], float3, param_5 ) = ro;
					var(spec[nothing ], float4, param_6 ) = mcol;
					var(spec[nothing ], float, _788 ) = DE(param_5, param_6 );
					mcol = param_6;
					var(spec[nothing ], float, d ) = _788;
					var(spec[nothing ], float, fClouds ) = max(0.0F, - mcol.w  );
					if(d < max(rCoC, fClouds * 0.5F ) )
					{
						var(spec[nothing ], float3, p ) = ro;
						if(fClouds < 0.100000001F )
						{
							p -= (rd * abs(d - rCoC ) );
						};
						var(spec[nothing ], float2, v ) = float2(rCoC * 0.333000004F, 0.0F );
						var(spec[nothing ], float3, param_7 ) = p - v.xyy ;
						var(spec[nothing ], float4, param_8 ) = mcol;
						var(spec[nothing ], float, _830 ) = DE(param_7, param_8 );
						mcol = param_8;
						var(spec[nothing ], float3, param_9 ) = p + v.xyy ;
						var(spec[nothing ], float4, param_10 ) = mcol;
						var(spec[nothing ], float, _840 ) = DE(param_9, param_10 );
						mcol = param_10;
						var(spec[nothing ], float3, param_11 ) = p - v.yxy ;
						var(spec[nothing ], float4, param_12 ) = mcol;
						var(spec[nothing ], float, _850 ) = DE(param_11, param_12 );
						mcol = param_12;
						var(spec[nothing ], float3, param_13 ) = p + v.yxy ;
						var(spec[nothing ], float4, param_14 ) = mcol;
						var(spec[nothing ], float, _860 ) = DE(param_13, param_14 );
						mcol = param_14;
						var(spec[nothing ], float3, param_15 ) = p - v.yyx ;
						var(spec[nothing ], float4, param_16 ) = mcol;
						var(spec[nothing ], float, _870 ) = DE(param_15, param_16 );
						mcol = param_16;
						var(spec[nothing ], float3, param_17 ) = p + v.yyx ;
						var(spec[nothing ], float4, param_18 ) = mcol;
						var(spec[nothing ], float, _880 ) = DE(param_17, param_18 );
						mcol = param_18;
						var(spec[nothing ], float3, N ) = normalize(float3((- _830 ) + _840, (- _850 ) + _860, (- _870 ) + _880 ) );
						mcol *= 0.143000007F;
						if(fClouds > 0.100000001F )
						{
							var(spec[nothing ], float, dn ) = clamp(0.5F - d, 0.0F, 1.0F );
							dn *= 2.0F;
							dn *= dn;
							alpha = (1.0F - col.w  ) * dn;
							scol = 1.0F.xxx  * (0.600000024F + ((dn * dot(N, L ) ) * 0.400000006F ) );
							scol += (float3(1.0F, 0.5F, 0.0F ) * (dn * max(0.0F, dot(reflect(rd, N ), L ) ) ) );
						}
						else
						{
							scol = mcol.xyz  * (0.200000003F + (0.400000006F * (1.0F + dot(N, L ) ) ) );
							scol += (float3(1.0F, 0.5F, 0.0F ) * (0.5F * pow(max(0.0F, dot(reflect(rd, N ), L ) ), 32.0F ) ) );
							var(spec[nothing ], bool, _954 ) = d < (rCoC * 0.25F );
							var(spec[nothing ], bool, _960 );
							if(_954 )
							{
								_960 = mcol.w  > 0.899999976F;
							}
							else
							{
								_960 = _954;
							};
							if(_960 )
							{
								rd = reflect(rd, N );
								d = (- rCoC ) * 0.25F;
								ro = p;
								t += 1.0F;
							};
							var(spec[nothing ], float3, param_19 ) = p;
							var(spec[nothing ], float3, param_20 ) = L;
							var(spec[nothing ], float, param_21 ) = shadowCone;
							var(spec[nothing ], float, param_22 ) = rCoC;
							var(spec[nothing ], float4, param_23 ) = mcol;
							var(spec[nothing ], float, param_24 ) = randSeed;
							var(spec[nothing ], float, _984 ) = FuzzyShadow(param_19, param_20, param_21, param_22, param_23, param_24 );
							mcol = param_23;
							randSeed = param_24;
							scol *= _984;
							var(spec[nothing ], float, param_25 ) = - rCoC;
							var(spec[nothing ], float, param_26 ) = rCoC;
							var(spec[nothing ], float, param_27 ) = (- d ) - (0.5F * rCoC );
							alpha = (1.0F - col.w  ) * linstep(param_25, param_26, param_27 );
						};
						col += float4(scol * alpha, alpha );
					};
					mcol = 0.0F.xxxx ;
					var(spec[nothing ], float, param_28 ) = randSeed;
					var(spec[nothing ], float, _1023 ) = randStep(param_28 );
					randSeed = param_28;
					d = abs(d + (0.330000013F * rCoC ) ) * _1023;
					ro += (rd * d );
					t += d;
				};
			}
			else_all_if_false_in_loop
			{
				_br_flag_18 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
	var(spec[nothing ], float3, scol_1 ) = (float3(0.400000006F, 0.5F, 0.600000024F ) + (rd * 0.0500000007F ) ) + (float3(1.0F, 0.75F, 0.5F ) * pow(max(0.0F, dot(rd, L ) ), 100.0F ) );
	var(spec[nothing ], float, _1051 ) = col.w ;
	var(spec[nothing ], float4, _1055 ) = col;
	var(spec[nothing ], float3, _1057 ) = _1055.xyz  + (scol_1 * (1.0F - clamp(_1051, 0.0F, 1.0F ) ) );
	col.x  = _1057.x ;
	col.y  = _1057.y ;
	col.z  = _1057.z ;
	O = float4(clamp(col.xyz , 0.0F.xxx , 1.0F.xxx  ), 1.0F );
};
func(spec[nothing ], void, frag_main )
params()
{
	focalDistance = 1.0F;
	aperture = 0.00999999977F;
	shadowCone = 0.300000012F;
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
