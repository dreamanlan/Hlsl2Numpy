struct CameraState
{
    float3 vPos;
    float3 vTarget;
    float fFov;
};

struct SceneResult
{
    float fDist;
    int iObjectId;
    float3 vUVW;
};

struct SurfaceLighting
{
    float3 vDiffuse;
    float3 vSpecular;
};

struct SurfaceInfo
{
    float3 vPos;
    float3 vNormal;
    float3 vBumpNormal;
    float3 vAlbedo;
    float3 vR0;
    float fSmoothness;
    float3 vEmissive;
    float fTransparency;
    float fRefractiveIndex;
};

struct ArrRayInfo
{
    float3 broadcastHelper;
    float3 vRayOrigin[12];
    float3 vRayDir[12];
    float fStartDist[12];
    float fLengthRemaining[12];
    float fRefractiveIndex[12];
    int iObjectId[12];
    float fDist[12];
    float3 vColor[12];
    float3 vAmount[12];
    int iChild0[12];
    int iChild1[12];
};

struct RayInfo
{
    float3 vRayOrigin;
    float3 vRayDir;
    float fStartDist;
    float fLengthRemaining;
    float fRefractiveIndex;
    int iObjectId;
    float fDist;
    float3 vColor;
    float3 vAmount;
    int iChild0;
    int iChild1;
};

static const RayInfo _664 = { 0.0f.xxx, 0.0f.xxx, 0.0f, -1.0f, 1.0f, -1, 0.0f, 0.0f.xxx, 1.0f.xxx, -1, -1 };

Texture2D<float4> bufferA_iChannel2 : register(t0);
SamplerState _bufferA_iChannel2_sampler : register(s0);
Texture2D<float4> bufferA_iChannel3 : register(t0);
SamplerState _bufferA_iChannel3_sampler : register(s0);
TextureCube<float4> bufferA_iChannel1 : register(t0);
SamplerState _bufferA_iChannel1_sampler : register(s0);
Texture2D<float4> iChannel0 : register(t0);
SamplerState _iChannel0_sampler : register(s0);
Texture2D<float4> iChannel1 : register(t0);
SamplerState _iChannel1_sampler : register(s0);
Texture2D<float4> iChannel2 : register(t0);
SamplerState _iChannel2_sampler : register(s0);
Texture2D<float4> iChannel3 : register(t0);
SamplerState _iChannel3_sampler : register(s0);
Texture2D<float4> bufferA_iChannel0 : register(t0);
SamplerState _bufferA_iChannel0_sampler : register(s0);

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

static float3 g_vSunDir;
static float3 g_vSunColor;
static float3 g_vAmbientColor;
static float fPlaneInFocus;
static float fGolden;
static float3 iResolution;
static float iTime;
static float4 iMouse;
static float iTimeDelta;
static float iFrameRate;
static int iFrame;
static float iChannelTime[4];
static float3 iChannelResolution[4];
static float4 iDate;
static float iSampleRate;

float2 Cam_GetViewCoordFromUV(float2 vUV)
{
    float2 vWindow = (vUV * 2.0f) - 1.0f.xx;
    vWindow.x *= (iResolution.x / iResolution.y);
    return vWindow;
}

float3x3 Cam_GetWorldToCameraRotMatrix(CameraState cameraState)
{
    float3 vForward = normalize(cameraState.vTarget - cameraState.vPos);
    float3 vRight = normalize(cross(float3(0.0f, 1.0f, 0.0f), vForward));
    float3 vUp = normalize(cross(vForward, vRight));
    return float3x3(float3(vRight), float3(vUp), float3(vForward));
}

void Cam_GetCameraRay(float2 vUV, CameraState cam, out float3 vRayOrigin, out float3 vRayDir)
{
    float2 vView = Cam_GetViewCoordFromUV(vUV);
    vRayOrigin = cam.vPos;
    float fPerspDist = 1.0f / tan(radians(cam.fFov));
    vRayDir = normalize(mul(float3(vView, fPerspDist), Cam_GetWorldToCameraRotMatrix(cam)));
}

float GetVignetting(float2 vUV, float fScale, float fPower, float fStrength)
{
    float2 vOffset = ((vUV - 0.5f.xx) * 1.41421353816986083984375f) * fScale;
    float fDist = max(0.0f, 1.0f - length(vOffset));
    float fShade = 1.0f - pow(fDist, fPower);
    fShade = 1.0f - (fShade * fStrength);
    return fShade;
}

void RayInfo_Clear(int i, inout ArrRayInfo arrRayInfo)
{
    RayInfo rayInfo = _664;
    arrRayInfo.vRayOrigin[i] = rayInfo.vRayOrigin;
    arrRayInfo.vRayDir[i] = rayInfo.vRayDir;
    arrRayInfo.fStartDist[i] = rayInfo.fStartDist;
    arrRayInfo.fLengthRemaining[i] = rayInfo.fLengthRemaining;
    arrRayInfo.fRefractiveIndex[i] = rayInfo.fRefractiveIndex;
    arrRayInfo.iObjectId[i] = rayInfo.iObjectId;
    arrRayInfo.fDist[i] = rayInfo.fDist;
    arrRayInfo.vColor[i] = rayInfo.vColor;
    arrRayInfo.vAmount[i] = rayInfo.vAmount;
    arrRayInfo.iChild0[i] = rayInfo.iChild0;
    arrRayInfo.iChild1[i] = rayInfo.iChild1;
}

void RayStack_Reset(inout ArrRayInfo rayStack)
{
    for (int i = 0; i < 12; i++)
    {
        int param = i;
        ArrRayInfo param_1 = rayStack;
        RayInfo_Clear(param, param_1);
        rayStack = param_1;
    }
}

