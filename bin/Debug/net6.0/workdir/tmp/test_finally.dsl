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
	var(spec[nothing ], float, h ) = dot(p, float2(127.099998, 311.700012 ) );
	return <- frac(sin(h ) * 43758.5469 );
};
func(spec[nothing ], float, _noise )
params(var(spec[nothing ], float2, p ) )
{
	var(spec[nothing ], float2, i ) = floor(p );
	var(spec[nothing ], float2, f ) = frac(p );
	var(spec[nothing ], float2, u ) = (f * f ) * (3.0F.xx  - (f * 2.0 ) );
	var(spec[nothing ], float2, param ) = i + 0.0F.xx ;
	var(spec[nothing ], float2, param_1 ) = i + float2(1.0, 0.0 );
	var(spec[nothing ], float2, param_2 ) = i + float2(0.0, 1.0 );
	var(spec[nothing ], float2, param_3 ) = i + 1.0F.xx ;
	return <- -1.0 + (2.0 * lerp(lerp(hash(param ), hash(param_1 ), u.x  ), lerp(hash(param_2 ), hash(param_3 ), u.x  ), u.y  ) );
};
func(spec[nothing ], float, sea_octave )
params(var(spec[inout, nothing ], float2, uv ), var(spec[nothing ], float, choppy ) )
{
	var(spec[nothing ], float2, param ) = uv;
	uv += _noise(param ).xx ;
	var(spec[nothing ], float2, wv ) = 1.0F.xx  - abs(sin(uv ) );
	var(spec[nothing ], float2, swv ) = abs(cos(uv ) );
	wv = lerp(wv, swv, wv );
	return <- pow(1.0 - pow(wv.x  * wv.y , 0.649999976 ), choppy );
};
func(spec[nothing ], float, map )
params(var(spec[nothing ], float3, p ) )
{
	var(spec[nothing ], float, freq ) = 0.159999996;
	var(spec[nothing ], float, amp ) = 0.600000024;
	var(spec[nothing ], float, choppy ) = 4.0;
	var(spec[nothing ], float2, uv ) = p.xz ;
	uv.x  *= 0.75F;
	var(spec[nothing ], float, h ) = 0.0;
	block
	{
		var(spec[nothing ], int, i ) = 0;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.159999996;
		var(spec[nothing ], float, param_1 ) = 4.0;
		var(spec[nothing ], float, _399 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _399;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.159999996;
		var(spec[nothing ], float, param_3 ) = 4.0;
		var(spec[nothing ], float, _411 ) = sea_octave(param_2, param_3 );
		d += _411;
		h += (d * 0.600000024 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 1;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.304;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _399 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _399;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.304;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _411 ) = sea_octave(param_2, param_3 );
		d += _411;
		h += (d * 0.132 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 2;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.5776;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _399 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _399;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.5776;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _411 ) = sea_octave(param_2, param_3 );
		d += _411;
		h += (d * 0.02904 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
	};
	return <- p.y  - h;
};
func(spec[nothing ], float, heightMapTracing )
params(var(spec[nothing ], float3, ori ), var(spec[nothing ], float3, dir ), var(spec[inout, nothing ], float3, p ) )
{
	var(spec[nothing ], float, _func_ret_val_7 );
	var(spec[nothing ], bool, _func_ret_flag_7 ) = false;
	var(spec[nothing ], float, tm ) = 0.0;
	var(spec[nothing ], float, tx ) = 1000.0;
	var(spec[nothing ], float3, param ) = ori + (dir * 1000.0 );
	var(spec[nothing ], float, hx ) = map(param );
	if(hx > 0.0 )
	{
		p = ori + (dir * 1000.0 );
		_func_ret_flag_7 = true;
		_func_ret_val_7 = 1000.0;
	};
	if(! _func_ret_flag_7 )
	{
		var(spec[nothing ], float3, param_1 ) = ori + (dir * 0.0 );
		var(spec[nothing ], float, hm ) = map(param_1 );
		var(spec[nothing ], float, tmid ) = 0.0;
		block
		{
			var(spec[nothing ], int, i ) = 0;
			tmid = lerp(0.0, 1000.0, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 1;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 2;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 3;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 4;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 5;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 6;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
			};
			i = 7;
			tmid = lerp(tm, tx, hm / (hm - hx ) );
			p = ori + (dir * tmid );
			var(spec[nothing ], float3, param_2 ) = p;
			var(spec[nothing ], float, hmid ) = map(param_2 );
			if(hmid < 0.0 )
			{
				tx = tmid;
				hx = hmid;
			}
			else
			{
				tm = tmid;
				hm = hmid;
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
	var(spec[nothing ], float, freq ) = 0.159999996;
	var(spec[nothing ], float, amp ) = 0.600000024;
	var(spec[nothing ], float, choppy ) = 4.0;
	var(spec[nothing ], float2, uv ) = p.xz ;
	uv.x  *= 0.75F;
	var(spec[nothing ], float, h ) = 0.0;
	block
	{
		var(spec[nothing ], int, i ) = 0;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.159999996;
		var(spec[nothing ], float, param_1 ) = 4.0;
		var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _476;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.159999996;
		var(spec[nothing ], float, param_3 ) = 4.0;
		var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
		d += _488;
		h += (d * 0.600000024 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 1;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.304;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _476;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.304;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
		d += _488;
		h += (d * 0.132 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 2;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.5776;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _476;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 0.5776;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
		d += _488;
		h += (d * 0.02904 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 3;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 1.09744;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _476;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 1.09744;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
		d += _488;
		h += (d * 0.0063888 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
		i = 4;
		var(spec[nothing ], float2, param ) = (uv + (1.0 + (iTime * 0.800000011 ) ).xx  ) * 2.085136;
		var(spec[nothing ], float, param_1 ) = choppy;
		var(spec[nothing ], float, _476 ) = sea_octave(param, param_1 );
		var(spec[nothing ], float, d ) = _476;
		var(spec[nothing ], float2, param_2 ) = (uv - (1.0 + (iTime * 0.800000011 ) ).xx  ) * 2.085136;
		var(spec[nothing ], float, param_3 ) = choppy;
		var(spec[nothing ], float, _488 ) = sea_octave(param_2, param_3 );
		d += _488;
		h += (d * 0.0014055 );
		uv = mul(float2x2(float2(1.60000002, 1.20000005 ), float2(-1.20000005, 1.60000002 ) ), uv );
		freq *= 1.89999998;
		amp *= 0.219999999;
		choppy = lerp(choppy, 1.0, 0.200000003 );
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
	e.y  = ((max(e.y , 0.0 ) * 0.800000011 ) + 0.200000003 ) * 0.800000011;
	return <- float3(pow(1.0 - e.y , 2.0 ), 1.0 - e.y , 0.600000024 + ((1.0 - e.y  ) * 0.400000006 ) ) * 1.10000002;
};
func(spec[nothing ], float, diffuse )
params(var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float, p ) )
{
	return <- pow((dot(n, l ) * 0.400000006 ) + 0.600000024, p );
};
func(spec[nothing ], float, specular )
params(var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float3, e ), var(spec[nothing ], float, s ) )
{
	var(spec[nothing ], float, nrm ) = (s + 8.0 ) / 25.1327362;
	return <- pow(max(dot(reflect(e, n ), l ), 0.0 ), s ) * nrm;
};
func(spec[nothing ], float3, getSeaColor )
params(var(spec[nothing ], float3, p ), var(spec[nothing ], float3, n ), var(spec[nothing ], float3, l ), var(spec[nothing ], float3, eye ), var(spec[nothing ], float3, dist ) )
{
	var(spec[nothing ], float, fresnel ) = clamp(1.0 - dot(n, - eye ), 0.0, 1.0 );
	fresnel = min(pow(fresnel, 3.0 ), 0.5 );
	var(spec[nothing ], float3, param ) = reflect(eye, n );
	var(spec[nothing ], float3, _528 ) = getSkyColor(param );
	var(spec[nothing ], float3, reflected ) = _528;
	var(spec[nothing ], float3, param_1 ) = n;
	var(spec[nothing ], float3, param_2 ) = l;
	var(spec[nothing ], float, param_3 ) = 80.0;
	var(spec[nothing ], float3, refracted ) = float3(0.0, 0.0900000035, 0.180000007 ) + ((float3(0.479999989, 0.540000021, 0.360000014 ) * diffuse(param_1, param_2, 80.0 ) ) * 0.119999997 );
	var(spec[nothing ], float3, color ) = lerp(refracted, reflected, fresnel.xxx  );
	var(spec[nothing ], float, atten ) = max(1.0 - (dot(dist, dist ) * 0.00100000005 ), 0.0 );
	color += (((float3(0.479999989, 0.540000021, 0.360000014 ) * (p.y  - 0.600000024 ) ) * 0.180000007 ) * atten );
	var(spec[nothing ], float3, param_4 ) = n;
	var(spec[nothing ], float3, param_5 ) = l;
	var(spec[nothing ], float3, param_6 ) = eye;
	var(spec[nothing ], float, param_7 ) = 60.0;
	color += specular(param_4, param_5, param_6, 60.0 ).xxx ;
	return <- color;
};
func(spec[nothing ], float3, getPixel )
params(var(spec[nothing ], float2, coord ), var(spec[nothing ], float, time ) )
{
	var(spec[nothing ], float2, uv ) = coord / iResolution.xy ;
	uv = (uv * 2.0 ) - 1.0F.xx ;
	uv.x  *= (iResolution.x  / iResolution.y  );
	var(spec[nothing ], float3, ang ) = float3(sin(time * 3.0 ) * 0.100000001, (sin(time ) * 0.200000003 ) + 0.300000012, time );
	var(spec[nothing ], float3, ori ) = float3(0.0, 3.5, time * 5.0 );
	var(spec[nothing ], float3, dir ) = normalize(float3(uv, -2.0 ) );
	dir.z  += (length(uv ) * 0.140000001 );
	var(spec[nothing ], float3, param ) = ang;
	dir = mul(fromEuler(param ), normalize(dir ) );
	var(spec[nothing ], float3, param_1 ) = ori;
	var(spec[nothing ], float3, param_2 ) = dir;
	var(spec[nothing ], float3, param_3 );
	var(spec[nothing ], float, _764 ) = heightMapTracing(param_1, param_2, param_3 );
	var(spec[nothing ], float3, p ) = param_3;
	var(spec[nothing ], float3, dist ) = p - ori;
	var(spec[nothing ], float3, param_4 ) = p;
	var(spec[nothing ], float, param_5 ) = dot(dist, dist ) * (0.100000001 / iResolution.x  );
	var(spec[nothing ], float3, n ) = getNormal(param_4, param_5 );
	var(spec[nothing ], float3, light ) = float3(0.0, 0.780868828, 0.624695063 );
	var(spec[nothing ], float3, param_6 ) = dir;
	var(spec[nothing ], float3, _788 ) = getSkyColor(param_6 );
	var(spec[nothing ], float3, param_7 ) = p;
	var(spec[nothing ], float3, param_8 ) = n;
	var(spec[nothing ], float3, param_9 ) = light;
	var(spec[nothing ], float3, param_10 ) = dir;
	var(spec[nothing ], float3, param_11 ) = dist;
	return <- lerp(_788, getSeaColor(param_7, param_8, param_9, param_10, param_11 ), pow(smoothstep(0.0, -0.0199999996, dir.y  ), 0.200000003 ).xxx  );
};
func(spec[nothing ], void, mainImage )
params(var(spec[inout, nothing ], float4, fragColor ), var(spec[nothing ], float2, fragCoord ) )
{
	var(spec[nothing ], float, time ) = (iTime * 0.300000012 ) + (iMouse.x  * 0.00999999977 );
	var(spec[nothing ], float3, color ) = 0.0F.xxx ;
	block
	{
		var(spec[nothing ], int, i ) = -1;
		block
		{
			var(spec[nothing ], int, j ) = -1;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(-1 ), float(-1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param, param_1 );
			j = 0;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(-1 ), float(0 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param, param_1 );
			j = 1;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(-1 ), float(1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param, param_1 );
		};
		i = 0;
		block
		{
			var(spec[nothing ], int, j_88 ) = -1;
			var(spec[nothing ], float2, uv_88 ) = fragCoord + (float2(float(0 ), float(-1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param_88 ) = uv_88;
			var(spec[nothing ], float, param_1_88 ) = time;
			color += getPixel(param_88, param_1_88 );
			j_88 = 0;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(0 ), float(0 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv_88;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param_88, param_1_88 );
			j_88 = 1;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(0 ), float(1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv_88;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param_88, param_1_88 );
		};
		i = 1;
		block
		{
			var(spec[nothing ], int, j_89 ) = -1;
			var(spec[nothing ], float2, uv_89 ) = fragCoord + (float2(float(1 ), float(-1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param_89 ) = uv_89;
			var(spec[nothing ], float, param_1_89 ) = time;
			color += getPixel(param_89, param_1_89 );
			j_89 = 0;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(1 ), float(0 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv_89;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param_89, param_1_89 );
			j_89 = 1;
			var(spec[nothing ], float2, uv ) = fragCoord + (float2(float(1 ), float(1 ) ) / 3.0F.xx  );
			var(spec[nothing ], float2, param ) = uv_89;
			var(spec[nothing ], float, param_1 ) = time;
			color += getPixel(param_89, param_1_89 );
		};
	};
	color /= 9.0F.xxx ;
	fragColor = float4(pow(color, 0.649999976F.xxx  ), 1.0 );
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
