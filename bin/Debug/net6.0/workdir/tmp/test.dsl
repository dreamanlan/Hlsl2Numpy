// Rewrite unchanged result:
var(spec[nothing], Texture2D<:float4:>, iChannel0)register(t0);
var(spec[nothing], SamplerState, _iChannel0_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel1)register(t0);
var(spec[nothing], SamplerState, _iChannel1_sampler)register(s0);
var(spec[nothing], TextureCube<:float4:>, iChannel2)register(t0);
var(spec[nothing], SamplerState, _iChannel2_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel3)register(t0);
var(spec[nothing], SamplerState, _iChannel3_sampler)register(s0);
var(spec[static, nothing], float4, outColor);
var(spec[static, nothing], float2, inCoord);
struct(SPIRV_Cross_Input) {
  field(spec[nothing], float2, inCoord)semantic(TEXCOORD2);
};
struct(SPIRV_Cross_Output) {
  field(spec[nothing], float4, outColor)semantic(SV_Target0);
};
var(spec[static, nothing], float4, iMouse);
var(spec[static, nothing], float3, iResolution);
var(spec[static, nothing], float, tt);
var(spec[static, nothing], float3, glv);
var(spec[static, nothing], float, iTime);
var(spec[static, nothing], float, iTimeDelta);
var(spec[static, nothing], float, iFrameRate);
var(spec[static, nothing], int, iFrame);
var(spec[static, nothing], float, iChannelTime[4]);
var(spec[static, nothing], float3, iChannelResolution[4]);
var(spec[static, nothing], float4, iDate);
var(spec[static, nothing], float, iSampleRate);
func(spec[nothing], float, mod)params(var(spec[nothing], float, x), var(spec[nothing], float, y)) {
  return <- x - y * floor(x / y);
};

func(spec[nothing], float2, mod)params(var(spec[nothing], float2, x), var(spec[nothing], float2, y)) {
  return <- x - y * floor(x / y);
};

func(spec[nothing], float3, mod)params(var(spec[nothing], float3, x), var(spec[nothing], float3, y)) {
  return <- x - y * floor(x / y);
};

func(spec[nothing], float4, mod)params(var(spec[nothing], float4, x), var(spec[nothing], float4, y)) {
  return <- x - y * floor(x / y);
};

func(spec[nothing], float3, lattice)params(var(spec[inout, nothing], float3, p), var(spec[nothing], int, iter)) {
  for ([var(spec[nothing], int, i) = 0], [i < iter], [i++]) {
    var(spec[nothing], float3, _282) = p;
    var(spec[nothing], float2, _284) = mul(float2x2(float2(0.707106888F, 0.707106709F), float2(-0.707106709F, 0.707106888F)), _282.xy);
    p.x = _284.x;
    p.y = _284.y;
    var(spec[nothing], float3, _289) = p;
    var(spec[nothing], float2, _291) = mul(float2x2(float2(0.707106888F, 0.707106709F), float2(-0.707106709F, 0.707106888F)), _289.xz);
    p.x = _291.x;
    p.z = _291.y;
    p = abs(p) - 1.0F.xxx;
    var(spec[nothing], float3, _303) = p;
    var(spec[nothing], float2, _305) = mul(float2x2(float2(0.707106888F, -0.707106709F), float2(0.707106709F, 0.707106888F)), _303.xy);
    p.x = _305.x;
    p.y = _305.y;
    var(spec[nothing], float3, _310) = p;
    var(spec[nothing], float2, _312) = mul(float2x2(float2(0.707106888F, -0.707106709F), float2(0.707106709F, 0.707106888F)), _310.xz);
    p.x = _312.x;
    p.z = _312.y;
  };
  return <- p;
};

func(spec[nothing], float, cy)params(var(spec[inout, nothing], float3, p), var(spec[nothing], float2, s)) {
  p.y += (s.x / 2.0F);
  p.y -= clamp(p.y, 0.0F, s.x);
  return <- length(p) - s.y;
};