RayInfo RayStack_Get(int i, ArrRayInfo rayStack)
{
    RayInfo rayInfo;
    rayInfo.vRayOrigin = rayStack.vRayOrigin[i];
    rayInfo.vRayDir = rayStack.vRayDir[i];
    rayInfo.fStartDist = rayStack.fStartDist[i];
    rayInfo.fLengthRemaining = rayStack.fLengthRemaining[i];
    rayInfo.fRefractiveIndex = rayStack.fRefractiveIndex[i];
    rayInfo.iObjectId = rayStack.iObjectId[i];
    rayInfo.fDist = rayStack.fDist[i];
    rayInfo.vColor = rayStack.vColor[i];
    rayInfo.vAmount = rayStack.vAmount[i];
    rayInfo.iChild0 = rayStack.iChild0[i];
    rayInfo.iChild1 = rayStack.iChild1[i];
    return rayInfo;
}

void Scene_Union(inout SceneResult a, SceneResult b)
{
    if (b.fDist < a.fDist)
    {
        a = b;
    }
}

float GetDistanceWine(float3 vPos)
{
    float3 vLocalPos = vPos;
    vLocalPos.y -= 2.0f;
    float2 vPos2 = float2(length(vLocalPos.xz), vLocalPos.y);
    float2 vSphOrigin = 0.0f.xx;
    float2 vSphPos = vPos2 - vSphOrigin;
    float fBowlDistance = (length(vSphPos) - 0.60000002384185791015625f) + 0.00999999977648258209228515625f;
    float3 vWaterNormal = float3(0.0f, 1.0f, 0.0f);
    vWaterNormal.x = sin(iTime * 5.0f) * 0.00999999977648258209228515625f;
    vWaterNormal.z = cos(iTime * 5.0f) * 0.00999999977648258209228515625f;
    vWaterNormal = normalize(vWaterNormal);
    float fWaterLevel = dot(vLocalPos, vWaterNormal) - 0.100000001490116119384765625f;
    return max(fBowlDistance, fWaterLevel);
}

float GetDistanceBowl(float3 vPos)
{
    float2 vPos2 = float2(length(vPos.xz), vPos.y);
    float2 vSphOrigin = float2(0.0f, 0.730000019073486328125f);
    float2 vSphPos = vPos2 - vSphOrigin;
    float2 vClosest = vSphPos;
    if (vClosest.y > 0.100000001490116119384765625f)
    {
        vClosest.y = 0.100000001490116119384765625f;
    }
    if (vClosest.y < (-0.699999988079071044921875f))
    {
        vClosest.y = -0.699999988079071044921875f;
    }
    float r = sqrt(1.0f - (vClosest.y * vClosest.y));
    vClosest.x = r;
    float fBowlDistance = distance(vClosest, vSphPos);
    vClosest = vSphPos;
    vClosest.y = -0.699999988079071044921875f;
    r = sqrt(1.0f - (vClosest.y * vClosest.y));
    vClosest.x = min(vClosest.x, r);
    float fBaseDistance = distance(vClosest, vSphPos);
    fBowlDistance = min(fBowlDistance, fBaseDistance);
    return fBowlDistance - 0.02999999932944774627685546875f;
}

float SmoothMin(float a, float b, float k)
{
    float h = clamp(0.5f + ((0.5f * (b - a)) / k), 0.0f, 1.0f);
    return lerp(b, a, h) - ((k * h) * (1.0f - h));
}

float GetDistanceWineGlass(float3 vPos)
{
    float2 vPos2 = float2(length(vPos.xz), vPos.y);
    float2 vSphOrigin = float2(0.0f, 2.0f);
    float2 vSphPos = vPos2 - vSphOrigin;
    float2 vClosest = vSphPos;
    if (vClosest.y > 0.300000011920928955078125f)
    {
        vClosest.y = 0.300000011920928955078125f;
    }
    vClosest = normalize(vClosest) * 0.60000002384185791015625f;
    float fBowlDistance = distance(vClosest, vSphPos) - 0.014999999664723873138427734375f;
    float2 vStemClosest = vPos2;
    vStemClosest.x = 0.0f;
    vStemClosest.y = clamp(vStemClosest.y, 0.0f, 1.35000002384185791015625f);
    float fStemRadius = vStemClosest.y - 0.5f;
    fStemRadius = ((fStemRadius * fStemRadius) * 0.0199999995529651641845703125f) + 0.02999999932944774627685546875f;
    float fStemDistance = distance(vPos2, vStemClosest) - fStemRadius;
    float2 norm = float2(0.3713906705379486083984375f, 0.92847669124603271484375f);
    float2 vBaseClosest = vPos2;
    float fBaseDistance = dot(vPos2 - float2(0.0f, 0.100000001490116119384765625f), norm) - 0.20000000298023223876953125f;
    fBaseDistance = max(fBaseDistance, vPos2.x - 0.5f);
    float param = fBowlDistance;
    float param_1 = fStemDistance;
    float param_2 = 0.20000000298023223876953125f;
    float fDistance = SmoothMin(param, param_1, param_2);
    float param_3 = fDistance;
    float param_4 = fBaseDistance;
    float param_5 = 0.20000000298023223876953125f;
    fDistance = SmoothMin(param_3, param_4, param_5);
    fDistance = max(fDistance, vSphPos.y - 0.5f);
    return fDistance;
}

void Scene_Trim(inout SceneResult a, SceneResult b)
{
    if (a.fDist < (-b.fDist))
    {
        a.fDist = -b.fDist;
    }
}

