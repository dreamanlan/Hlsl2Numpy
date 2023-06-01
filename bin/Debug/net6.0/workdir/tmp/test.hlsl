Texture2D<float4> iChannel0 : register(t0);
SamplerState _iChannel0_sampler : register(s0);
Texture2D<float4> iChannel1 : register(t0);
SamplerState _iChannel1_sampler : register(s0);
Texture3D<float4> iChannel2 : register(t0);
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

static float iTime;
static float3 iResolution;
static float4 iMouse;
static float iTimeDelta;
static float iFrameRate;
static int iFrame;
static float iChannelTime[4];
static float3 iChannelResolution[4];
static float4 iDate;
static float iSampleRate;

float3x3 fromEuler(float3 ang)
{
    float2 a1 = float2(sin(ang.x), cos(ang.x));
    float2 a2 = float2(sin(ang.y), cos(ang.y));
    float2 a3 = float2(sin(ang.z), cos(ang.z));
    float3x3 m;
    m[0] = float3((a1.y * a3.y) + ((a1.x * a2.x) * a3.x), ((a1.y * a2.x) * a3.x) + (a3.y * a1.x), (-a2.y) * a3.x);
    m[1] = float3((-a2.y) * a1.x, a1.y * a2.y, a2.x);
    m[2] = float3(((a3.y * a1.x) * a2.x) + (a1.y * a3.x), (a1.x * a3.x) - ((a1.y * a3.y) * a2.x), a2.y * a3.y);
    return m;
}

float hash(float2 p)
{
    float h = dot(p, float2(127.09999847412109375f, 311.70001220703125f));
    return frac(sin(h) * 43758.546875f);
}

float _noise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    float2 u = (f * f) * (3.0f.xx - (f * 2.0f));
    float2 param = i + 0.0f.xx;
    float2 param_1 = i + float2(1.0f, 0.0f);
    float2 param_2 = i + float2(0.0f, 1.0f);
    float2 param_3 = i + 1.0f.xx;
    return (-1.0f) + (2.0f * lerp(lerp(hash(param), hash(param_1), u.x), lerp(hash(param_2), hash(param_3), u.x), u.y));
}

float sea_octave(inout float2 uv, float choppy)
{
    float2 param = uv;
    uv += _noise(param).xx;
    float2 wv = 1.0f.xx - abs(sin(uv));
    float2 swv = abs(cos(uv));
    wv = lerp(wv, swv, wv);
    return pow(1.0f - pow(wv.x * wv.y, 0.64999997615814208984375f), choppy);
}

float map(float3 p)
{
    float freq = 0.1599999964237213134765625f;
    float amp = 0.60000002384185791015625f;
    float choppy = 4.0f;
    float2 uv = p.xz;
    uv.x *= 0.75f;
    float h = 0.0f;
    for (int i = 0; i < 3; i++)
    {
        float2 param = (uv + (1.0f + (iTime * 0.800000011920928955078125f)).xx) * freq;
        float param_1 = choppy;
        float _399 = sea_octave(param, param_1);
        float d = _399;
        float2 param_2 = (uv - (1.0f + (iTime * 0.800000011920928955078125f)).xx) * freq;
        float param_3 = choppy;
        float _411 = sea_octave(param_2, param_3);
        d += _411;
        h += (d * amp);
        uv = mul(float2x2(float2(1.60000002384185791015625f, 1.2000000476837158203125f), float2(-1.2000000476837158203125f, 1.60000002384185791015625f)), uv);
        freq *= 1.89999997615814208984375f;
        amp *= 0.2199999988079071044921875f;
        choppy = lerp(choppy, 1.0f, 0.20000000298023223876953125f);
    }
    return p.y - h;
}

float heightMapTracing(float3 ori, float3 dir, inout float3 p)
{
    float tm = 0.0f;
    float tx = 1000.0f;
    float3 param = ori + (dir * tx);
    float hx = map(param);
    if (hx > 0.0f)
    {
        p = ori + (dir * tx);
        return tx;
    }
    float3 param_1 = ori + (dir * tm);
    float hm = map(param_1);
    float tmid = 0.0f;
    for (int i = 0; i < 8; i++)
    {
        tmid = lerp(tm, tx, hm / (hm - hx));
        p = ori + (dir * tmid);
        float3 param_2 = p;
        float hmid = map(param_2);
        if (hmid < 0.0f)
        {
            tx = tmid;
            hx = hmid;
        }
        else
        {
            tm = tmid;
            hm = hmid;
        }
    }
    return tmid;
}

float map_detailed(float3 p)
{
    float freq = 0.1599999964237213134765625f;
    float amp = 0.60000002384185791015625f;
    float choppy = 4.0f;
    float2 uv = p.xz;
    uv.x *= 0.75f;
    float h = 0.0f;
    for (int i = 0; i < 5; i++)
    {
        float2 param = (uv + (1.0f + (iTime * 0.800000011920928955078125f)).xx) * freq;
        float param_1 = choppy;
        float _476 = sea_octave(param, param_1);
        float d = _476;
        float2 param_2 = (uv - (1.0f + (iTime * 0.800000011920928955078125f)).xx) * freq;
        float param_3 = choppy;
        float _488 = sea_octave(param_2, param_3);
        d += _488;
        h += (d * amp);
        uv = mul(float2x2(float2(1.60000002384185791015625f, 1.2000000476837158203125f), float2(-1.2000000476837158203125f, 1.60000002384185791015625f)), uv);
        freq *= 1.89999997615814208984375f;
        amp *= 0.2199999988079071044921875f;
        choppy = lerp(choppy, 1.0f, 0.20000000298023223876953125f);
    }
    return p.y - h;
}