func(spec[nothing], float, shatter)params(var(spec[inout, nothing], float3, p), var(spec[inout, nothing], float, d), var(spec[nothing], float, n), var(spec[nothing], float, a), var(spec[nothing], float, s)) {
  var(spec[nothing], float, _234);
  var(spec[nothing], float, _243);
  for ([var(spec[nothing], float, i) = 0.0F], [i < n], [i += 1.0F]) {
    var(spec[nothing], float3, _171) = p;
    var(spec[nothing], float2, _173) = mul(float2x2(float2(cos(a), sin(a)), float2(-sin(a), cos(a))), _171.xy);
    p.x = _173.x;
    p.y = _173.y;
    var(spec[nothing], float3, _195) = p;
    var(spec[nothing], float2, _197) = mul(float2x2(float2(cos(a * 0.5F), sin(a * 0.5F)), float2(-sin(a * 0.5F), cos(a * 0.5F))), _195.xz);
    p.x = _197.x;
    p.z = _197.y;
    var(spec[nothing], float3, _222) = p;
    var(spec[nothing], float2, _224) = mul(float2x2(float2(cos(a + a), sin(a + a)), float2(-sin(a + a), cos(a + a))), _222.yz);
    p.y = _224.x;
    p.z = _224.y;
    if (mod(i, 3.0F) == 0.0F) {
      _234 = p.x;
    } else {
      if (mod(i, 3.0F) == 1.0F) {
        _243 = p.y;
      } else {
        _243 = p.z;
      };
      _234 = _243;
    };
    var(spec[nothing], float, c) = _234;
    c = abs(c) - s;
    d = max(d, -c);
  };
  return <- d;
};

func(spec[nothing], float, bx)params(var(spec[nothing], float3, p), var(spec[nothing], float3, s)) {
  var(spec[nothing], float3, q) = abs(p) - s;
  return <- min(max(q.x, max(q.y, q.z)), 0.0F) + length(max(q, 0.0F.xxx));
};

func(spec[nothing], float, mp)params(var(spec[inout, nothing], float3, p), var(spec[inout, nothing], float3, oc), var(spec[inout, nothing], float, oa), var(spec[inout, nothing], float, io), var(spec[inout, nothing], float3, ss), var(spec[inout, nothing], float3, vb), var(spec[inout, nothing], int, ec)) {
  if (iMouse.z > 0.0F) {
    var(spec[nothing], float3, _369) = p;
    var(spec[nothing], float2, _371) = mul(float2x2(float2(cos(2.0F * ((iMouse.y / iResolution.y) - 0.5F)), sin(2.0F * ((iMouse.y / iResolution.y) - 0.5F))), float2(-sin(2.0F * ((iMouse.y / iResolution.y) - 0.5F)), cos(2.0F * ((iMouse.y / iResolution.y) - 0.5F)))), _369.yz);
    p.y = _371.x;
    p.z = _371.y;
    var(spec[nothing], float3, _413) = p;
    var(spec[nothing], float2, _415) = mul(float2x2(float2(cos((-7.0F) * ((iMouse.x / iResolution.x) - 0.5F)), sin((-7.0F) * ((iMouse.x / iResolution.x) - 0.5F))), float2(-sin((-7.0F) * ((iMouse.x / iResolution.x) - 0.5F)), cos((-7.0F) * ((iMouse.x / iResolution.x) - 0.5F)))), _413.zx);
    p.z = _415.x;
    p.x = _415.y;
  };
  var(spec[nothing], float3, pp) = p;
  var(spec[nothing], float3, _440) = p;
  var(spec[nothing], float2, _442) = mul(float2x2(float2(cos(tt * 0.200000003F), sin(tt * 0.200000003F)), float2(-sin(tt * 0.200000003F), cos(tt * 0.200000003F))), _440.xz);
  p.x = _442.x;
  p.z = _442.y;
  var(spec[nothing], float3, _463) = p;
  var(spec[nothing], float2, _465) = mul(float2x2(float2(cos(tt * 0.200000003F), sin(tt * 0.200000003F)), float2(-sin(tt * 0.200000003F), cos(tt * 0.200000003F))), _463.xy);
  p.x = _465.x;
  p.y = _465.y;
  var(spec[nothing], float3, param) = p;
  var(spec[nothing], int, param_1) = 3;
  var(spec[nothing], float3, _474) = lattice(param, param_1);
  p = _474;
  var(spec[nothing], float3, param_2) = p;
  var(spec[nothing], float2, param_3) = 1.0F.xx;
  var(spec[nothing], float, _480) = cy(param_2, param_3);
  var(spec[nothing], float, sd) = _480 - 0.0500000007F;
  var(spec[nothing], float3, param_4) = p;
  var(spec[nothing], float, param_5) = sd;
  var(spec[nothing], float, param_6) = 1.0F;
  var(spec[nothing], float, param_7) = sin(tt * 0.100000001F);
  var(spec[nothing], float, param_8) = 0.200000003F;
  var(spec[nothing], float, _494) = shatter(param_4, param_5, param_6, param_7, param_8);
  sd = _494;
  var(spec[nothing], float3, param_9) = p;
  var(spec[nothing], float3, param_10) = float3(0.100000001F, 2.0999999F, 8.0F);
  sd = min(sd, bx(param_9, param_10) - 0.300000012F);
  var(spec[nothing], float3, param_11) = p;
  var(spec[nothing], float2, param_12) = float2(4.0F, 1.0F);
  var(spec[nothing], float, _512) = cy(param_11, param_12);
  sd = lerp(sd, _512, (cos(tt * 0.5F) * 0.5F) + 0.5F);
  sd = abs(sd) - 0.00100000005F;
  if (sd < 0.00100000005F) {
    oc = lerp(float3(1.0F, 0.100000001F, 0.600000024F), float3(0.0F, 0.600000024F, 1.0F), pow(length(pp) * 0.180000007F, 1.5F).xxx);
    io = 1.10000002F;
    oa = 1.04999995F - (length(pp) * 0.200000003F);
    ss = 0.0F.xxx;
    vb = float3(0.0F, 2.5F, 2.5F);
    ec = 2;
  };
  return <- sd;
};