SceneResult Scene_GetDistance(float3 vPos, int iInsideObject)
{
    float3 vWineGlassPos = float3(0.0f, 0.0f, -2.0f);
    float3 vBowlPos = float3(1.0f, 0.0f, 1.0f);
    SceneResult result;
    result.fDist = vPos.y;
    result.vUVW = vPos;
    result.iObjectId = 0;
    float3 vSphere1Pos = vBowlPos + float3(0.4000000059604644775390625f, 0.5f, 0.20000000298023223876953125f);
    SceneResult sphereResult1;
    sphereResult1.vUVW = vPos - vSphere1Pos;
    sphereResult1.fDist = min(result.fDist, length(vPos - vSphere1Pos) - 0.4000000059604644775390625f);
    sphereResult1.iObjectId = 4;
    SceneResult param = result;
    Scene_Union(param, sphereResult1);
    result = param;
    float3 vSphere2Pos = float3(2.2000000476837158203125f, 0.5f, -0.89999997615814208984375f);
    SceneResult sphereResult2;
    sphereResult2.vUVW = (vPos - vSphere2Pos).zyx;
    sphereResult2.fDist = length(vPos - vSphere2Pos) - 0.5f;
    sphereResult2.iObjectId = 4;
    SceneResult param_1 = result;
    Scene_Union(param_1, sphereResult2);
    result = param_1;
    if (result.fDist > 10.0f)
    {
        result.iObjectId = -1;
    }
    SceneResult wineResult;
    wineResult.vUVW = vPos;
    wineResult.iObjectId = 2;
    float3 param_2 = vPos - vWineGlassPos;
    wineResult.fDist = GetDistanceWine(param_2);
    float fRadius = 1.0f;
    float fHeight = 1.0f;
    SceneResult glassResult;
    glassResult.iObjectId = 1;
    glassResult.fDist = length(vPos - float3(-2.0f, fHeight, 1.0f)) - fRadius;
    float3 param_3 = vPos - vBowlPos;
    glassResult.fDist = min(glassResult.fDist, GetDistanceBowl(param_3));
    glassResult.vUVW = vPos.xzy;
    float3 param_4 = vPos - vWineGlassPos;
    glassResult.fDist = min(glassResult.fDist, GetDistanceWineGlass(param_4));
    SceneResult param_5 = wineResult;
    Scene_Trim(param_5, glassResult);
    wineResult = param_5;
    wineResult.fDist -= 9.9999997473787516355514526367188e-05f;
    if (iInsideObject == 1)
    {
        glassResult.fDist = -glassResult.fDist;
    }
    if (iInsideObject == 2)
    {
        wineResult.fDist = -wineResult.fDist;
    }
    SceneResult param_6 = result;
    Scene_Union(param_6, glassResult);
    result = param_6;
    SceneResult param_7 = result;
    Scene_Union(param_7, wineResult);
    result = param_7;
    return result;
}

SceneResult Scene_Trace(float3 vRayOrigin, float3 vRayDir, float minDist, float maxDist, int iInsideObject)
{
    SceneResult result;
    result.fDist = 0.0f;
    result.vUVW = 0.0f.xxx;
    result.iObjectId = -1;
    float t = minDist;
    for (int i = 0; i < 96; i++)
    {
        result = Scene_GetDistance(vRayOrigin + (vRayDir * t), iInsideObject);
        t += result.fDist;
        if (abs(result.fDist) < 0.001000000047497451305389404296875f)
        {
            break;
        }
        bool _420 = iInsideObject == (-1);
        bool _427;
        if (_420)
        {
            _427 = abs(result.fDist) > 0.100000001490116119384765625f;
        }
        else
        {
            _427 = _420;
        }
        if (_427)
        {
            result.iObjectId = -1;
        }
        if (t > maxDist)
        {
            result.iObjectId = -1;
            t = maxDist;
            break;
        }
    }
    result.fDist = t;
    return result;
}

float4 Env_GetSkyColor(float3 vViewPos, float3 vViewDir)
{
    float4 vResult = float4(0.0f, 0.0f, 1.0f, 1100.0f);
    float3 vEnvMap = bufferA_iChannel1.SampleLevel(_bufferA_iChannel1_sampler, vViewDir, 0.0f).xyz;
    vEnvMap *= vEnvMap;
    float kEnvmapExposure = 0.999000012874603271484375f;
    float3 _1954 = -log2(1.0f.xxx - (vEnvMap * kEnvmapExposure));
    vResult.x = _1954.x;
    vResult.y = _1954.y;
    vResult.z = _1954.z;
    return vResult;
}

float3 Scene_GetNormal(float3 vPos, int iInsideObject)
{
    float2 e = float2(-1.0f, 1.0f);
    float3 vNormal = (((e.yxx * Scene_GetDistance(vPos + (e.yxx * 0.001000000047497451305389404296875f), iInsideObject).fDist) + (e.xxy * Scene_GetDistance(vPos + (e.xxy * 0.001000000047497451305389404296875f), iInsideObject).fDist)) + (e.xyx * Scene_GetDistance(vPos + (e.xyx * 0.001000000047497451305389404296875f), iInsideObject).fDist)) + (e.yyy * Scene_GetDistance(vPos + (e.yyy * 0.001000000047497451305389404296875f), iInsideObject).fDist);
    if (dot(vNormal, vNormal) < 9.9999997473787516355514526367188e-06f)
    {
        return float3(0.0f, 1.0f, 0.0f);
    }
    return normalize(vNormal);
}

