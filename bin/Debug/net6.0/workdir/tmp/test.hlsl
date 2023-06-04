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

static float focalDistance;
static float aperture;
static float shadowCone;
static float pixelSize;
static float iTime;
static float3 iResolution;
static float iTimeDelta;
static float iFrameRate;
static int iFrame;
static float iChannelTime[4];
static float3 iChannelResolution[4];
static float4 iMouse;
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

float3x3 lookat(inout float3 fw, float3 up)
{
    fw = normalize(fw);
    float3 rt = normalize(cross(fw, normalize(up)));
    return float3x3(float3(rt), float3(cross(rt, fw)), float3(fw));
}

float hash(float n)
{
    return frac(sin(n) * 4378.54541015625f);
}

float noyz(float3 x)
{
    float3 p = floor(x);
    float3 j = frac(x);
    float n = (p.x + (p.y * 7.0f)) + (p.z * 13.0f);
    float param = n;
    float a = hash(param);
    float param_1 = n + 1.0f;
    float b = hash(param_1);
    float param_2 = n + 7.0f;
    float c = hash(param_2);
    float param_3 = (n + 7.0f) + 1.0f;
    float d = hash(param_3);
    float param_4 = n + 13.0f;
    float e = hash(param_4);
    float param_5 = (n + 1.0f) + 13.0f;
    float f = hash(param_5);
    float param_6 = (n + 7.0f) + 13.0f;
    float g = hash(param_6);
    float param_7 = ((n + 1.0f) + 7.0f) + 13.0f;
    float h = hash(param_7);
    float3 u = (j * j) * (3.0f.xxx - (j * 2.0f));
    return lerp(((a + ((b - a) * u.x)) + ((c - a) * u.y)) + (((((a - b) - c) + d) * u.x) * u.y), ((e + ((f - e) * u.x)) + ((g - e) * u.y)) + (((((e - f) - g) + h) * u.x) * u.y), u.z);
}

float fbm(inout float3 p)
{
    float3 param = p;
    float h = noyz(param);
    float3 _285 = p;
    float3 _286 = _285 * 2.2999999523162841796875f;
    p = _286;
    float3 param_1 = _286;
    h += (0.5f * noyz(param_1));
    float3 param_2 = p * 2.2999999523162841796875f;
    return h + (0.25f * noyz(param_2));
}

void Kaleido(inout float2 v, float power)
{
    float a = (floor(0.5f + ((atan2(v.x, -v.y) * power) / 6.28299999237060546875f)) * 6.28299999237060546875f) / power;
    v = (v * cos(a)) + (float2(v.y, -v.x) * sin(a));
}

float Rect(float3 z, float3 r)
{
    return max(abs(z.x) - r.x, max(abs(z.y) - r.y, abs(z.z) - r.z));
}

float DE(inout float3 z0, inout float4 mcol)
{
    float dW = 100.0f;
    float dD = 100.0f;
    float3 param = (z0 * 0.25f) + 100.0f.xxx;
    float _311 = fbm(param);
    float dC = (((_311 * 0.5f) + (sin(z0.y) * 0.100000001490116119384765625f)) + (sin(z0.z * 0.4000000059604644775390625f) * 0.100000001490116119384765625f)) + min((z0.y * 0.039999999105930328369140625f) + 0.100000001490116119384765625f, 0.100000001490116119384765625f);
    float2 v = floor((float2(z0.x, abs(z0.z)) * 0.5f) + 0.5f.xx);
    float3 _344 = z0;
    float3 _351 = z0;
    float2 _353 = (clamp(_344.xz, (-2.0f).xx, 2.0f.xx) * 2.0f) - _351.xz;
    z0.x = _353.x;
    z0.z = _353.y;
    float r = length(z0.xz);
    float dS = r - 0.60000002384185791015625f;
    if (r < 1.0f)
    {
        float shape = 0.2849999964237213134765625f - (v.x * 0.0199999995529651641845703125f);
        z0.y += (v.y * 0.20000000298023223876953125f);
        float3 z = z0 * 10.0f;
        dS = max(z0.y - 2.5f, r - max(0.10999999940395355224609375f - (z0.y * 0.100000001490116119384765625f), 0.00999999977648258209228515625f));
        float y2 = max(abs(abs(mod(z.y + 0.5f, 2.0f) - 1.0f) - 0.5f) - 0.0500000007450580596923828125f, abs(z.y - 7.099999904632568359375f) - 8.30000019073486328125f);
        float y = sin(clamp(floor(z.y) * shape, -0.4000000059604644775390625f, 3.400000095367431640625f)) * 40.0f;
        float2 param_1 = z.xz;
        float param_2 = 8.0f + floor(y);
        Kaleido(param_1, param_2);
        z.x = param_1.x;
        z.z = param_1.y;
        float3 param_3 = z;
        float3 param_4 = float3(0.89999997615814208984375f + (y * 0.100000001490116119384765625f), 22.0f, 0.89999997615814208984375f + (y * 0.100000001490116119384765625f));
        dW = Rect(param_3, param_4) * 0.07999999821186065673828125f;
        dD = max(z0.y - 1.37000000476837158203125f, max(y2, ((r * 10.0f) - 1.75f) - (sin(clamp((z.y - 0.5f) * shape, -0.0500000007450580596923828125f, 3.4900000095367431640625f)) * 4.0f))) * 0.07999999821186065673828125f;
        dS = min(dS, min(dW, dD));
    }
    dS = min(dS, dC);
    if (dS == dW)
    {
        mcol += float4(0.800000011920928955078125f, 0.89999997615814208984375f, 0.89999997615814208984375f, 1.0f);
    }
    else
    {
        if (dS == dD)
        {
            mcol += float4(0.60000002384185791015625f, 0.4000000059604644775390625f, 0.300000011920928955078125f, 0.0f);
        }
        else
        {
            if (dS == dC)
            {
                mcol += float4(1.0f, 1.0f, 1.0f, -1.0f);
            }
            else
            {
                mcol += float4(0.699999988079071044921875f + (sin(z0.y * 100.0f) * 0.300000011920928955078125f), 1.0f, 0.800000011920928955078125f, 0.0f);
            }
        }
    }
    return dS;
}

