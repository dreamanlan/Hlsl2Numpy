Texture2D<float4> iChannel0 : register(t0);
SamplerState _iChannel0_sampler : register(s0);
Texture2D<float4> iChannel1 : register(t0);
SamplerState _iChannel1_sampler : register(s0);
TextureCube<float4> iChannel2 : register(t0);
SamplerState _iChannel2_sampler : register(s0);
Texture2D<float4> iChannel3 : register(t0);
SamplerState _iChannel3_sampler : register(s0);

static float4 outColor;
static float2 inCoord;

struct SPIRV_Cross_Input
{
    float2 inCoord : TEXCOORD2;
};

struct SPIRV_Cross_Output
{
    float4 outColor : SV_Target0;
};

static float4 iMouse;
static float3 iResolution;
static float tt;
static float3 glv;
static float iTime;
static float iTimeDelta;
static float iFrameRate;
static int iFrame;
static float iChannelTime[4];
static float3 iChannelResolution[4];
static float4 iDate;
static float iSampleRate;

float mod(float x, float y)
{
    return x - y * floor(x / y);
}

float2 mod(float2 x, float2 y)
{
    return x - y * floor(x / y);
}

float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float4 mod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

float3 lattice(inout float3 p, int iter)
{
    for (int i = 0; i < iter; i++)
    {
        float3 _282 = p;
        float2 _284 = mul(float2x2(float2(0.707106888294219970703125f, 0.70710670948028564453125f), float2(-0.70710670948028564453125f, 0.707106888294219970703125f)), _282.xy);
        p.x = _284.x;
        p.y = _284.y;
        float3 _289 = p;
        float2 _291 = mul(float2x2(float2(0.707106888294219970703125f, 0.70710670948028564453125f), float2(-0.70710670948028564453125f, 0.707106888294219970703125f)), _289.xz);
        p.x = _291.x;
        p.z = _291.y;
        p = abs(p) - 1.0f.xxx;
        float3 _303 = p;
        float2 _305 = mul(float2x2(float2(0.707106888294219970703125f, -0.70710670948028564453125f), float2(0.70710670948028564453125f, 0.707106888294219970703125f)), _303.xy);
        p.x = _305.x;
        p.y = _305.y;
        float3 _310 = p;
        float2 _312 = mul(float2x2(float2(0.707106888294219970703125f, -0.70710670948028564453125f), float2(0.70710670948028564453125f, 0.707106888294219970703125f)), _310.xz);
        p.x = _312.x;
        p.z = _312.y;
    }
    return p;
}

float cy(inout float3 p, float2 s)
{
    p.y += (s.x / 2.0f);
    p.y -= clamp(p.y, 0.0f, s.x);
    return length(p) - s.y;
}

float shatter(inout float3 p, inout float d, float n, float a, float s)
{
    float _234;
    float _243;
    for (float i = 0.0f; i < n; i += 1.0f)
    {
        float3 _171 = p;
        float2 _173 = mul(float2x2(float2(cos(a), sin(a)), float2(-sin(a), cos(a))), _171.xy);
        p.x = _173.x;
        p.y = _173.y;
        float3 _195 = p;
        float2 _197 = mul(float2x2(float2(cos(a * 0.5f), sin(a * 0.5f)), float2(-sin(a * 0.5f), cos(a * 0.5f))), _195.xz);
        p.x = _197.x;
        p.z = _197.y;
        float3 _222 = p;
        float2 _224 = mul(float2x2(float2(cos(a + a), sin(a + a)), float2(-sin(a + a), cos(a + a))), _222.yz);
        p.y = _224.x;
        p.z = _224.y;
        if (mod(i, 3.0f) == 0.0f)
        {
            _234 = p.x;
        }
        else
        {
            if (mod(i, 3.0f) == 1.0f)
            {
                _243 = p.y;
            }
            else
            {
                _243 = p.z;
            }
            _234 = _243;
        }
        float c = _234;
        c = abs(c) - s;
        d = max(d, -c);
    }
    return d;
}

float bx(float3 p, float3 s)
{
    float3 q = abs(p) - s;
    return min(max(q.x, max(q.y, q.z)), 0.0f) + length(max(q, 0.0f.xxx));
}