SurfaceInfo Scene_GetSurfaceInfo(float3 vRayOrigin, float3 vRayDir, SceneResult traceResult, int iInsideObject)
{
    SurfaceInfo surfaceInfo;
    surfaceInfo.vPos = vRayOrigin + (vRayDir * traceResult.fDist);
    surfaceInfo.vNormal = Scene_GetNormal(surfaceInfo.vPos, iInsideObject);
    surfaceInfo.vBumpNormal = surfaceInfo.vNormal;
    surfaceInfo.vAlbedo = 1.0f.xxx;
    surfaceInfo.vR0 = 0.00999999977648258209228515625f.xxx;
    surfaceInfo.fSmoothness = 1.0f;
    surfaceInfo.vEmissive = 0.0f.xxx;
    surfaceInfo.fTransparency = 0.0f;
    surfaceInfo.fRefractiveIndex = 1.0f;
    if (traceResult.iObjectId == 0)
    {
        surfaceInfo.vR0 = 0.0199999995529651641845703125f.xxx;
        surfaceInfo.vAlbedo = bufferA_iChannel2.SampleLevel(_bufferA_iChannel2_sampler, traceResult.vUVW.xz * 0.5f, 0.0f).xyz;
        surfaceInfo.vAlbedo *= surfaceInfo.vAlbedo;
        surfaceInfo.fSmoothness = clamp(1.0f - ((surfaceInfo.vAlbedo.x * surfaceInfo.vAlbedo.x) * 2.0f), 0.0f, 1.0f);
        surfaceInfo.vAlbedo *= 0.25f;
        float fDist = length(surfaceInfo.vPos.xz);
        float fCheckerAmount = clamp((1.0f - (fDist * 0.100000001490116119384765625f)) + (surfaceInfo.vAlbedo.x * 0.5f), 0.0f, 1.0f);
        float fChecker = step(frac((floor(traceResult.vUVW.x) + floor(traceResult.vUVW.z)) * 0.5f), 0.25f);
        float3 vChecker;
        if (fChecker > 0.0f)
        {
            vChecker = 1.0f.xxx;
        }
        else
        {
            vChecker = 0.100000001490116119384765625f.xxx;
        }
        surfaceInfo.vAlbedo = lerp(surfaceInfo.vAlbedo, vChecker, fCheckerAmount.xxx);
        surfaceInfo.vR0 = lerp(surfaceInfo.vR0, 0.100000001490116119384765625f.xxx, fCheckerAmount.xxx);
        surfaceInfo.fSmoothness = lerp(surfaceInfo.fSmoothness, 1.0f, fCheckerAmount);
    }
    if (traceResult.iObjectId == 4)
    {
        float fStripe = step(frac(dot(traceResult.vUVW * 5.0f, float3(1.0f, 0.20000000298023223876953125f, 0.4000000059604644775390625f))), 0.5f);
        if (fStripe > 0.0f)
        {
            surfaceInfo.vAlbedo = float3(0.100000001490116119384765625f, 0.0500000007450580596923828125f, 1.0f);
        }
        else
        {
            surfaceInfo.vAlbedo = float3(1.0f, 0.0500000007450580596923828125f, 0.100000001490116119384765625f);
        }
    }
    if (traceResult.iObjectId == 1)
    {
        surfaceInfo.vR0 = 0.0199999995529651641845703125f.xxx;
        float3 vAlbedo = bufferA_iChannel3.SampleLevel(_bufferA_iChannel3_sampler, traceResult.vUVW.xy * 2.0f, 0.0f).xyz;
        vAlbedo *= vAlbedo;
        vAlbedo *= float3(1.0f, 0.100000001490116119384765625f, 0.5f);
        surfaceInfo.vAlbedo = vAlbedo;
        surfaceInfo.fSmoothness = clamp(1.0f - (surfaceInfo.vAlbedo.x * 2.0f), 0.0f, 0.89999997615814208984375f);
        surfaceInfo.fTransparency = clamp((surfaceInfo.vPos.y * 5.0f) + (surfaceInfo.vAlbedo.y * 3.0f), 0.0f, 1.0f);
        bool _1469 = surfaceInfo.vPos.x < 0.0f;
        bool _1476;
        if (!_1469)
        {
            _1476 = surfaceInfo.vPos.z < 0.0f;
        }
        else
        {
            _1476 = _1469;
        }
        if (_1476)
        {
            surfaceInfo.vAlbedo = 0.0f.xxx;
            surfaceInfo.fSmoothness = 0.89999997615814208984375f;
            surfaceInfo.fTransparency = 1.0f - (vAlbedo.y * 0.20000000298023223876953125f);
        }
        surfaceInfo.fRefractiveIndex = 1.5f;
        float fLipStickDist = length(surfaceInfo.vPos - float3(0.300000011920928955078125f, 3.099999904632568359375f, -2.900000095367431640625f)) - 1.0f;
        if (fLipStickDist < 0.0f)
        {
            surfaceInfo.fTransparency = clamp((1.0f + (fLipStickDist * 2.0f)) - vAlbedo.x, 0.0f, 1.0f);
            surfaceInfo.vAlbedo = float3(0.5f, 0.0f, 0.0f) * (1.0f - surfaceInfo.fTransparency);
        }
    }
    if (traceResult.iObjectId == 2)
    {
        surfaceInfo.vR0 = 0.0199999995529651641845703125f.xxx;
        surfaceInfo.vAlbedo = 0.0f.xxx;
        surfaceInfo.fSmoothness = 0.89999997615814208984375f;
        surfaceInfo.fTransparency = 1.0f;
        surfaceInfo.fRefractiveIndex = 1.2999999523162841796875f;
    }
    if (traceResult.iObjectId == iInsideObject)
    {
        surfaceInfo.fRefractiveIndex = 1.0f;
    }
    return surfaceInfo;
}