float CircleOfConfusion(float t)
{
    return max(abs(focalDistance - t) * aperture, pixelSize * (1.0f + t));
}

float linstep(float a, float b, float t)
{
    return clamp((t - a) / (b - a), 0.0f, 1.0f);
}

float randStep(inout float randSeed)
{
    randSeed += 1.0f;
    return 0.800000011920928955078125f + (0.20000000298023223876953125f * frac(sin(randSeed) * 4375.54541015625f));
}

float FuzzyShadow(float3 ro, float3 rd, float coneGrad, float rCoC, inout float4 mcol, inout float randSeed)
{
    float t = rCoC * 2.0f;
    float d = 1.0f;
    float s = 1.0f;
    for (int i = 0; i < 6; i++)
    {
        if (s < 0.100000001490116119384765625f)
        {
            continue;
        }
        float r = rCoC + (t * coneGrad);
        float3 param = ro + (rd * t);
        float4 param_1 = mcol;
        float _637 = DE(param, param_1);
        mcol = param_1;
        d = _637 + (r * 0.4000000059604644775390625f);
        float param_2 = -r;
        float param_3 = r;
        float param_4 = d;
        s *= linstep(param_2, param_3, param_4);
        float param_5 = randSeed;
        float _656 = randStep(param_5);
        randSeed = param_5;
        t += (abs(d) * _656);
    }
    return clamp((s * 0.75f) + 0.25f, 0.0f, 1.0f);
}