func(spec[nothing], void, tr)params(var(spec[nothing], float3, ro), var(spec[nothing], float3, rd), var(spec[inout, nothing], float3, oc), var(spec[inout, nothing], float, oa), var(spec[inout, nothing], float, cd), var(spec[inout, nothing], float, td), var(spec[inout, nothing], float, io), var(spec[inout, nothing], float3, ss), var(spec[inout, nothing], float3, vb), var(spec[inout, nothing], int, ec)) {
  vb.x = 0.0F;
  cd = 0.0F;
  for ([var(spec[nothing], float, i) = 0.0F], [i < 64.0F], [i += 1.0F]) {
    var(spec[nothing], float3, param) = ro + (rd * cd);
    var(spec[nothing], float3, param_1) = oc;
    var(spec[nothing], float, param_2) = oa;
    var(spec[nothing], float, param_3) = io;
    var(spec[nothing], float3, param_4) = ss;
    var(spec[nothing], float3, param_5) = vb;
    var(spec[nothing], int, param_6) = ec;
    var(spec[nothing], float, _580) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
    oc = param_1;
    oa = param_2;
    io = param_3;
    ss = param_4;
    vb = param_5;
    ec = param_6;
    var(spec[nothing], float, sd) = _580;
    cd += sd;
    td += sd;
    if ((sd < 9.99999974E-5F) || (cd > 128.0F)) {
      break;
    };
  };
};

func(spec[nothing], float3, nm)params(var(spec[nothing], float3, cp), var(spec[inout, nothing], float3, oc), var(spec[inout, nothing], float, oa), var(spec[inout, nothing], float, io), var(spec[inout, nothing], float3, ss), var(spec[inout, nothing], float3, vb), var(spec[inout, nothing], int, ec)) {
  var(spec[nothing], float3x3, _623) = float3x3(float3(cp), float3(cp), float3(cp));
  var(spec[nothing], float3x3, k) = float3x3(_623[0] - float3(0.00100000005F, 0.0F, 0.0F), _623[1] - float3(0.0F, 0.00100000005F, 0.0F), _623[2] - float3(0.0F, 0.0F, 0.00100000005F));
  var(spec[nothing], float3, param) = cp;
  var(spec[nothing], float3, param_1) = oc;
  var(spec[nothing], float, param_2) = oa;
  var(spec[nothing], float, param_3) = io;
  var(spec[nothing], float3, param_4) = ss;
  var(spec[nothing], float3, param_5) = vb;
  var(spec[nothing], int, param_6) = ec;
  var(spec[nothing], float, _652) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
  oc = param_1;
  oa = param_2;
  io = param_3;
  ss = param_4;
  vb = param_5;
  ec = param_6;
  var(spec[nothing], float3, param_7) = k[0];
  var(spec[nothing], float3, param_8) = oc;
  var(spec[nothing], float, param_9) = oa;
  var(spec[nothing], float, param_10) = io;
  var(spec[nothing], float3, param_11) = ss;
  var(spec[nothing], float3, param_12) = vb;
  var(spec[nothing], int, param_13) = ec;
  var(spec[nothing], float, _674) = mp(param_7, param_8, param_9, param_10, param_11, param_12, param_13);
  oc = param_8;
  oa = param_9;
  io = param_10;
  ss = param_11;
  vb = param_12;
  ec = param_13;
  var(spec[nothing], float3, param_14) = k[1];
  var(spec[nothing], float3, param_15) = oc;
  var(spec[nothing], float, param_16) = oa;
  var(spec[nothing], float, param_17) = io;
  var(spec[nothing], float3, param_18) = ss;
  var(spec[nothing], float3, param_19) = vb;
  var(spec[nothing], int, param_20) = ec;
  var(spec[nothing], float, _696) = mp(param_14, param_15, param_16, param_17, param_18, param_19, param_20);
  oc = param_15;
  oa = param_16;
  io = param_17;
  ss = param_18;
  vb = param_19;
  ec = param_20;
  var(spec[nothing], float3, param_21) = k[2];
  var(spec[nothing], float3, param_22) = oc;
  var(spec[nothing], float, param_23) = oa;
  var(spec[nothing], float, param_24) = io;
  var(spec[nothing], float3, param_25) = ss;
  var(spec[nothing], float3, param_26) = vb;
  var(spec[nothing], int, param_27) = ec;
  var(spec[nothing], float, _718) = mp(param_21, param_22, param_23, param_24, param_25, param_26, param_27);
  oc = param_22;
  oa = param_23;
  io = param_24;
  ss = param_25;
  vb = param_26;
  ec = param_27;
  return <- normalize(_652.xxx - float3(_674, _696, _718));
};