float mp(inout float3 p, inout float3 oc, inout float oa, inout float io, inout float3 ss, inout float3 vb, inout int ec)
{
    if (iMouse.z > 0.0f)
    {
        float3 _369 = p;
        float2 _371 = mul(float2x2(float2(cos(2.0f * ((iMouse.y / iResolution.y) - 0.5f)), sin(2.0f * ((iMouse.y / iResolution.y) - 0.5f))), float2(-sin(2.0f * ((iMouse.y / iResolution.y) - 0.5f)), cos(2.0f * ((iMouse.y / iResolution.y) - 0.5f)))), _369.yz);
        p.y = _371.x;
        p.z = _371.y;
        float3 _413 = p;
        float2 _415 = mul(float2x2(float2(cos((-7.0f) * ((iMouse.x / iResolution.x) - 0.5f)), sin((-7.0f) * ((iMouse.x / iResolution.x) - 0.5f))), float2(-sin((-7.0f) * ((iMouse.x / iResolution.x) - 0.5f)), cos((-7.0f) * ((iMouse.x / iResolution.x) - 0.5f)))), _413.zx);
        p.z = _415.x;
        p.x = _415.y;
    }
    float3 pp = p;
    float3 _440 = p;
    float2 _442 = mul(float2x2(float2(cos(tt * 0.20000000298023223876953125f), sin(tt * 0.20000000298023223876953125f)), float2(-sin(tt * 0.20000000298023223876953125f), cos(tt * 0.20000000298023223876953125f))), _440.xz);
    p.x = _442.x;
    p.z = _442.y;
    float3 _463 = p;
    float2 _465 = mul(float2x2(float2(cos(tt * 0.20000000298023223876953125f), sin(tt * 0.20000000298023223876953125f)), float2(-sin(tt * 0.20000000298023223876953125f), cos(tt * 0.20000000298023223876953125f))), _463.xy);
    p.x = _465.x;
    p.y = _465.y;
    float3 param = p;
    int param_1 = 3;
    float3 _474 = lattice(param, param_1);
    p = _474;
    float3 param_2 = p;
    float2 param_3 = 1.0f.xx;
    float _480 = cy(param_2, param_3);
    float sd = _480 - 0.0500000007450580596923828125f;
    float3 param_4 = p;
    float param_5 = sd;
    float param_6 = 1.0f;
    float param_7 = sin(tt * 0.100000001490116119384765625f);
    float param_8 = 0.20000000298023223876953125f;
    float _494 = shatter(param_4, param_5, param_6, param_7, param_8);
    sd = _494;
    float3 param_9 = p;
    float3 param_10 = float3(0.100000001490116119384765625f, 2.099999904632568359375f, 8.0f);
    sd = min(sd, bx(param_9, param_10) - 0.300000011920928955078125f);
    float3 param_11 = p;
    float2 param_12 = float2(4.0f, 1.0f);
    float _512 = cy(param_11, param_12);
    sd = lerp(sd, _512, (cos(tt * 0.5f) * 0.5f) + 0.5f);
    sd = abs(sd) - 0.001000000047497451305389404296875f;
    if (sd < 0.001000000047497451305389404296875f)
    {
        oc = lerp(float3(1.0f, 0.100000001490116119384765625f, 0.60000002384185791015625f), float3(0.0f, 0.60000002384185791015625f, 1.0f), pow(length(pp) * 0.180000007152557373046875f, 1.5f).xxx);
        io = 1.10000002384185791015625f;
        oa = 1.0499999523162841796875f - (length(pp) * 0.20000000298023223876953125f);
        ss = 0.0f.xxx;
        vb = float3(0.0f, 2.5f, 2.5f);
        ec = 2;
    }
    return sd;
}

void tr(float3 ro, float3 rd, inout float3 oc, inout float oa, inout float cd, inout float td, inout float io, inout float3 ss, inout float3 vb, inout int ec)
{
    vb.x = 0.0f;
    cd = 0.0f;
    for (float i = 0.0f; i < 64.0f; i += 1.0f)
    {
        float3 param = ro + (rd * cd);
        float3 param_1 = oc;
        float param_2 = oa;
        float param_3 = io;
        float3 param_4 = ss;
        float3 param_5 = vb;
        int param_6 = ec;
        float _580 = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
        oc = param_1;
        oa = param_2;
        io = param_3;
        ss = param_4;
        vb = param_5;
        ec = param_6;
        float sd = _580;
        cd += sd;
        td += sd;
        if ((sd < 9.9999997473787516355514526367188e-05f) || (cd > 128.0f))
        {
            break;
        }
    }
}