float Scene_TraceShadow(float3 vRayOrigin, float3 vRayDir, float fMinDist, float fLightDist)
{
    float res = 1.0f;
    float t = fMinDist;
    for (int i = 0; i < 16; i++)
    {
        float h = Scene_GetDistance(vRayOrigin + (vRayDir * t), -1).fDist;
        res = min(res, (8.0f * h) / t);
        t += clamp(h, 0.0199999995529651641845703125f, 0.100000001490116119384765625f);
        if ((h < 9.9999997473787516355514526367188e-05f) || (t > fLightDist))
        {
            break;
        }
    }
    return clamp(res, 0.0f, 1.0f);
}

float Light_GIV(float dotNV, float k)
{
    return 1.0f / (((dotNV + 9.9999997473787516355514526367188e-05f) * (1.0f - k)) + k);
}

void Light_Add(inout SurfaceLighting lighting, SurfaceInfo surface, float3 vViewDir, float3 vLightDir, float3 vLightColour)
{
    float fNDotL = clamp(dot(vLightDir, surface.vBumpNormal), 0.0f, 1.0f);
    lighting.vDiffuse += (vLightColour * fNDotL);
    float3 vH = normalize((-vViewDir) + vLightDir);
    float fNdotV = clamp(dot(-vViewDir, surface.vBumpNormal), 0.0f, 1.0f);
    float fNdotH = clamp(dot(surface.vBumpNormal, vH), 0.0f, 1.0f);
    float alpha = 1.0f - surface.fSmoothness;
    float alphaSqr = alpha * alpha;
    float denom = ((fNdotH * fNdotH) * (alphaSqr - 1.0f)) + 1.0f;
    float d = alphaSqr / ((3.1415927410125732421875f * denom) * denom);
    float k = alpha / 2.0f;
    float param = fNDotL;
    float param_1 = k;
    float param_2 = fNdotV;
    float param_3 = k;
    float vis = Light_GIV(param, param_1) * Light_GIV(param_2, param_3);
    float fSpecularIntensity = (d * vis) * fNDotL;
    lighting.vSpecular += (vLightColour * fSpecularIntensity);
}

void Light_AddDirectional(inout SurfaceLighting lighting, SurfaceInfo surface, float3 vViewDir, float3 vLightDir, float3 vLightColour)
{
    float fAttenuation = 1.0f;
    float arg = 0.100000001490116119384765625f;
    float arg_1 = 10.0f;
    float fShadowFactor = Scene_TraceShadow(surface.vPos, vLightDir, arg, arg_1);
    SurfaceLighting param = lighting;
    SurfaceInfo param_1 = surface;
    Light_Add(param, param_1, vViewDir, vLightDir, (vLightColour * fShadowFactor) * fAttenuation);
    lighting = param;
}

float Scene_GetAmbientOcclusion(float3 vPos, float3 vDir)
{
    float fOcclusion = 0.0f;
    float fScale = 1.0f;
    for (int i = 0; i < 5; i++)
    {
        float fOffsetDist = 0.00999999977648258209228515625f + ((1.0f * float(i)) / 4.0f);
        float3 vAOPos = (vDir * fOffsetDist) + vPos;
        float fDist = Scene_GetDistance(vAOPos, -1).fDist;
        fOcclusion += ((fOffsetDist - fDist) * fScale);
        fScale *= 0.4000000059604644775390625f;
    }
    return clamp(1.0f - (2.0f * fOcclusion), 0.0f, 1.0f);
}

SurfaceLighting Scene_GetSurfaceLighting(float3 vViewDir, SurfaceInfo surfaceInfo)
{
    SurfaceLighting surfaceLighting;
    surfaceLighting.vDiffuse = 0.0f.xxx;
    surfaceLighting.vSpecular = 0.0f.xxx;
    SurfaceLighting param = surfaceLighting;
    SurfaceInfo param_1 = surfaceInfo;
    Light_AddDirectional(param, param_1, vViewDir, g_vSunDir, g_vSunColor);
    surfaceLighting = param;
    float fAO = Scene_GetAmbientOcclusion(surfaceInfo.vPos, surfaceInfo.vNormal);
    surfaceLighting.vDiffuse += (g_vAmbientColor * (fAO * ((surfaceInfo.vBumpNormal.y * 0.5f) + 0.5f)));
    return surfaceLighting;
}

float3 Light_GetFresnel(float3 vView, float3 vNormal, float3 vR0, float fGloss)
{
    float NdotV = max(0.0f, dot(vView, vNormal));
    return vR0 + (((1.0f.xxx - vR0) * pow(1.0f - NdotV, 5.0f)) * pow(fGloss, 20.0f));
}

void RayStack_Set(int i, RayInfo rayInfo, inout ArrRayInfo rayStack)
{
    rayStack.vRayOrigin[i] = rayInfo.vRayOrigin;
    rayStack.vRayDir[i] = rayInfo.vRayDir;
    rayStack.fStartDist[i] = rayInfo.fStartDist;
    rayStack.fLengthRemaining[i] = rayInfo.fLengthRemaining;
    rayStack.fRefractiveIndex[i] = rayInfo.fRefractiveIndex;
    rayStack.iObjectId[i] = rayInfo.iObjectId;
    rayStack.fDist[i] = rayInfo.fDist;
    rayStack.vColor[i] = rayInfo.vColor;
    rayStack.vAmount[i] = rayInfo.vAmount;
    rayStack.iChild0[i] = rayInfo.iChild0;
    rayStack.iChild1[i] = rayInfo.iChild1;
}

