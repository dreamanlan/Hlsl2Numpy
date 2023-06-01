// Rewrite unchanged result:
var(spec[nothing ], Texture2D<:float4 :>, iChannel0 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel0_sampler )register(s0 );
var(spec[nothing ], Texture2D<:float4 :>, iChannel1 )register(t0 );
var(spec[nothing ], SamplerState, _iChannel1_sampler )register(s0 );
var(spec[nothing ], Texture3D<:float4 :>, iChannel2 )register(t0 );
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
var(spec[static, nothing ], float, iTime );
var(spec[static, nothing ], float3, iResolution );
var(spec[static, nothing ], float4, iMouse );
var(spec[static, nothing ], float, iTimeDelta );
var(spec[static, nothing ], float, iFrameRate );
var(spec[static, nothing ], int, iFrame );
var(spec[static, nothing ], float, iChannelTime[4 ] );
var(spec[static, nothing ], float3, iChannelResolution[4 ] );
var(spec[static, nothing ], float4, iDate );
var(spec[static, nothing ], float, iSampleRate );
func(spec[nothing ], float3x3, fromEuler )
params(var(spec[nothing ], float3, ang ) )
{
	var(spec[nothing ], float2, a1 ) = float2(sin(ang.x  ), cos(ang.x  ) );
	var(spec[nothing ], float2, a2 ) = float2(sin(ang.y  ), cos(ang.y  ) );
	var(spec[nothing ], float2, a3 ) = float2(sin(ang.z  ), cos(ang.z  ) );
	var(spec[nothing ], float3x3, m );
	m[0 ] = float3((a1.y  * a3.y  ) + ((a1.x  * a2.x  ) * a3.x  ), ((a1.y  * a2.x  ) * a3.x  ) + (a3.y  * a1.x  ), (- a2.y  ) * a3.x  );
	m[1 ] = float3((- a2.y  ) * a1.x , a1.y  * a2.y , a2.x  );
	m[2 ] = float3(((a3.y  * a1.x  ) * a2.x  ) + (a1.y  * a3.x  ), (a1.x  * a3.x  ) - ((a1.y  * a3.y  ) * a2.x  ), a2.y  * a3.y  );
	return <- m;
};
func(spec[nothing ], float, hash )
params(var(spec[nothing ], float2, p ) )
{
	var(spec[nothing ], float, h ) = dot(p, float2(127.099998F, 311.700012F ) );
	return <- frac(sin(h ) * 43758.5469F );
};
func(spec[nothing ], float, _noise )
params(var(spec[nothing ], float2, p ) )
{
	var(spec[nothing ], float2, i ) = floor(p );
	var(spec[nothing ], float2, f ) = frac(p );
	var(spec[nothing ], float2, u ) = (f * f ) * (3.0F.xx  - (f * 2.0F ) );
	var(spec[nothing ], float2, param ) = i + 0.0F.xx ;
	var(spec[nothing ], float2, param_1 ) = i + float2(1.0F, 0.0F );
	var(spec[nothing ], float2, param_2 ) = i + float2(0.0F, 1.0F );
	var(spec[nothing ], float2, param_3 ) = i + 1.0F.xx ;
	return <- (-1.0F ) + (2.0F * lerp(lerp(hash(param ), hash(param_1 ), u.x  ), lerp(hash(param_2 ), hash(param_3 ), u.x  ), u.y  ) );
};
func(spec[nothing ], float, sea_octave )
params(var(spec[inout, nothing ], float2, uv ), var(spec[nothing ], float, choppy ) )
{
	var(spec[nothing ], float2, param ) = uv;
	uv += _noise(param ).xx ;
	var(spec[nothing ], float2, wv ) = 1.0F.xx  - abs(sin(uv ) );
	var(spec[nothing ], float2, swv ) = abs(cos(uv ) );
	wv = lerp(wv, swv, wv );
	return <- pow(1.0F - pow(wv.x  * wv.y , 0.649999976F ), choppy );
};
func(spec[nothing ], float, map )
params(var(spec[nothing ], float3, p ) )
{
	var(spec[nothing ], float, freq ) = 0.159999996F;
	var(spec[nothing ], float, amp ) = 0.600000024F;
	var(spec[nothing ], float, choppy ) = 4.0F;
	var(spec[nothing ], float2, uv ) = p.xz ;
	uv.x  *= 0.75F;
	var(spec[nothing ], float, h ) = 0.0F;
	var(spec[nothing ], bool, _br_flag_6 ) = false;
	for([var(spec[nothing ], int, i ) = 0 ], [], [++ i ] )
	{
		if(! _br_flag_6 )
		{
			if(i < 3 )
			{
				var(spec[nothing ], float2, param ) = (uv + (1.0F + (iTime * 0.800000011F ) ).xx  ) * freq;
				var(spec[nothing ], float, param_1 ) = choppy;
				var(spec[nothing ], float, _399 ) = sea_octave(param, param_1 );
				var(spec[nothing ], float, d ) = _399;
				var(spec[nothing ], float2, param_2 ) = (uv - (1.0F + (iTime * 0.800000011F ) ).xx  ) * freq;
				var(spec[nothing ], float, param_3 ) = choppy;
				var(spec[nothing ], float, _411 ) = sea_octave(param_2, param_3 );
				d += _411;
				h += (d * amp );
				uv = mul(float2x2(float2(1.60000002F, 1.20000005F ), float2(-1.20000005F, 1.60000002F ) ), uv );
				freq *= 1.89999998F;
				amp *= 0.219999999F;
				choppy = lerp(choppy, 1.0F, 0.200000003F );
			}
			else_all_if_false_in_loop
			{
				_br_flag_6 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
	return <- p.y  - h;
};
func(spec[nothing ], float, heightMapTracing )
params(var(spec[nothing ], float3, ori ), var(spec[nothing ], float3, dir ), var(spec[inout, nothing ], float3, p ) )
{
	var(spec[nothing ], float, _func_ret_val_7 );
	var(spec[nothing ], bool, _func_ret_flag_7 ) = false;
	var(spec[nothing ], float, tm ) = 0.0F;
	var(spec[nothing ], float, tx ) = 1000.0F;
	var(spec[nothing ], float3, param ) = ori + (dir * tx );
	var(spec[nothing ], float, hx ) = map(param );
	if(hx > 0.0F )
	{
		p = ori + (dir * tx );
		_func_ret_flag_7 = true;
		_func_ret_val_7 = tx;
	};
	if(! _func_ret_flag_7 )
	{
		var(spec[nothing ], float3, param_1 ) = ori + (dir * tm );
		var(spec[nothing ], float, hm ) = map(param_1 );
		var(spec[nothing ], float, tmid ) = 0.0F;
		var(spec[nothing ], bool, _br_flag_8 ) = false;
		for([var(spec[nothing ], int, i ) = 0 ], [], [++ i ] )
		{
			if(! _br_flag_8 )
			{
				if(i < 8 )
				{
					tmid = lerp(tm, tx, hm / (hm - hx ) );
					p = ori + (dir * tmid );
					var(spec[nothing ], float3, param_2 ) = p;
					var(spec[nothing ], float, hmid ) = map(param_2 );
					if(hmid < 0.0F )
					{
						tx = tmid;
						hx = hmid;
					}
					else
					{
						tm = tmid;
						hm = hmid;
					};
				}
				else_all_if_false_in_loop
				{
					_br_flag_8 = true;
				};
			}
			else_all_if_false_in_loop
			{
				break;
			};
		};
		_func_ret_flag_7 = true;
		_func_ret_val_7 = tmid;
	};
	return <- _func_ret_val_7;
};
func(spec[nothing ], float, map_detailed )
params(var(spec[nothing ], float3, p ) )
{
	var(spec[nothing ], float, freq ) = 0.159999996F;
	var(spec[nothing ], float, amp ) = 0.600000024F;
	var(spec[nothing ], float, choppy ) = 4.0F;
	var(spec[nothing ], float2, uv ) = p.xz ;
	uv.x  *= 0.75F;
	var(spec[nothing ], float, h ) = 0.0F;
	var(spec[nothing ], bool, _br_flag_10 ) = false;
	for([var(spec[nothing ], int, i ) = 0 ], [], [++ i ] )
	{
		if(! _br_flag_10 )
		{
			if(i < 5 )
			{
				var(spec[nothing ], float2, param ) = (uv + (1.0F + (iTime * 0.800000011F ) ).xx  ) * freq;
				var(spec[nothing ], float, param_1 ) = choppy;
				var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
				var(spec[nothing ], float, d ) = _476;
				var(spec[nothing ], float2, param_2 ) = (uv - (1.0F + (iTime * 0.800000011F ) ).xx  ) * freq;
				var(spec[nothing ], float, param_3 ) = choppy;
				var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
				d += _488;
				h += (d * amp );
				uv = mul(float2x2(float2(1.60000002F, 1.20000005F ), float2(-1.20000005F, 1.60000002F ) ), uv );
				freq *= 1.89999998F;
				amp *= 0.219999999F;
				choppy = lerp(choppy, 1.0F, 0.200000003F );
			}
			else_all_if_false_in_loop
			{
				_br_flag_10 = true;
			};
		}
		else_all_if_false_in_loop
		{
			break;
		};
	};
	return <- p.y  - h;
};
func(spec[nothing ], float3, getNormal )
params(var(spec[nothing ], float3, p ), var(spec[nothing ], float, eps ) )
{
	var(spec[nothing ], float3, param ) = p;
	var(spec[nothing ], float3, n );
	n.y  = map_detailed(param );
	var(spec[nothing ], float3, param_1 ) = float3(p.x  + eps, p.y , p.z  );
	n.x  = map_detailed(param_1 ) - n.y ;
	var(spec[nothing ], float3, param_2 ) = float3(p.x , p.y , p.z  + eps );
	n.z  = map_detailed(param_2 ) - n.y ;
	n.y  = eps;
	return <- normalize(n );
};
func(spec[nothing ], float3, getSkyColor )
params(var(spec[inout, nothing ], float3, e ) )
{
	e.y  = ((max(e.y , 0.0F ) * 0.800000011F ) + 0.200000003F ) * 0.800000011F;
	return <- float3(pow(1.0F - e.y , 2.0F ), 1.0F - e.y , 0.600000024F + ((1.0F - e.y  ) * 0.400000006F ) ) * 1.10000002F;
};
func(spec[nothing ], float, diffuse )
params(var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float, p ) )
{
	return <- pow((dot(n, l ) * 0.400000006F ) + 0.600000024F, p );
};
func(spec[nothing ], float, specular )
params(var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float3, e ), var(spec[nothing ], float, s ) )
{
	var(spec[nothing ], float, nrm ) = (s + 8.0F ) / 25.1327362F;
	return <- pow(max(dot(reflect(e, n ), l ), 0.0F ), s ) * nrm;
};
func(spec[nothing ], float3, getSeaColor )
params(var(spec[nothing ], float3, p ), var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float3, eye ), var(spec[nothing ], float3, dist ) )
{
	var(spec[nothing ], float, fresnel ) = clamp(1.0F - dot(n, - eye ), 0.0F, 1.0F );
	fresnel = min(pow(fresnel, 3.0F ), 0.5F );
	var(spec[nothing ], float3, param ) = reflect(eye, n );
	var(spec[nothing ], float3, _528 ) = getSkyColor(param );
	var(spec[nothing ], float3, reflected ) = _528;
	var(spec[nothing ], float3, param_1 ) = n;
	var(spec[nothing ], float3, param_2 ) = l;
	var(spec[nothing ], float, param_3 ) = 80.0F;
	var(spec[nothing ], float3, refracted ) = float3(0.0F, 0.0900000035F, 0.180000007F ) + ((float3(0.479999989F, 0.540000021F, 0.360000014F ) * diffuse(param_1, param_2, param_3 ) ) * 0.119999997F );
	var(spec[nothing ], float3, color ) = lerp(refracted, reflected, fresnel.xxx  );
	var(spec[nothing ], float, atten ) = max(1.0F - (dot(dist, dist ) * 0.00100000005F ), 0.0F );
	color += (((float3(0.479999989F, 0.540000021F, 0.360000014F ) * (p.y  - 0.600000024F ) ) * 0.180000007F ) * atten );
	var(spec[nothing ], float3, param_4 ) = n;
	var(spec[nothing ], float3, param_5 ) = l;
	var(spec[nothing ], float3, param_6 ) = eye;
	var(spec[nothing ], float, param_7 ) = 60.0F;
	color += specular(param_4, param_5, param_6, param_7 ).xxx ;
	return <- color;
};
func(spec[nothing ], float3, getPixel )
params(var(spec[nothing ], float2, coord ), var(spec[nothing ], float, time ) )
{
	var(spec[nothing ], float2, uv ) = coord / iResolution.xy ;
	uv = (uv * 2.0F ) - 1.0F.xx ;
	uv.x  *= (iResolution.x  / iResolution.y  );
	var(spec[nothing ], float3, ang ) = float3(sin(time * 3.0F ) * 0.100000001F, (sin(time ) * 0.200000003F ) + 0.300000012F, time );
	var(spec[nothing ], float3, ori ) = float3(0.0F, 3.5F, time * 5.0F );
	var(spec[nothing ], float3, dir ) = normalize(float3(uv, -2.0F ) );
	dir.z  += (length(uv ) * 0.140000001F );
	var(spec[nothing ], float3, param ) = ang;
	dir = mul(fromEuler(param ), normalize(dir ) );
	var(spec[nothing ], float3, param_1 ) = ori;
	var(spec[nothing ], float3, param_2 ) = dir;
	var(spec[nothing ], float3, param_3 );
	var(spec[nothing ], float, _764 ) = heightMapTracing(param_1, param_2, param_3 );
	var(spec[nothing ], float3, p ) = param_3;
	var(spec[nothing ], float3, dist ) = p - ori;
	var(spec[nothing ], float3, param_4 ) = p;
	var(spec[nothing ], float, param_5 ) = dot(dist, dist ) * (0.100000001F / iResolution.x  );
	var(spec[nothing ], float3, n ) = getNormal(param_4, param_5 );
	var(spec[nothing ], float3, light ) = float3(0.0F, 0.780868828F, 0.624695063F );
	var(spec[nothing ], float3, param_6 ) = dir;
	var(spec[nothing ], float3, _788 ) = getSkyColor(param_6 );
	var(spec[nothing ], float3, param_7 ) = p;
	var(spec[nothing ], float3, param_8 ) = n;
	var(spec[nothing ], float3, param_9 ) = light;
	var(spec[nothing ], float3, param_10 ) = dir;
	var(spec[nothing ], float3, param_11 ) = dist;
	return <- lerp(_788, getSeaColor(param_7, param_8, param_9, param_10, param_11 ), pow(smoothstep(0.0F, -0.0199999996F, dir.y  ), 0.200000003F ).xxx  );
};
func(spec[nothing ], void, mainImage )
params(var(spec[inout, nothing ], float4, fragColor ), var(spec[nothing ], float2, fragCoord ) )
{
	var(spec[nothing ], float, time ) = (iTime * 0.300000012F ) + (iMouse.x  * 0.00999999977F );
	var(spec[nothing ], float3, color ) = 0.0F.xxx ;
	var(spec[nothing ], bool, _br_flag_18 ) = false;
	for([var(spec[nothing ], int, i ) = -1 ], [], [++ i ] )
	{
		if(! _br_flag_18 )
		{
			if(i <= 1 )
			{
				var(spec[nothing ], bool, _br_flag_19 ) = false;
				for([var(spec[nothing ], int, j ) = -1 ], [], [++ j ] )
				{
					if(! _br_flag_19 )
					{
						if(j <= 1 )
						{
							var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(i ), float(j ) ) / 3.0F.xx  );
							var(spec[nothing ], float2, param ) = uv;
							var(spec[nothing ], float, param_1 ) = time;
							color += getPixel(param, param_1 );
						}
						else_all_if_false_in_loop
						{
							_br_flag_19 = true;
						};
					}
					else_all_if_false_in_loop
					{
						break;
					};
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
	color /= 9.0F.xxx ;
	fragColor = float4(pow(color, 0.649999976F.xxx  ), 1.0F );
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