float3 nm(float3 cp, inout float3 oc, inout float oa, inout float io, inout float3 ss, inout float3 vb, inout int ec)
{
    float3x3 _623 = float3x3(float3(cp), float3(cp), float3(cp));
    float3x3 k = float3x3(_623[0] - float3(0.001000000047497451305389404296875f, 0.0f, 0.0f), _623[1] - float3(0.0f, 0.001000000047497451305389404296875f, 0.0f), _623[2] - float3(0.0f, 0.0f, 0.001000000047497451305389404296875f));
    float3 param = cp;
    float3 param_1 = oc;
    float param_2 = oa;
    float param_3 = io;
    float3 param_4 = ss;
    float3 param_5 = vb;
    int param_6 = ec;
    float _652 = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
    oc = param_1;
    oa = param_2;
    io = param_3;
    ss = param_4;
    vb = param_5;
    ec = param_6;
    float3 param_7 = k[0];
    float3 param_8 = oc;
    float param_9 = oa;
    float param_10 = io;
    float3 param_11 = ss;
    float3 param_12 = vb;
    int param_13 = ec;
    float _674 = mp(param_7, param_8, param_9, param_10, param_11, param_12, param_13);
    oc = param_8;
    oa = param_9;
    io = param_10;
    ss = param_11;
    vb = param_12;
    ec = param_13;
    float3 param_14 = k[1];
    float3 param_15 = oc;
    float param_16 = oa;
    float param_17 = io;
    float3 param_18 = ss;
    float3 param_19 = vb;
    int param_20 = ec;
    float _696 = mp(param_14, param_15, param_16, param_17, param_18, param_19, param_20);
    oc = param_15;
    oa = param_16;
    io = param_17;
    ss = param_18;
    vb = param_19;
    ec = param_20;
    float3 param_21 = k[2];
    float3 param_22 = oc;
    float param_23 = oa;
    float param_24 = io;
    float3 param_25 = ss;
    float3 param_26 = vb;
    int param_27 = ec;
    float _718 = mp(param_21, param_22, param_23, param_24, param_25, param_26, param_27);
    oc = param_22;
    oa = param_23;
    io = param_24;
    ss = param_25;
    vb = param_26;
    ec = param_27;
    return normalize(_652.xxx - float3(_674, _696, _718));
}

float3 px(float3 rd, float3 cp, float3 cr, float3 cn, float cd, inout float3 oc, inout float oa, inout float io, inout float3 ss, inout float3 vb, inout int ec)
{
    float3 cc = (float3(0.699999988079071044921875f, 0.4000000059604644775390625f, 0.60000002384185791015625f) + (length(pow(abs(rd + float3(0.0f, 0.5f, 0.0f)), 3.0f.xxx)) * 0.300000011920928955078125f).xxx) + glv;
    if (cd > 128.0f)
    {
        oa = 1.0f;
        return cc;
    }
    float3 l = float3(0.4000000059604644775390625f, 0.699999988079071044921875f, 0.800000011920928955078125f);
    float df = clamp(length(cn * l), 0.0f, 1.0f);
    float3 fr = lerp(cc, 0.4000000059604644775390625f.xxx, 0.5f.xxx) * pow(1.0f - df, 3.0f);
    float sp = (1.0f - length(cross(cr, cn * l))) * 0.20000000298023223876953125f;
    float3 param = cp + (cn * 0.300000011920928955078125f);
    float3 param_1 = oc;
    float param_2 = oa;
    float param_3 = io;
    float3 param_4 = ss;
    float3 param_5 = vb;
    int param_6 = ec;
    float _799 = mp(param, param_1, param_2, param_3, param_4, param_5, param_6);
    oc = param_1;
    oa = param_2;
    io = param_3;
    ss = param_4;
    vb = param_5;
    ec = param_6;
    float ao = min(_799 - 0.300000011920928955078125f, 0.300000011920928955078125f) * 0.5f;
    cc = lerp(((((oc * ((df.xxx + fr) + ss)) + fr) + sp.xxx) + ao.xxx) + glv, oc, vb.x.xxx);
    return cc;
}