float3 Env_ApplyAtmosphere(float3 vColor, float3 vRayOrigin, float3 vRayDir, float fDist, int iInsideObject)
{
    float3 vResult = vColor;
    if ((iInsideObject == 1) || (iInsideObject == 2))
    {
        float3 vExtCol = 0.0f.xxx;
        if (iInsideObject == 2)
        {
            vExtCol = float3(0.0f, 0.5f, 0.9900000095367431640625f);
        }
        else
        {
            if (vRayOrigin.z > 0.0f)
            {
                if (vRayOrigin.x < 0.0f)
                {
                    vExtCol = float3(0.9900000095367431640625f, 0.9900000095367431640625f, 0.0f);
                }
                else
                {
                    vExtCol = float3(0.0f, 0.800000011920928955078125f, 0.20000000298023223876953125f);
                    vExtCol *= 20.0f;
                }
            }
        }
        vResult *= exp((-vExtCol) * fDist);
    }
    return vResult;
}

float3 FX_Apply(float3 vColor, float3 vRayOrigin, float3 vRayDir, float fDist)
{
    return vColor;
}

float4 Scene_GetColorAndDepth(float3 vInRayOrigin, float3 vInRayDir)
{
    float3 vResultColor = 0.0f.xxx;
    int ix = 0;
    int stackCurrent = 0;
    int stackEnd = 1;
    ArrRayInfo rayStack;
    ArrRayInfo param = rayStack;
    RayStack_Reset(param);
    rayStack = param;
    rayStack.vRayOrigin[0] = vInRayOrigin;
    rayStack.vRayDir[0] = vInRayDir;
    rayStack.fStartDist[0] = 0.0f;
    rayStack.fLengthRemaining[0] = 1000.0f;
    rayStack.fRefractiveIndex[0] = 1.0f;
    rayStack.vAmount[0] = 1.0f.xxx;
    rayStack.iChild0[0] = -1;
    rayStack.iChild1[0] = -1;
    RayInfo refractRayInfo;
    RayInfo reflectRayInfo;
    for (int iPassIndex = 0; iPassIndex < 12; iPassIndex++)
    {
        if (ix >= 12)
        {
            break;
        }
        stackCurrent = clamp(ix, 0, 11);
        int param_1 = stackCurrent;
        ArrRayInfo param_2 = rayStack;
        RayInfo rayInfo = RayStack_Get(param_1, param_2);
        if (rayInfo.fLengthRemaining <= 0.0f)
        {
            continue;
        }
        rayInfo.iChild0 = -1;
        rayInfo.iChild1 = -1;
        float param_3 = rayInfo.fStartDist;
        float param_4 = rayInfo.fLengthRemaining;
        int param_5 = rayInfo.iObjectId;
        SceneResult traceResult = Scene_Trace(rayInfo.vRayOrigin, rayInfo.vRayDir, param_3, param_4, param_5);
        rayInfo.fDist = traceResult.fDist;
        rayInfo.vColor = 0.0f.xxx;
        float3 vReflectance = 1.0f.xxx;
        if (traceResult.iObjectId < 0)
        {
            rayInfo.vColor = Env_GetSkyColor(rayInfo.vRayOrigin, rayInfo.vRayDir).xyz;
        }
        else
        {
            SceneResult param_6 = traceResult;
            int param_7 = rayInfo.iObjectId;
            SurfaceInfo surfaceInfo = Scene_GetSurfaceInfo(rayInfo.vRayOrigin, rayInfo.vRayDir, param_6, param_7);
            SurfaceInfo param_8 = surfaceInfo;
            SurfaceLighting surfaceLighting = Scene_GetSurfaceLighting(rayInfo.vRayDir, param_8);
            float NdotV = clamp(dot(surfaceInfo.vBumpNormal, -rayInfo.vRayDir), 0.0f, 1.0f);
            float3 param_9 = -rayInfo.vRayDir;
            float3 param_10 = surfaceInfo.vBumpNormal;
            float3 param_11 = surfaceInfo.vR0;
            float param_12 = surfaceInfo.fSmoothness;
            vReflectance = Light_GetFresnel(param_9, param_10, param_11, param_12);
            rayInfo.vColor = ((surfaceInfo.vAlbedo * surfaceLighting.vDiffuse) + surfaceInfo.vEmissive) * (1.0f.xxx - vReflectance);
            float3 vReflectAmount = vReflectance;
            float3 vTranmitAmount = 1.0f.xxx - vReflectance;
            vTranmitAmount *= surfaceInfo.fTransparency;
            bool doReflection = true;
            if (surfaceInfo.fTransparency > 0.0f)
            {
                float3 vTestAmount = vTranmitAmount * rayInfo.vAmount;
                if (((vTestAmount.x + vTestAmount.y) + vTestAmount.z) > 0.00999999977648258209228515625f)
                {
                    refractRayInfo.vAmount = vTranmitAmount;
                    refractRayInfo.vRayOrigin = surfaceInfo.vPos;
                    refractRayInfo.iObjectId = traceResult.iObjectId;
                    refractRayInfo.vRayDir = refract(rayInfo.vRayDir, surfaceInfo.vBumpNormal, rayInfo.fRefractiveIndex / surfaceInfo.fRefractiveIndex);
                    if (traceResult.iObjectId == rayInfo.iObjectId)
                    {
                        refractRayInfo.iObjectId = -1;
                    }
                    if (length(refractRayInfo.vRayDir) > 0.0f)
                    {
                        refractRayInfo.vRayDir = normalize(refractRayInfo.vRayDir);
                        refractRayInfo.fStartDist = abs(0.100000001490116119384765625f / dot(refractRayInfo.vRayDir, surfaceInfo.vNormal));
                        refractRayInfo.fLengthRemaining = rayInfo.fLengthRemaining - traceResult.fDist;
                        refractRayInfo.fDist = 1.0f - rayInfo.fDist;
                        refractRayInfo.fRefractiveIndex = surfaceInfo.fRefractiveIndex;
                        rayInfo.iChild1 = stackEnd;
                        rayInfo.vColor *= (1.0f - surfaceInfo.fTransparency);
                        refractRayInfo.vAmount *= surfaceInfo.fTransparency;
                        int param_13 = stackEnd;
                        RayInfo param_14 = refractRayInfo;
                        ArrRayInfo param_15 = rayStack;
                        RayStack_Set(param_13, param_14, param_15);
                        rayStack = param_15;
                        stackEnd++;
                        stackEnd = clamp(stackEnd, 0, 11);
                        doReflection = false;
                    }
                    else
                    {
                        vReflectAmount += vTranmitAmount;
                    }
                }
            }
            if (doReflection)
            {
                float3 vTestAmount_1 = vReflectAmount * rayInfo.vAmount;
                if (((vTestAmount_1.x + vTestAmount_1.y) + vTestAmount_1.z) > 0.00999999977648258209228515625f)
                {
                    reflectRayInfo.vAmount = vReflectAmount;
                    reflectRayInfo.vRayOrigin = surfaceInfo.vPos;
                    reflectRayInfo.vRayDir = normalize(reflect(rayInfo.vRayDir, surfaceInfo.vBumpNormal));
                    reflectRayInfo.iObjectId = rayInfo.iObjectId;
                    reflectRayInfo.fStartDist = abs(0.00999999977648258209228515625f / dot(reflectRayInfo.vRayDir, surfaceInfo.vNormal));
                    reflectRayInfo.fLengthRemaining = rayInfo.fLengthRemaining - traceResult.fDist;
                    reflectRayInfo.fRefractiveIndex = rayInfo.fRefractiveIndex;
                    rayInfo.iChild0 = stackEnd;
                    int param_16 = stackEnd;
                    RayInfo param_17 = reflectRayInfo;
                    ArrRayInfo param_18 = rayStack;
                    RayStack_Set(param_16, param_17, param_18);
                    rayStack = param_18;
                    stackEnd++;
                    stackEnd = clamp(stackEnd, 0, 11);
                }
            }
            rayInfo.vColor += (surfaceLighting.vSpecular * vReflectance);
        }
        int param_19 = stackCurrent;
        RayInfo param_20 = rayInfo;
        ArrRayInfo param_21 = rayStack;
        RayStack_Set(param_19, param_20, param_21);
        rayStack = param_21;
        ix++;
    }
    for (int iStackPos = 11; iStackPos >= 0; iStackPos--)
    {
        int param_22 = iStackPos;
        ArrRayInfo param_23 = rayStack;
        RayInfo rayInfo_1 = RayStack_Get(param_22, param_23);
        if (rayInfo_1.fLengthRemaining <= 0.0f)
        {
            continue;
        }
        if (rayInfo_1.iChild0 >= 0)
        {
            int param_24 = rayInfo_1.iChild0;
            ArrRayInfo param_25 = rayStack;
            RayInfo childRayInfo = RayStack_Get(param_24, param_25);
            if (childRayInfo.fDist > 0.0f)
            {
                rayInfo_1.vColor += (childRayInfo.vAmount * childRayInfo.vColor);
            }
        }
        if (rayInfo_1.iChild1 >= 0)
        {
            int param_26 = rayInfo_1.iChild1;
            ArrRayInfo param_27 = rayStack;
            RayInfo childRayInfo_1 = RayStack_Get(param_26, param_27);
            if (childRayInfo_1.fDist > 0.0f)
            {
                rayInfo_1.vColor += (childRayInfo_1.vAmount * childRayInfo_1.vColor);
            }
        }
        rayInfo_1.vColor = Env_ApplyAtmosphere(rayInfo_1.vColor, rayInfo_1.vRayOrigin, rayInfo_1.vRayDir, rayInfo_1.fDist, rayInfo_1.iObjectId);
        float3 param_28 = rayInfo_1.vColor;
        rayInfo_1.vColor = FX_Apply(param_28, rayInfo_1.vRayOrigin, rayInfo_1.vRayDir, rayInfo_1.fDist);
        int param_29 = iStackPos;
        RayInfo param_30 = rayInfo_1;
        ArrRayInfo param_31 = rayStack;
        RayStack_Set(param_29, param_30, param_31);
        rayStack = param_31;
    }
    SceneResult firstTraceResult;
    if (firstTraceResult.iObjectId >= 10)
    {
        firstTraceResult.fDist = -firstTraceResult.fDist;
    }
    return float4(rayStack.vColor[0], rayStack.fDist[0]);
}