func(spec[nothing], float3, px)params(var(spec[nothing], float3, rd), var(spec[nothing], float3, cp), var(spec[nothing], float3, cr), var(spec[nothing], float3, cn), var(spec[nothing], float, cd), var(spec[inout, nothing], float3, oc), var(spec[inout, nothing], float, oa), var(spec[inout, nothing], float, io), var(spec[inout, nothing], float3, ss), var(spec[inout, nothing], float3, vb), var(spec[inout, nothing], int, ec)) {
  var(spec[nothing], float3, cc) = (float3(0.699999988F, 0.400000006F, 0.600000024F) + (length(pow(abs(rd + float3(0.0F, 0.5F, 0.0F)), 3.0F.xxx)) * 0.300000012F).xxx) + glv;
  if (cd > 128.0F) {
    oa = 1.0F;
    return <- cc;
  };
  var(spec[nothing], float3, l) = float3(0.400000006F, 0.699999988F, 0.800000011F);
  var(spec[nothing], float, df) = clamp(length(cn * l), 0.0F, 1.0F);
  var(spec[nothing], float3, fr) = lerp(cc, 0.400000006F.xxx, 0.5F.xxx) * pow(1.0F - df, 3.0F);
  var(spec[nothing], float, sp) = (1.0F - length(cross(cr, cn * l))) * 0.200000003F;
  var(spec[nothing], float3, param) = cp + (cn * 0.300000012F);
  var(spec[nothing], float3, param_1) = oc;
  var(spec[nothing], float, param_2) = oa;
  var(spec[nothing], float, param_3) = io;
  var(spec[nothing], float3, param_4) = ss;
  var(spec[nothing], float3, param_5) = vb;
  var(spec[nothing], int, param_6) = ec;
  var(spec[nothing], float, _799) = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
  oc = param_1;
  oa = param_2;
  io = param_3;
  ss = param_4;
  vb = param_5;
  ec = param_6;
  var(spec[nothing], float, ao) = min(_799 - 0.300000012F, 0.300000012F) * 0.5F;
  cc = lerp(((((oc * ((df.xxx + fr) + ss)) + fr) + sp.xxx) + ao.xxx) + glv, oc, vb.x.xxx);
  return <- cc;
};