void mainImage(inout float4 O, float2 U)
{
    float4 mcol = 0.0f.xxxx;
    float randSeed = frac(sin(iTime + dot(U, float2(9.12300014495849609375f, 13.430999755859375f))) * 473.71923828125f);
    pixelSize = 2.0f / iResolution.y;
    float tim = iTime * 0.25f;
    float3 ro = float3(cos(tim), (sin(tim * 0.699999988079071044921875f) * 0.5f) + 0.300000011920928955078125f, sin(tim)) * (1.7999999523162841796875f + (0.5f * sin(tim * 0.4099999964237213134765625f)));
    float3 param = float3(0.0f, 0.60000002384185791015625f, sin(tim * 2.2999999523162841796875f)) - ro;
    float3 param_1 = float3(0.100000001490116119384765625f, 1.0f, 0.0f);
    float3x3 _723 = lookat(param, param_1);
    float3 rd = mul(normalize(float3(((U * 2.0f) - iResolution.xy) / iResolution.y.xx, 2.0f)), _723);
    float3 L = float3(0.485071241855621337890625f, 0.72760689258575439453125f, -0.485071241855621337890625f);
    float4 col = 0.0f.xxxx;
    float3 param_2 = ro;
    float4 param_3 = mcol;
    float _749 = DE(param_2, param_3);
    mcol = param_3;
    float t = (_749 * randSeed) * 0.800000011920928955078125f;
    ro += (rd * t);
    float alpha;
    float3 scol;
    for (int i = 0; i < 72; i++)
    {
        if ((col.w > 0.89999997615814208984375f) || (t > 20.0f))
        {
            continue;
        }
        float param_4 = t;
        float rCoC = CircleOfConfusion(param_4);
        float3 param_5 = ro;
        float4 param_6 = mcol;
        float _788 = DE(param_5, param_6);
        mcol = param_6;
        float d = _788;
        float fClouds = max(0.0f, -mcol.w);
        if (d < max(rCoC, fClouds * 0.5f))
        {
            float3 p = ro;
            if (fClouds < 0.100000001490116119384765625f)
            {
                p -= (rd * abs(d - rCoC));
            }
            float2 v = float2(rCoC * 0.333000004291534423828125f, 0.0f);
            float3 param_7 = p - v.xyy;
            float4 param_8 = mcol;
            float _830 = DE(param_7, param_8);
            mcol = param_8;
            float3 param_9 = p + v.xyy;
            float4 param_10 = mcol;
            float _840 = DE(param_9, param_10);
            mcol = param_10;
            float3 param_11 = p - v.yxy;
            float4 param_12 = mcol;
            float _850 = DE(param_11, param_12);
            mcol = param_12;
            float3 param_13 = p + v.yxy;
            float4 param_14 = mcol;
            float _860 = DE(param_13, param_14);
            mcol = param_14;
            float3 param_15 = p - v.yyx;
            float4 param_16 = mcol;
            float _870 = DE(param_15, param_16);
            mcol = param_16;
            float3 param_17 = p + v.yyx;
            float4 param_18 = mcol;
            float _880 = DE(param_17, param_18);
            mcol = param_18;
            float3 N = normalize(float3((-_830) + _840, (-_850) + _860, (-_870) + _880));
            mcol *= 0.14300000667572021484375f;
            if (fClouds > 0.100000001490116119384765625f)
            {
                float dn = clamp(0.5f - d, 0.0f, 1.0f);
                dn *= 2.0f;
                dn *= dn;
                alpha = (1.0f - col.w) * dn;
                scol = 1.0f.xxx * (0.60000002384185791015625f + ((dn * dot(N, L)) * 0.4000000059604644775390625f));
                scol += (float3(1.0f, 0.5f, 0.0f) * (dn * max(0.0f, dot(reflect(rd, N), L))));
            }
            else
            {
                scol = mcol.xyz * (0.20000000298023223876953125f + (0.4000000059604644775390625f * (1.0f + dot(N, L))));
                scol += (float3(1.0f, 0.5f, 0.0f) * (0.5f * pow(max(0.0f, dot(reflect(rd, N), L)), 32.0f)));
                bool _954 = d < (rCoC * 0.25f);
                bool _960;
                if (_954)
                {
                    _960 = mcol.w > 0.89999997615814208984375f;
                }
                else
                {
                    _960 = _954;
                }
                if (_960)
                {
                    rd = reflect(rd, N);
                    d = (-rCoC) * 0.25f;
                    ro = p;
                    t += 1.0f;
                }
                float3 param_19 = p;
                float3 param_20 = L;
                float param_21 = shadowCone;
                float param_22 = rCoC;
                float4 param_23 = mcol;
                float param_24 = randSeed;
                float _984 = FuzzyShadow(param_19, param_20, param_21, param_22, param_23, param_24);
                mcol = param_23;
                randSeed = param_24;
                scol *= _984;
                float param_25 = -rCoC;
                float param_26 = rCoC;
                float param_27 = (-d) - (0.5f * rCoC);
                alpha = (1.0f - col.w) * linstep(param_25, param_26, param_27);
            }
            col += float4(scol * alpha, alpha);
        }
        mcol = 0.0f.xxxx;
        float param_28 = randSeed;
        float _1023 = randStep(param_28);
        randSeed = param_28;
        d = abs(d + (0.3300000131130218505859375f * rCoC)) * _1023;
        ro += (rd * d);
        t += d;
    }
    float3 scol_1 = (float3(0.4000000059604644775390625f, 0.5f, 0.60000002384185791015625f) + (rd * 0.0500000007450580596923828125f)) + (float3(1.0f, 0.75f, 0.5f) * pow(max(0.0f, dot(rd, L)), 100.0f));
    float _1051 = col.w;
    float4 _1055 = col;
    float3 _1057 = _1055.xyz + (scol_1 * (1.0f - clamp(_1051, 0.0f, 1.0f)));
    col.x = _1057.x;
    col.y = _1057.y;
    col.z = _1057.z;
    O = float4(clamp(col.xyz, 0.0f.xxx, 1.0f.xxx), 1.0f);
}

void frag_main()
{
    focalDistance = 1.0f;
    aperture = 0.00999999977648258209228515625f;
    shadowCone = 0.300000011920928955078125f;
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