float GetCoC(float fDistance, float fPlaneInFocus_1)
{
    float fAperture = 0.0500000007450580596923828125f;
    float fFocalLength = 0.800000011920928955078125f;
    return abs((fAperture * (fFocalLength * (fDistance - fPlaneInFocus_1))) / (fDistance * (fPlaneInFocus_1 - fFocalLength)));
}

float4 MainCommon(float3 vRayOrigin, float3 vRayDir, float fShade)
{
    float4 vColorLinAmdDepth = Scene_GetColorAndDepth(vRayOrigin, vRayDir);
    float4 _2024 = vColorLinAmdDepth;
    float3 _2026 = max(_2024.xyz, 0.0f.xxx);
    vColorLinAmdDepth.x = _2026.x;
    vColorLinAmdDepth.y = _2026.y;
    vColorLinAmdDepth.z = _2026.z;
    float4 vFragColor = vColorLinAmdDepth;
    float4 _2036 = vFragColor;
    float3 _2038 = _2036.xyz * fShade;
    vFragColor.x = _2038.x;
    vFragColor.y = _2038.y;
    vFragColor.z = _2038.z;
    float param = vColorLinAmdDepth.w;
    float param_1 = fPlaneInFocus;
    vFragColor.w = GetCoC(param, param_1);
    return vFragColor;
}