func(spec[nothing], float4, render)params(var(spec[nothing], float2, frag), var(spec[nothing], float2, res), var(spec[nothing], float, time)) {
  var(spec[nothing], float4, fc) = 0.100000001F.xxxx;
  var(spec[nothing], int, es) = 0;
  tt = mod(time, 260.0F);
  var(spec[nothing], float2, uv) = float2(frag.x / res.x, frag.y / res.y);
  uv -= 0.5F.xx;
  uv /= float2(res.y / res.x, 1.0F);
  var(spec[nothing], float3, ro) = float3(0.0F, 0.0F, -15.0F);
  var(spec[nothing], float3, rd) = normalize(float3(uv, 1.0F));
  var(spec[nothing], float3, oc);
  var(spec[nothing], float, oa);
  var(spec[nothing], float, cd);
  var(spec[nothing], float, td);
  var(spec[nothing], float, io);
  var(spec[nothing], float3, ss);
  var(spec[nothing], float3, vb);
  var(spec[nothing], int, ec);
  var(spec[nothing], float, _958);
  for ([var(spec[nothing], int, i) = 0], [i < 64], [i++]) {
    var(spec[nothing], float3, param) = ro;
    var(spec[nothing], float3, param_1) = rd;
    var(spec[nothing], float3, param_2) = oc;
    var(spec[nothing], float, param_3) = oa;
    var(spec[nothing], float, param_4) = cd;
    var(spec[nothing], float, param_5) = td;
    var(spec[nothing], float, param_6) = io;
    var(spec[nothing], float3, param_7) = ss;
    var(spec[nothing], float3, param_8) = vb;
    var(spec[nothing], int, param_9) = ec;
    tr(param, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9);
    oc = param_2;
    oa = param_3;
    cd = param_4;
    td = param_5;
    io = param_6;
    ss = param_7;
    vb = param_8;
    ec = param_9;
    var(spec[nothing], float3, cp) = ro + (rd * cd);
    var(spec[nothing], float3, param_10) = cp;
    var(spec[nothing], float3, param_11) = oc;
    var(spec[nothing], float, param_12) = oa;
    var(spec[nothing], float, param_13) = io;
    var(spec[nothing], float3, param_14) = ss;
    var(spec[nothing], float3, param_15) = vb;
    var(spec[nothing], int, param_16) = ec;
    var(spec[nothing], float3, _940) = nm(param_10, param_11, param_12, param_13, param_14, param_15, param_16);
    oc = param_11;
    oa = param_12;
    io = param_13;
    ss = param_14;
    vb = param_15;
    ec = param_16;
    var(spec[nothing], float3, cn) = _940;
    ro = cp - (cn * 0.00999999977F);
    if ((i % 2) == 0) {
      _958 = 1.0F / io;
    } else {
      _958 = io;
    };
    var(spec[nothing], float3, cr) = refract(rd, cn, _958);
    if ((length(cr) == 0.0F) && (es <= 0)) {
      cr = reflect(rd, cn);
      es = ec;
    };
    if (((max(es, 0) % 3) == 0) && (cd < 128.0F)) {
      rd = cr;
    };
    es--;
    var(spec[nothing], bool, _993) = vb.x > 0.0F;
    var(spec[nothing], bool, _999);
    if (_993) {
      _999 = (i % 2) == 1;
    } else {
      _999 = _993;
    };
    if (_999) {
      oa = pow(clamp(cd / vb.y, 0.0F, 1.0F), vb.z);
    };
    var(spec[nothing], float3, param_17) = rd;
    var(spec[nothing], float3, param_18) = cp;
    var(spec[nothing], float3, param_19) = cr;
    var(spec[nothing], float3, param_20) = cn;
    var(spec[nothing], float, param_21) = cd;
    var(spec[nothing], float3, param_22) = oc;
    var(spec[nothing], float, param_23) = oa;
    var(spec[nothing], float, param_24) = io;
    var(spec[nothing], float3, param_25) = ss;
    var(spec[nothing], float3, param_26) = vb;
    var(spec[nothing], int, param_27) = ec;
    var(spec[nothing], float3, _1033) = px(param_17, param_18, param_19, param_20, param_21, param_22, param_23, param_24, param_25, param_26, param_27);
    oc = param_22;
    oa = param_23;
    io = param_24;
    ss = param_25;
    vb = param_26;
    ec = param_27;
    var(spec[nothing], float3, cc) = _1033;
    fc += (float4(cc * oa, oa) * (1.0F - fc.w));
    if ((fc.w >= 1.0F) || (cd > 128.0F)) {
      break;
    };
  };
  var(spec[nothing], float4, col) = fc / clamp(fc.w, 0.00999999977F, 1.0F).xxxx;
  return <- col;
};

func(spec[nothing], void, mainImage)params(var(spec[out, nothing], float4, fragColor), var(spec[nothing], float2, fragCoord)) {
  var(spec[nothing], float2, coord) = fragCoord;
  var(spec[nothing], float2, param) = coord;
  var(spec[nothing], float2, param_1) = iResolution.xy;
  var(spec[nothing], float, param_2) = iTime;
  var(spec[nothing], float4, _1086) = render(param, param_1, param_2);
  fragColor = _1086;
};

func(spec[nothing], void, frag_main)params() {
  var(spec[nothing], float2, param_1) = inCoord;
  var(spec[nothing], float4, param);
  mainImage(param, param_1);
  outColor = param;
};

func(spec[nothing], SPIRV_Cross_Output, main)params(var(spec[nothing], SPIRV_Cross_Input, stage_input)) {
  inCoord = stage_input.inCoord;
  frag_main();
  var(spec[nothing], SPIRV_Cross_Output, stage_output);
  stage_output.outColor = outColor;
  return <- stage_output;
};