float3 getNormal(float3 p, float eps)
{
    float3 param = p;
    float3 n;
    n.y = map_detailed(param);
    float3 param_1 = float3(p.x + eps, p.y, p.z);
    n.x = map_detailed(param_1) - n.y;
    float3 param_2 = float3(p.x, p.y, p.z + eps);
    n.z = map_detailed(param_2) - n.y;
    n.y = eps;
    return normalize(n);
}

float3 getSkyColor(inout float3 e)
{
    e.y = ((max(e.y, 0.0f) * 0.800000011920928955078125f) + 0.20000000298023223876953125f) * 0.800000011920928955078125f;
    return float3(pow(1.0f - e.y, 2.0f), 1.0f - e.y, 0.60000002384185791015625f + ((1.0f - e.y) * 0.4000000059604644775390625f)) * 1.10000002384185791015625f;
}

float diffuse(float3 n, float3 l, float p)
{
    return pow((dot(n, l) * 0.4000000059604644775390625f) + 0.60000002384185791015625f, p);
}

float specular(float3 n, float3 l, float3 e, float s)
{
    float nrm = (s + 8.0f) / 25.1327362060546875f;
    return pow(max(dot(reflect(e, n), l), 0.0f), s) * nrm;
}

float3 getSeaColor(float3 p, float3 n, float3 l, float3 eye, float3 dist)
{
    float fresnel = clamp(1.0f - dot(n, -eye), 0.0f, 1.0f);
    fresnel = min(pow(fresnel, 3.0f), 0.5f);
    float3 param = reflect(eye, n);
    float3 _528 = getSkyColor(param);
    float3 reflected = _528;
    float3 param_1 = n;
    float3 param_2 = l;
    float param_3 = 80.0f;
    float3 refracted = float3(0.0f, 0.0900000035762786865234375f, 0.180000007152557373046875f) + ((float3(0.4799999892711639404296875f, 0.540000021457672119140625f, 0.36000001430511474609375f) * diffuse(param_1, param_2, param_3)) * 0.119999997317790985107421875f);
    float3 color = lerp(refracted, reflected, fresnel.xxx);
    float atten = max(1.0f - (dot(dist, dist) * 0.001000000047497451305389404296875f), 0.0f);
    color += (((float3(0.4799999892711639404296875f, 0.540000021457672119140625f, 0.36000001430511474609375f) * (p.y - 0.60000002384185791015625f)) * 0.180000007152557373046875f) * atten);
    float3 param_4 = n;
    float3 param_5 = l;
    float3 param_6 = eye;
    float param_7 = 60.0f;
    color += specular(param_4, param_5, param_6, param_7).xxx;
    return color;
}

float3 getPixel(float2 coord, float time)
{
    float2 uv = coord / iResolution.xy;
    uv = (uv * 2.0f) - 1.0f.xx;
    uv.x *= (iResolution.x / iResolution.y);
    float3 ang = float3(sin(time * 3.0f) * 0.100000001490116119384765625f, (sin(time) * 0.20000000298023223876953125f) + 0.300000011920928955078125f, time);
    float3 ori = float3(0.0f, 3.5f, time * 5.0f);
    float3 dir = normalize(float3(uv, -2.0f));
    dir.z += (length(uv) * 0.14000000059604644775390625f);
    float3 param = ang;
    dir = mul(fromEuler(param), normalize(dir));
    float3 param_1 = ori;
    float3 param_2 = dir;
    float3 param_3;
    float _764 = heightMapTracing(param_1, param_2, param_3);
    float3 p = param_3;
    float3 dist = p - ori;
    float3 param_4 = p;
    float param_5 = dot(dist, dist) * (0.100000001490116119384765625f / iResolution.x);
    float3 n = getNormal(param_4, param_5);
    float3 light = float3(0.0f, 0.780868828296661376953125f, 0.6246950626373291015625f);
    float3 param_6 = dir;
    float3 _788 = getSkyColor(param_6);
    float3 param_7 = p;
    float3 param_8 = n;
    float3 param_9 = light;
    float3 param_10 = dir;
    float3 param_11 = dist;
    return lerp(_788, getSeaColor(param_7, param_8, param_9, param_10, param_11), pow(smoothstep(0.0f, -0.0199999995529651641845703125f, dir.y), 0.20000000298023223876953125f).xxx);
}

void mainImage(inout float4 fragColor, float2 fragCoord)
{
    float time = (iTime * 0.300000011920928955078125f) + (iMouse.x * 0.00999999977648258209228515625f);
    float3 color = 0.0f.xxx;
    for (int i = -1; i <= 1; i++)
    {
        for (int j = -1; j <= 1; j++)
        {
            float2 uv = fragCoord + (float2(float(i), float(j)) / 3.0f.xx);
            float2 param = uv;
            float param_1 = time;
            color += getPixel(param, param_1);
        }
    }
    color /= 9.0f.xxx;
    fragColor = float4(pow(color, 0.64999997615814208984375f.xxx), 1.0f);
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