void fillBufferA(out float4 vFragColor, float2 vFragCoord)
{
    float2 vUV = vFragCoord / iResolution.xy;
    float fAngle = (iMouse.x / iResolution.x) * 6.283185482025146484375f;
    float fElevation = (iMouse.y / iResolution.y) * 1.57079637050628662109375f;
    if (iMouse.x <= 0.0f)
    {
        fAngle = -2.2999999523162841796875f;
        fElevation = 0.5f;
    }
    float fDist = 6.0f;
    CameraState cam;
    cam.vPos = float3((sin(fAngle) * fDist) * cos(fElevation), sin(fElevation) * fDist, (cos(fAngle) * fDist) * cos(fElevation));
    cam.vTarget = float3(0.0f, 0.5f, 0.0f);
    cam.fFov = 20.0f;
    float3 param;
    float3 param_1;
    Cam_GetCameraRay(vUV, cam, param, param_1);
    float3 vRayOrigin = param;
    float3 vRayDir = param_1;
    float param_2 = 0.699999988079071044921875f;
    float param_3 = 2.0f;
    float param_4 = 1.0f;
    float fShade = GetVignetting(vUV, param_2, param_3, param_4);
    float3 param_5 = vRayOrigin;
    float3 param_6 = vRayDir;
    float param_7 = fShade;
    vFragColor = MainCommon(param_5, param_6, param_7);
}

float3 ColorGrade(inout float3 vColor)
{
    float3 vHue = float3(1.0f, 0.699999988079071044921875f, 0.20000000298023223876953125f);
    float3 vGamma = 1.0f.xxx + (vHue * 0.60000002384185791015625f);
    float3 vGain = 0.89999997615814208984375f.xxx + ((vHue * vHue) * 8.0f);
    vColor *= 2.0f;
    float fMaxLum = 100.0f;
    vColor /= fMaxLum.xxx;
    vColor = pow(vColor, vGamma);
    vColor *= vGain;
    vColor *= fMaxLum;
    return vColor;
}

float3 Tonemap(float3 x)
{
    float a = 0.00999999977648258209228515625f;
    float b = 0.1319999992847442626953125f;
    float c = 0.00999999977648258209228515625f;
    float d = 0.16300000250339508056640625f;
    float e = 0.101000003516674041748046875f;
    return (x * ((x * a) + b.xxx)) / ((x * ((x * c) + d.xxx)) + e.xxx);
}

void mainImage(inout float4 fragColor, float2 fragCoord)
{
    float2 vUV = fragCoord / iResolution.xy;
    float4 vSample = iChannel0.SampleLevel(_iChannel0_sampler, vUV, 0.0f);
    float fCoC = vSample.w;
    float3 vResult = vSample.xyz;
    float fTot = 0.0f;
    float2 vangle = float2(0.0f, fCoC);
    if (abs(fCoC) > 0.0f)
    {
        vResult *= fCoC;
        fTot += fCoC;
        float fBlurTaps = 32.0f;
        for (int i = 1; i < 32; i++)
        {
            float t = float(i) / fBlurTaps;
            float fTheta = (t * fBlurTaps) * fGolden;
            float fRadius = (fCoC * sqrt(t * fBlurTaps)) / sqrt(fBlurTaps);
            float2 vTapUV = vUV + (float2(sin(fTheta), cos(fTheta)) * fRadius);
            float4 vTapSample = iChannel0.SampleLevel(_iChannel0_sampler, vTapUV, 0.0f);
            float fCoC2 = vTapSample.w;
            float fWeight = max(0.001000000047497451305389404296875f, fCoC2);
            vResult += (vTapSample.xyz * fWeight);
            fTot += fWeight;
        }
        vResult /= fTot.xxx;
    }
    fragColor = float4(vResult, 1.0f);
    float fExposure = 3.0f;
    float4 _2327 = fragColor;
    float3 _2330 = _2327.xyz * fExposure;
    fragColor.x = _2330.x;
    fragColor.y = _2330.y;
    fragColor.z = _2330.z;
    float3 param = fragColor.xyz;
    float3 _2340 = ColorGrade(param);
    fragColor.x = _2340.x;
    fragColor.y = _2340.y;
    fragColor.z = _2340.z;
    float3 param_1 = fragColor.xyz;
    float3 _2350 = Tonemap(param_1);
    fragColor.x = _2350.x;
    fragColor.y = _2350.y;
    fragColor.z = _2350.z;
}

void frag_main()
{
    g_vSunDir = float3(0.842151939868927001953125f, 0.33686077594757080078125f, 0.4210759699344635009765625f);
    g_vSunColor = float3(5.0f, 3.5f, 2.5f);
    g_vAmbientColor = float3(0.800000011920928955078125f, 0.20000000298023223876953125f, 0.100000001490116119384765625f);
    fPlaneInFocus = 5.0f;
    fGolden = 2.3999626636505126953125f;
    float2 param_1 = inCoord;
    float4 param;
    fillBufferA(param, param_1);
    outColor = param;
    float2 param_3 = inCoord;
    float4 param_2;
    mainImage(param_2, param_3);
    outColor = param_2;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    inCoord = stage_input.inCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.outColor = outColor;
    return stage_output;
}