float4 render(float2 frag, float2 res, float time)
{
    float4 fc = 0.100000001490116119384765625f.xxxx;
    int es = 0;
    tt = mod(time, 260.0f);
    float2 uv = float2(frag.x / res.x, frag.y / res.y);
    uv -= 0.5f.xx;
    uv /= float2(res.y / res.x, 1.0f);
    float3 ro = float3(0.0f, 0.0f, -15.0f);
    float3 rd = normalize(float3(uv, 1.0f));
    float3 oc;
    float oa;
    float cd;
    float td;
    float io;
    float3 ss;
    float3 vb;
    int ec;
    float _958;
    for (int i = 0; i < 64; i++)
    {
        float3 param = ro;
        float3 param_1 = rd;
        float3 param_2 = oc;
        float param_3 = oa;
        float param_4 = cd;
        float param_5 = td;
        float param_6 = io;
        float3 param_7 = ss;
        float3 param_8 = vb;
        int param_9 = ec;
        tr(param, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9);
        oc = param_2;
        oa = param_3;
        cd = param_4;
        td = param_5;
        io = param_6;
        ss = param_7;
        vb = param_8;
        ec = param_9;
        float3 cp = ro + (rd * cd);
        float3 param_10 = cp;
        float3 param_11 = oc;
        float param_12 = oa;
        float param_13 = io;
        float3 param_14 = ss;
        float3 param_15 = vb;
        int param_16 = ec;
        float3 _940 = nm(param_10, param_11, param_12, param_13, param_14, param_15, param_16);
        oc = param_11;
        oa = param_12;
        io = param_13;
        ss = param_14;
        vb = param_15;
        ec = param_16;
        float3 cn = _940;
        ro = cp - (cn * 0.00999999977648258209228515625f);
        if ((i % 2) == 0)
        {
            _958 = 1.0f / io;
        }
        else
        {
            _958 = io;
        }
        float3 cr = refract(rd, cn, _958);
        if ((length(cr) == 0.0f) && (es <= 0))
        {
            cr = reflect(rd, cn);
            es = ec;
        }
        if (((max(es, 0) % 3) == 0) && (cd < 128.0f))
        {
            rd = cr;
        }
        es--;
        bool _993 = vb.x > 0.0f;
        bool _999;
        if (_993)
        {
            _999 = (i % 2) == 1;
        }
        else
        {
            _999 = _993;
        }
        if (_999)
        {
            oa = pow(clamp(cd / vb.y, 0.0f, 1.0f), vb.z);
        }
        float3 param_17 = rd;
        float3 param_18 = cp;
        float3 param_19 = cr;
        float3 param_20 = cn;
        float param_21 = cd;
        float3 param_22 = oc;
        float param_23 = oa;
        float param_24 = io;
        float3 param_25 = ss;
        float3 param_26 = vb;
        int param_27 = ec;
        float3 _1033 = px(param_17, param_18, param_19, param_20, param_21, param_22, param_23, param_24, param_25, param_26, param_27);
        oc = param_22;
        oa = param_23;
        io = param_24;
        ss = param_25;
        vb = param_26;
        ec = param_27;
        float3 cc = _1033;
        fc += (float4(cc * oa, oa) * (1.0f - fc.w));
        if ((fc.w >= 1.0f) || (cd > 128.0f))
        {
            break;
        }
    }
    float4 col = fc / clamp(fc.w, 0.00999999977648258209228515625f, 1.0f).xxxx;
    return col;
}

void mainImage(out float4 fragColor, float2 fragCoord)
{
    float2 coord = fragCoord;
    float2 param = coord;
    float2 param_1 = iResolution.xy;
    float param_2 = iTime;
    float4 _1086 = render(param, param_1, param_2);
    fragColor = _1086;
}

void frag_main()
{
    float2 param_1 = inCoord;
    float4 param;
    mainImage(param, param_1);
    outColor = param;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inCoord = stage_input.inCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.outColor = outColor;
    return stage_output;
}
