// Rewrite unchanged result:
struct(CameraState) {
  field(spec[nothing], float3, vPos);
  field(spec[nothing], float3, vTarget);
  field(spec[nothing], float, fFov);
};
struct(SceneResult) {
  field(spec[nothing], float, fDist);
  field(spec[nothing], int, iObjectId);
  field(spec[nothing], float3, vUVW);
};
struct(SurfaceLighting) {
  field(spec[nothing], float3, vDiffuse);
  field(spec[nothing], float3, vSpecular);
};
struct(SurfaceInfo) {
  field(spec[nothing], float3, vPos);
  field(spec[nothing], float3, vNormal);
  field(spec[nothing], float3, vBumpNormal);
  field(spec[nothing], float3, vAlbedo);
  field(spec[nothing], float3, vR0);
  field(spec[nothing], float, fSmoothness);
  field(spec[nothing], float3, vEmissive);
  field(spec[nothing], float, fTransparency);
  field(spec[nothing], float, fRefractiveIndex);
};
struct(ArrRayInfo) {
  field(spec[nothing], float3, broadcastHelper);
  field(spec[nothing], float3, vRayOrigin[12]);
  field(spec[nothing], float3, vRayDir[12]);
  field(spec[nothing], float, fStartDist[12]);
  field(spec[nothing], float, fLengthRemaining[12]);
  field(spec[nothing], float, fRefractiveIndex[12]);
  field(spec[nothing], int, iObjectId[12]);
  field(spec[nothing], float, fDist[12]);
  field(spec[nothing], float3, vColor[12]);
  field(spec[nothing], float3, vAmount[12]);
  field(spec[nothing], int, iChild0[12]);
  field(spec[nothing], int, iChild1[12]);
};
struct(RayInfo) {
  field(spec[nothing], float3, vRayOrigin);
  field(spec[nothing], float3, vRayDir);
  field(spec[nothing], float, fStartDist);
  field(spec[nothing], float, fLengthRemaining);
  field(spec[nothing], float, fRefractiveIndex);
  field(spec[nothing], int, iObjectId);
  field(spec[nothing], float, fDist);
  field(spec[nothing], float3, vColor);
  field(spec[nothing], float3, vAmount);
  field(spec[nothing], int, iChild0);
  field(spec[nothing], int, iChild1);
};
var(spec[static, nothing], const RayInfo, _664) = { 0.0F.xxx, 0.0F.xxx, 0.0F, -1.0F, 1.0F, -1, 0.0F, 0.0F.xxx, 1.0F.xxx, -1, -1 };
var(spec[nothing], Texture2D<:float4:>, bufferA_iChannel2)register(t0);
var(spec[nothing], SamplerState, _bufferA_iChannel2_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, bufferA_iChannel3)register(t0);
var(spec[nothing], SamplerState, _bufferA_iChannel3_sampler)register(s0);
var(spec[nothing], TextureCube<:float4:>, bufferA_iChannel1)register(t0);
var(spec[nothing], SamplerState, _bufferA_iChannel1_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel0)register(t0);
var(spec[nothing], SamplerState, _iChannel0_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel1)register(t0);
var(spec[nothing], SamplerState, _iChannel1_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel2)register(t0);
var(spec[nothing], SamplerState, _iChannel2_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, iChannel3)register(t0);
var(spec[nothing], SamplerState, _iChannel3_sampler)register(s0);
var(spec[nothing], Texture2D<:float4:>, bufferA_iChannel0)register(t0);
var(spec[nothing], SamplerState, _bufferA_iChannel0_sampler)register(s0);
var(spec[static, nothing], float4, outColor);
var(spec[static, nothing], float2, inCoord);
struct(SPIRV_Cross_Input) {
  field(spec[nothing], float2, inCoord)semantic(TEXCOORD2);
};
struct(SPIRV_Cross_Output) {
  field(spec[nothing], float4, outColor)semantic(SV_Target0);
};
var(spec[static, nothing], float3, g_vSunDir);
var(spec[static, nothing], float3, g_vSunColor);
var(spec[static, nothing], float3, g_vAmbientColor);
var(spec[static, nothing], float, fPlaneInFocus);
var(spec[static, nothing], float, fGolden);
var(spec[static, nothing], float3, iResolution);
var(spec[static, nothing], float, iTime);
var(spec[static, nothing], float4, iMouse);
var(spec[static, nothing], float, iTimeDelta);
var(spec[static, nothing], float, iFrameRate);
var(spec[static, nothing], int, iFrame);
var(spec[static, nothing], float, iChannelTime[4]);
var(spec[static, nothing], float3, iChannelResolution[4]);
var(spec[static, nothing], float4, iDate);
var(spec[static, nothing], float, iSampleRate);
func(spec[nothing], float2, Cam_GetViewCoordFromUV)params(var(spec[nothing], float2, vUV)) {
  var(spec[nothing], float2, vWindow) = (vUV * 2.0F) - 1.0F.xx;
  vWindow.x *= (iResolution.x / iResolution.y);
  return <- vWindow;
};

func(spec[nothing], float3x3, Cam_GetWorldToCameraRotMatrix)params(var(spec[nothing], CameraState, cameraState)) {
  var(spec[nothing], float3, vForward) = normalize(cameraState.vTarget - cameraState.vPos);
  var(spec[nothing], float3, vRight) = normalize(cross(float3(0.0F, 1.0F, 0.0F), vForward));
  var(spec[nothing], float3, vUp) = normalize(cross(vForward, vRight));
  return <- float3x3(float3(vRight), float3(vUp), float3(vForward));
};

func(spec[nothing], void, Cam_GetCameraRay)params(var(spec[nothing], float2, vUV), var(spec[nothing], CameraState, cam), var(spec[out, nothing], float3, vRayOrigin), var(spec[out, nothing], float3, vRayDir)) {
  var(spec[nothing], float2, vView) = Cam_GetViewCoordFromUV(vUV);
  vRayOrigin = cam.vPos;
  var(spec[nothing], float, fPerspDist) = 1.0F / tan(radians(cam.fFov));
  vRayDir = normalize(mul(float3(vView, fPerspDist), Cam_GetWorldToCameraRotMatrix(cam)));
};

func(spec[nothing], float, GetVignetting)params(var(spec[nothing], float2, vUV), var(spec[nothing], float, fScale), var(spec[nothing], float, fPower), var(spec[nothing], float, fStrength)) {
  var(spec[nothing], float2, vOffset) = ((vUV - 0.5F.xx) * 1.41421354F) * fScale;
  var(spec[nothing], float, fDist) = max(0.0F, 1.0F - length(vOffset));
  var(spec[nothing], float, fShade) = 1.0F - pow(fDist, fPower);
  fShade = 1.0F - (fShade * fStrength);
  return <- fShade;
};

func(spec[nothing], void, RayInfo_Clear)params(var(spec[nothing], int, i), var(spec[inout, nothing], ArrRayInfo, arrRayInfo)) {
  var(spec[nothing], RayInfo, rayInfo) = _664;
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
};

func(spec[nothing], void, RayStack_Reset)params(var(spec[inout, nothing], ArrRayInfo, rayStack)) {
  for ([var(spec[nothing], int, i) = 0], [i < 12], [i++]) {
    var(spec[nothing], int, param) = i;
    var(spec[nothing], ArrRayInfo, param_1) = rayStack;
    RayInfo_Clear(param, param_1);
    rayStack = param_1;
  };
};

func(spec[nothing], RayInfo, RayStack_Get)params(var(spec[nothing], int, i), var(spec[nothing], ArrRayInfo, rayStack)) {
  var(spec[nothing], RayInfo, rayInfo);
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
  return <- rayInfo;
};

func(spec[nothing], void, Scene_Union)params(var(spec[inout, nothing], SceneResult, a), var(spec[nothing], SceneResult, b)) {
  if (b.fDist < a.fDist) {
    a = b;
  };
};

func(spec[nothing], float, GetDistanceWine)params(var(spec[nothing], float3, vPos)) {
  var(spec[nothing], float3, vLocalPos) = vPos;
  vLocalPos.y -= 2.0F;
  var(spec[nothing], float2, vPos2) = float2(length(vLocalPos.xz), vLocalPos.y);
  var(spec[nothing], float2, vSphOrigin) = 0.0F.xx;
  var(spec[nothing], float2, vSphPos) = vPos2 - vSphOrigin;
  var(spec[nothing], float, fBowlDistance) = (length(vSphPos) - 0.600000024F) + 0.00999999977F;
  var(spec[nothing], float3, vWaterNormal) = float3(0.0F, 1.0F, 0.0F);
  vWaterNormal.x = sin(iTime * 5.0F) * 0.00999999977F;
  vWaterNormal.z = cos(iTime * 5.0F) * 0.00999999977F;
  vWaterNormal = normalize(vWaterNormal);
  var(spec[nothing], float, fWaterLevel) = dot(vLocalPos, vWaterNormal) - 0.100000001F;
  return <- max(fBowlDistance, fWaterLevel);
};

func(spec[nothing], float, GetDistanceBowl)params(var(spec[nothing], float3, vPos)) {
  var(spec[nothing], float2, vPos2) = float2(length(vPos.xz), vPos.y);
  var(spec[nothing], float2, vSphOrigin) = float2(0.0F, 0.730000019F);
  var(spec[nothing], float2, vSphPos) = vPos2 - vSphOrigin;
  var(spec[nothing], float2, vClosest) = vSphPos;
  if (vClosest.y > 0.100000001F) {
    vClosest.y = 0.100000001F;
  };
  if (vClosest.y < (-0.699999988F)) {
    vClosest.y = -0.699999988F;
  };
  var(spec[nothing], float, r) = sqrt(1.0F - (vClosest.y * vClosest.y));
  vClosest.x = r;
  var(spec[nothing], float, fBowlDistance) = distance(vClosest, vSphPos);
  vClosest = vSphPos;
  vClosest.y = -0.699999988F;
  r = sqrt(1.0F - (vClosest.y * vClosest.y));
  vClosest.x = min(vClosest.x, r);
  var(spec[nothing], float, fBaseDistance) = distance(vClosest, vSphPos);
  fBowlDistance = min(fBowlDistance, fBaseDistance);
  return <- fBowlDistance - 0.0299999993F;
};

func(spec[nothing], float, SmoothMin)params(var(spec[nothing], float, a), var(spec[nothing], float, b), var(spec[nothing], float, k)) {
  var(spec[nothing], float, h) = clamp(0.5F + ((0.5F * (b - a)) / k), 0.0F, 1.0F);
  return <- lerp(b, a, h) - ((k * h) * (1.0F - h));
};

func(spec[nothing], float, GetDistanceWineGlass)params(var(spec[nothing], float3, vPos)) {
  var(spec[nothing], float2, vPos2) = float2(length(vPos.xz), vPos.y);
  var(spec[nothing], float2, vSphOrigin) = float2(0.0F, 2.0F);
  var(spec[nothing], float2, vSphPos) = vPos2 - vSphOrigin;
  var(spec[nothing], float2, vClosest) = vSphPos;
  if (vClosest.y > 0.300000012F) {
    vClosest.y = 0.300000012F;
  };
  vClosest = normalize(vClosest) * 0.600000024F;
  var(spec[nothing], float, fBowlDistance) = distance(vClosest, vSphPos) - 0.0149999997F;
  var(spec[nothing], float2, vStemClosest) = vPos2;
  vStemClosest.x = 0.0F;
  vStemClosest.y = clamp(vStemClosest.y, 0.0F, 1.35000002F);
  var(spec[nothing], float, fStemRadius) = vStemClosest.y - 0.5F;
  fStemRadius = ((fStemRadius * fStemRadius) * 0.0199999996F) + 0.0299999993F;
  var(spec[nothing], float, fStemDistance) = distance(vPos2, vStemClosest) - fStemRadius;
  var(spec[nothing], float2, norm) = float2(0.371390671F, 0.928476691F);
  var(spec[nothing], float2, vBaseClosest) = vPos2;
  var(spec[nothing], float, fBaseDistance) = dot(vPos2 - float2(0.0F, 0.100000001F), norm) - 0.200000003F;
  fBaseDistance = max(fBaseDistance, vPos2.x - 0.5F);
  var(spec[nothing], float, param) = fBowlDistance;
  var(spec[nothing], float, param_1) = fStemDistance;
  var(spec[nothing], float, param_2) = 0.200000003F;
  var(spec[nothing], float, fDistance) = SmoothMin(param, param_1, param_2);
  var(spec[nothing], float, param_3) = fDistance;
  var(spec[nothing], float, param_4) = fBaseDistance;
  var(spec[nothing], float, param_5) = 0.200000003F;
  fDistance = SmoothMin(param_3, param_4, param_5);
  fDistance = max(fDistance, vSphPos.y - 0.5F);
  return <- fDistance;
};

func(spec[nothing], void, Scene_Trim)params(var(spec[inout, nothing], SceneResult, a), var(spec[nothing], SceneResult, b)) {
  if (a.fDist < (-b.fDist)) {
    a.fDist = -b.fDist;
  };
};

func(spec[nothing], SceneResult, Scene_GetDistance)params(var(spec[nothing], float3, vPos), var(spec[nothing], int, iInsideObject)) {
  var(spec[nothing], float3, vWineGlassPos) = float3(0.0F, 0.0F, -2.0F);
  var(spec[nothing], float3, vBowlPos) = float3(1.0F, 0.0F, 1.0F);
  var(spec[nothing], SceneResult, result);
  result.fDist = vPos.y;
  result.vUVW = vPos;
  result.iObjectId = 0;
  var(spec[nothing], float3, vSphere1Pos) = vBowlPos + float3(0.400000006F, 0.5F, 0.200000003F);
  var(spec[nothing], SceneResult, sphereResult1);
  sphereResult1.vUVW = vPos - vSphere1Pos;
  sphereResult1.fDist = min(result.fDist, length(vPos - vSphere1Pos) - 0.400000006F);
  sphereResult1.iObjectId = 4;
  var(spec[nothing], SceneResult, param) = result;
  Scene_Union(param, sphereResult1);
  result = param;
  var(spec[nothing], float3, vSphere2Pos) = float3(2.20000005F, 0.5F, -0.899999976F);
  var(spec[nothing], SceneResult, sphereResult2);
  sphereResult2.vUVW = (vPos - vSphere2Pos).zyx;
  sphereResult2.fDist = length(vPos - vSphere2Pos) - 0.5F;
  sphereResult2.iObjectId = 4;
  var(spec[nothing], SceneResult, param_1) = result;
  Scene_Union(param_1, sphereResult2);
  result = param_1;
  if (result.fDist > 10.0F) {
    result.iObjectId = -1;
  };
  var(spec[nothing], SceneResult, wineResult);
  wineResult.vUVW = vPos;
  wineResult.iObjectId = 2;
  var(spec[nothing], float3, param_2) = vPos - vWineGlassPos;
  wineResult.fDist = GetDistanceWine(param_2);
  var(spec[nothing], float, fRadius) = 1.0F;
  var(spec[nothing], float, fHeight) = 1.0F;
  var(spec[nothing], SceneResult, glassResult);
  glassResult.iObjectId = 1;
  glassResult.fDist = length(vPos - float3(-2.0F, fHeight, 1.0F)) - fRadius;
  var(spec[nothing], float3, param_3) = vPos - vBowlPos;
  glassResult.fDist = min(glassResult.fDist, GetDistanceBowl(param_3));
  glassResult.vUVW = vPos.xzy;
  var(spec[nothing], float3, param_4) = vPos - vWineGlassPos;
  glassResult.fDist = min(glassResult.fDist, GetDistanceWineGlass(param_4));
  var(spec[nothing], SceneResult, param_5) = wineResult;
  Scene_Trim(param_5, glassResult);
  wineResult = param_5;
  wineResult.fDist -= 9.99999974E-5F;
  if (iInsideObject == 1) {
    glassResult.fDist = -glassResult.fDist;
  };
  if (iInsideObject == 2) {
    wineResult.fDist = -wineResult.fDist;
  };
  var(spec[nothing], SceneResult, param_6) = result;
  Scene_Union(param_6, glassResult);
  result = param_6;
  var(spec[nothing], SceneResult, param_7) = result;
  Scene_Union(param_7, wineResult);
  result = param_7;
  return <- result;
};

func(spec[nothing], SceneResult, Scene_Trace)params(var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], float, minDist), var(spec[nothing], float, maxDist), var(spec[nothing], int, iInsideObject)) {
  var(spec[nothing], SceneResult, result);
  result.fDist = 0.0F;
  result.vUVW = 0.0F.xxx;
  result.iObjectId = -1;
  var(spec[nothing], float, t) = minDist;
  for ([var(spec[nothing], int, i) = 0], [i < 96], [i++]) {
    result = Scene_GetDistance(vRayOrigin + (vRayDir * t), iInsideObject);
    t += result.fDist;
    if (abs(result.fDist) < 0.00100000005F) {
      break;
    };
    var(spec[nothing], bool, _420) = iInsideObject == (-1);
    var(spec[nothing], bool, _427);
    if (_420) {
      _427 = abs(result.fDist) > 0.100000001F;
    } else {
      _427 = _420;
    };
    if (_427) {
      result.iObjectId = -1;
    };
    if (t > maxDist) {
      result.iObjectId = -1;
      t = maxDist;
      break;
    };
  };
  result.fDist = t;
  return <- result;
};

func(spec[nothing], float4, Env_GetSkyColor)params(var(spec[nothing], float3, vViewPos), var(spec[nothing], float3, vViewDir)) {
  var(spec[nothing], float4, vResult) = float4(0.0F, 0.0F, 1.0F, 1100.0F);
  var(spec[nothing], float3, vEnvMap) = bufferA_iChannel1.SampleLevel(_bufferA_iChannel1_sampler, vViewDir, 0.0F).xyz;
  vEnvMap *= vEnvMap;
  var(spec[nothing], float, kEnvmapExposure) = 0.999000012F;
  var(spec[nothing], float3, _1954) = -log2(1.0F.xxx - (vEnvMap * kEnvmapExposure));
  vResult.x = _1954.x;
  vResult.y = _1954.y;
  vResult.z = _1954.z;
  return <- vResult;
};

func(spec[nothing], float3, Scene_GetNormal)params(var(spec[nothing], float3, vPos), var(spec[nothing], int, iInsideObject)) {
  var(spec[nothing], float2, e) = float2(-1.0F, 1.0F);
  var(spec[nothing], float3, vNormal) = (((e.yxx * Scene_GetDistance(vPos + (e.yxx * 0.00100000005F), iInsideObject).fDist) + (e.xxy * Scene_GetDistance(vPos + (e.xxy * 0.00100000005F), iInsideObject).fDist)) + (e.xyx * Scene_GetDistance(vPos + (e.xyx * 0.00100000005F), iInsideObject).fDist)) + (e.yyy * Scene_GetDistance(vPos + (e.yyy * 0.00100000005F), iInsideObject).fDist);
  if (dot(vNormal, vNormal) < 9.99999974E-6F) {
    return <- float3(0.0F, 1.0F, 0.0F);
  };
  return <- normalize(vNormal);
};

func(spec[nothing], SurfaceInfo, Scene_GetSurfaceInfo)params(var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], SceneResult, traceResult), var(spec[nothing], int, iInsideObject)) {
  var(spec[nothing], SurfaceInfo, surfaceInfo);
  surfaceInfo.vPos = vRayOrigin + (vRayDir * traceResult.fDist);
  surfaceInfo.vNormal = Scene_GetNormal(surfaceInfo.vPos, iInsideObject);
  surfaceInfo.vBumpNormal = surfaceInfo.vNormal;
  surfaceInfo.vAlbedo = 1.0F.xxx;
  surfaceInfo.vR0 = 0.00999999977F.xxx;
  surfaceInfo.fSmoothness = 1.0F;
  surfaceInfo.vEmissive = 0.0F.xxx;
  surfaceInfo.fTransparency = 0.0F;
  surfaceInfo.fRefractiveIndex = 1.0F;
  if (traceResult.iObjectId == 0) {
    surfaceInfo.vR0 = 0.0199999996F.xxx;
    surfaceInfo.vAlbedo = bufferA_iChannel2.SampleLevel(_bufferA_iChannel2_sampler, traceResult.vUVW.xz * 0.5F, 0.0F).xyz;
    surfaceInfo.vAlbedo *= surfaceInfo.vAlbedo;
    surfaceInfo.fSmoothness = clamp(1.0F - ((surfaceInfo.vAlbedo.x * surfaceInfo.vAlbedo.x) * 2.0F), 0.0F, 1.0F);
    surfaceInfo.vAlbedo *= 0.25F;
    var(spec[nothing], float, fDist) = length(surfaceInfo.vPos.xz);
    var(spec[nothing], float, fCheckerAmount) = clamp((1.0F - (fDist * 0.100000001F)) + (surfaceInfo.vAlbedo.x * 0.5F), 0.0F, 1.0F);
    var(spec[nothing], float, fChecker) = step(frac((floor(traceResult.vUVW.x) + floor(traceResult.vUVW.z)) * 0.5F), 0.25F);
    var(spec[nothing], float3, vChecker);
    if (fChecker > 0.0F) {
      vChecker = 1.0F.xxx;
    } else {
      vChecker = 0.100000001F.xxx;
    };
    surfaceInfo.vAlbedo = lerp(surfaceInfo.vAlbedo, vChecker, fCheckerAmount.xxx);
    surfaceInfo.vR0 = lerp(surfaceInfo.vR0, 0.100000001F.xxx, fCheckerAmount.xxx);
    surfaceInfo.fSmoothness = lerp(surfaceInfo.fSmoothness, 1.0F, fCheckerAmount);
  };
  if (traceResult.iObjectId == 4) {
    var(spec[nothing], float, fStripe) = step(frac(dot(traceResult.vUVW * 5.0F, float3(1.0F, 0.200000003F, 0.400000006F))), 0.5F);
    if (fStripe > 0.0F) {
      surfaceInfo.vAlbedo = float3(0.100000001F, 0.0500000007F, 1.0F);
    } else {
      surfaceInfo.vAlbedo = float3(1.0F, 0.0500000007F, 0.100000001F);
    };
  };
  if (traceResult.iObjectId == 1) {
    surfaceInfo.vR0 = 0.0199999996F.xxx;
    var(spec[nothing], float3, vAlbedo) = bufferA_iChannel3.SampleLevel(_bufferA_iChannel3_sampler, traceResult.vUVW.xy * 2.0F, 0.0F).xyz;
    vAlbedo *= vAlbedo;
    vAlbedo *= float3(1.0F, 0.100000001F, 0.5F);
    surfaceInfo.vAlbedo = vAlbedo;
    surfaceInfo.fSmoothness = clamp(1.0F - (surfaceInfo.vAlbedo.x * 2.0F), 0.0F, 0.899999976F);
    surfaceInfo.fTransparency = clamp((surfaceInfo.vPos.y * 5.0F) + (surfaceInfo.vAlbedo.y * 3.0F), 0.0F, 1.0F);
    var(spec[nothing], bool, _1469) = surfaceInfo.vPos.x < 0.0F;
    var(spec[nothing], bool, _1476);
    if (!_1469) {
      _1476 = surfaceInfo.vPos.z < 0.0F;
    } else {
      _1476 = _1469;
    };
    if (_1476) {
      surfaceInfo.vAlbedo = 0.0F.xxx;
      surfaceInfo.fSmoothness = 0.899999976F;
      surfaceInfo.fTransparency = 1.0F - (vAlbedo.y * 0.200000003F);
    };
    surfaceInfo.fRefractiveIndex = 1.5F;
    var(spec[nothing], float, fLipStickDist) = length(surfaceInfo.vPos - float3(0.300000012F, 3.0999999F, -2.9000001F)) - 1.0F;
    if (fLipStickDist < 0.0F) {
      surfaceInfo.fTransparency = clamp((1.0F + (fLipStickDist * 2.0F)) - vAlbedo.x, 0.0F, 1.0F);
      surfaceInfo.vAlbedo = float3(0.5F, 0.0F, 0.0F) * (1.0F - surfaceInfo.fTransparency);
    };
  };
  if (traceResult.iObjectId == 2) {
    surfaceInfo.vR0 = 0.0199999996F.xxx;
    surfaceInfo.vAlbedo = 0.0F.xxx;
    surfaceInfo.fSmoothness = 0.899999976F;
    surfaceInfo.fTransparency = 1.0F;
    surfaceInfo.fRefractiveIndex = 1.29999995F;
  };
  if (traceResult.iObjectId == iInsideObject) {
    surfaceInfo.fRefractiveIndex = 1.0F;
  };
  return <- surfaceInfo;
};

func(spec[nothing], float, Scene_TraceShadow)params(var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], float, fMinDist), var(spec[nothing], float, fLightDist)) {
  var(spec[nothing], float, res) = 1.0F;
  var(spec[nothing], float, t) = fMinDist;
  for ([var(spec[nothing], int, i) = 0], [i < 16], [i++]) {
    var(spec[nothing], float, h) = Scene_GetDistance(vRayOrigin + (vRayDir * t), -1).fDist;
    res = min(res, (8.0F * h) / t);
    t += clamp(h, 0.0199999996F, 0.100000001F);
    if ((h < 9.99999974E-5F) || (t > fLightDist)) {
      break;
    };
  };
  return <- clamp(res, 0.0F, 1.0F);
};

func(spec[nothing], float, Light_GIV)params(var(spec[nothing], float, dotNV), var(spec[nothing], float, k)) {
  return <- 1.0F / (((dotNV + 9.99999974E-5F) * (1.0F - k)) + k);
};

func(spec[nothing], void, Light_Add)params(var(spec[inout, nothing], SurfaceLighting, lighting), var(spec[nothing], SurfaceInfo, surface), var(spec[nothing], float3, vViewDir), var(spec[nothing], float3, vLightDir), var(spec[nothing], float3, vLightColour)) {
  var(spec[nothing], float, fNDotL) = clamp(dot(vLightDir, surface.vBumpNormal), 0.0F, 1.0F);
  lighting.vDiffuse += (vLightColour * fNDotL);
  var(spec[nothing], float3, vH) = normalize((-vViewDir) + vLightDir);
  var(spec[nothing], float, fNdotV) = clamp(dot(-vViewDir, surface.vBumpNormal), 0.0F, 1.0F);
  var(spec[nothing], float, fNdotH) = clamp(dot(surface.vBumpNormal, vH), 0.0F, 1.0F);
  var(spec[nothing], float, alpha) = 1.0F - surface.fSmoothness;
  var(spec[nothing], float, alphaSqr) = alpha * alpha;
  var(spec[nothing], float, denom) = ((fNdotH * fNdotH) * (alphaSqr - 1.0F)) + 1.0F;
  var(spec[nothing], float, d) = alphaSqr / ((3.14159274F * denom) * denom);
  var(spec[nothing], float, k) = alpha / 2.0F;
  var(spec[nothing], float, param) = fNDotL;
  var(spec[nothing], float, param_1) = k;
  var(spec[nothing], float, param_2) = fNdotV;
  var(spec[nothing], float, param_3) = k;
  var(spec[nothing], float, vis) = Light_GIV(param, param_1) * Light_GIV(param_2, param_3);
  var(spec[nothing], float, fSpecularIntensity) = (d * vis) * fNDotL;
  lighting.vSpecular += (vLightColour * fSpecularIntensity);
};

func(spec[nothing], void, Light_AddDirectional)params(var(spec[inout, nothing], SurfaceLighting, lighting), var(spec[nothing], SurfaceInfo, surface), var(spec[nothing], float3, vViewDir), var(spec[nothing], float3, vLightDir), var(spec[nothing], float3, vLightColour)) {
  var(spec[nothing], float, fAttenuation) = 1.0F;
  var(spec[nothing], float, arg) = 0.100000001F;
  var(spec[nothing], float, arg_1) = 10.0F;
  var(spec[nothing], float, fShadowFactor) = Scene_TraceShadow(surface.vPos, vLightDir, arg, arg_1);
  var(spec[nothing], SurfaceLighting, param) = lighting;
  var(spec[nothing], SurfaceInfo, param_1) = surface;
  Light_Add(param, param_1, vViewDir, vLightDir, (vLightColour * fShadowFactor) * fAttenuation);
  lighting = param;
};

func(spec[nothing], float, Scene_GetAmbientOcclusion)params(var(spec[nothing], float3, vPos), var(spec[nothing], float3, vDir)) {
  var(spec[nothing], float, fOcclusion) = 0.0F;
  var(spec[nothing], float, fScale) = 1.0F;
  for ([var(spec[nothing], int, i) = 0], [i < 5], [i++]) {
    var(spec[nothing], float, fOffsetDist) = 0.00999999977F + ((1.0F * float(i)) / 4.0F);
    var(spec[nothing], float3, vAOPos) = (vDir * fOffsetDist) + vPos;
    var(spec[nothing], float, fDist) = Scene_GetDistance(vAOPos, -1).fDist;
    fOcclusion += ((fOffsetDist - fDist) * fScale);
    fScale *= 0.400000006F;
  };
  return <- clamp(1.0F - (2.0F * fOcclusion), 0.0F, 1.0F);
};

func(spec[nothing], SurfaceLighting, Scene_GetSurfaceLighting)params(var(spec[nothing], float3, vViewDir), var(spec[nothing], SurfaceInfo, surfaceInfo)) {
  var(spec[nothing], SurfaceLighting, surfaceLighting);
  surfaceLighting.vDiffuse = 0.0F.xxx;
  surfaceLighting.vSpecular = 0.0F.xxx;
  var(spec[nothing], SurfaceLighting, param) = surfaceLighting;
  var(spec[nothing], SurfaceInfo, param_1) = surfaceInfo;
  Light_AddDirectional(param, param_1, vViewDir, g_vSunDir, g_vSunColor);
  surfaceLighting = param;
  var(spec[nothing], float, fAO) = Scene_GetAmbientOcclusion(surfaceInfo.vPos, surfaceInfo.vNormal);
  surfaceLighting.vDiffuse += (g_vAmbientColor * (fAO * ((surfaceInfo.vBumpNormal.y * 0.5F) + 0.5F)));
  return <- surfaceLighting;
};

func(spec[nothing], float3, Light_GetFresnel)params(var(spec[nothing], float3, vView), var(spec[nothing], float3, vNormal), var(spec[nothing], float3, vR0), var(spec[nothing], float, fGloss)) {
  var(spec[nothing], float, NdotV) = max(0.0F, dot(vView, vNormal));
  return <- vR0 + (((1.0F.xxx - vR0) * pow(1.0F - NdotV, 5.0F)) * pow(fGloss, 20.0F));
};

func(spec[nothing], void, RayStack_Set)params(var(spec[nothing], int, i), var(spec[nothing], RayInfo, rayInfo), var(spec[inout, nothing], ArrRayInfo, rayStack)) {
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
};

func(spec[nothing], float3, Env_ApplyAtmosphere)params(var(spec[nothing], float3, vColor), var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], float, fDist), var(spec[nothing], int, iInsideObject)) {
  var(spec[nothing], float3, vResult) = vColor;
  if ((iInsideObject == 1) || (iInsideObject == 2)) {
    var(spec[nothing], float3, vExtCol) = 0.0F.xxx;
    if (iInsideObject == 2) {
      vExtCol = float3(0.0F, 0.5F, 0.990000009F);
    } else {
      if (vRayOrigin.z > 0.0F) {
        if (vRayOrigin.x < 0.0F) {
          vExtCol = float3(0.990000009F, 0.990000009F, 0.0F);
        } else {
          vExtCol = float3(0.0F, 0.800000011F, 0.200000003F);
          vExtCol *= 20.0F;
        };
      };
    };
    vResult *= exp((-vExtCol) * fDist);
  };
  return <- vResult;
};

func(spec[nothing], float3, FX_Apply)params(var(spec[nothing], float3, vColor), var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], float, fDist)) {
  return <- vColor;
};

func(spec[nothing], float4, Scene_GetColorAndDepth)params(var(spec[nothing], float3, vInRayOrigin), var(spec[nothing], float3, vInRayDir)) {
  var(spec[nothing], float3, vResultColor) = 0.0F.xxx;
  var(spec[nothing], int, ix) = 0;
  var(spec[nothing], int, stackCurrent) = 0;
  var(spec[nothing], int, stackEnd) = 1;
  var(spec[nothing], ArrRayInfo, rayStack);
  var(spec[nothing], ArrRayInfo, param) = rayStack;
  RayStack_Reset(param);
  rayStack = param;
  rayStack.vRayOrigin[0] = vInRayOrigin;
  rayStack.vRayDir[0] = vInRayDir;
  rayStack.fStartDist[0] = 0.0F;
  rayStack.fLengthRemaining[0] = 1000.0F;
  rayStack.fRefractiveIndex[0] = 1.0F;
  rayStack.vAmount[0] = 1.0F.xxx;
  rayStack.iChild0[0] = -1;
  rayStack.iChild1[0] = -1;
  var(spec[nothing], RayInfo, refractRayInfo);
  var(spec[nothing], RayInfo, reflectRayInfo);
  for ([var(spec[nothing], int, iPassIndex) = 0], [iPassIndex < 12], [iPassIndex++]) {
    if (ix >= 12) {
      break;
    };
    stackCurrent = clamp(ix, 0, 11);
    var(spec[nothing], int, param_1) = stackCurrent;
    var(spec[nothing], ArrRayInfo, param_2) = rayStack;
    var(spec[nothing], RayInfo, rayInfo) = RayStack_Get(param_1, param_2);
    if (rayInfo.fLengthRemaining <= 0.0F) {
      continue;
    };
    rayInfo.iChild0 = -1;
    rayInfo.iChild1 = -1;
    var(spec[nothing], float, param_3) = rayInfo.fStartDist;
    var(spec[nothing], float, param_4) = rayInfo.fLengthRemaining;
    var(spec[nothing], int, param_5) = rayInfo.iObjectId;
    var(spec[nothing], SceneResult, traceResult) = Scene_Trace(rayInfo.vRayOrigin, rayInfo.vRayDir, param_3, param_4, param_5);
    rayInfo.fDist = traceResult.fDist;
    rayInfo.vColor = 0.0F.xxx;
    var(spec[nothing], float3, vReflectance) = 1.0F.xxx;
    if (traceResult.iObjectId < 0) {
      rayInfo.vColor = Env_GetSkyColor(rayInfo.vRayOrigin, rayInfo.vRayDir).xyz;
    } else {
      var(spec[nothing], SceneResult, param_6) = traceResult;
      var(spec[nothing], int, param_7) = rayInfo.iObjectId;
      var(spec[nothing], SurfaceInfo, surfaceInfo) = Scene_GetSurfaceInfo(rayInfo.vRayOrigin, rayInfo.vRayDir, param_6, param_7);
      var(spec[nothing], SurfaceInfo, param_8) = surfaceInfo;
      var(spec[nothing], SurfaceLighting, surfaceLighting) = Scene_GetSurfaceLighting(rayInfo.vRayDir, param_8);
      var(spec[nothing], float, NdotV) = clamp(dot(surfaceInfo.vBumpNormal, -rayInfo.vRayDir), 0.0F, 1.0F);
      var(spec[nothing], float3, param_9) = -rayInfo.vRayDir;
      var(spec[nothing], float3, param_10) = surfaceInfo.vBumpNormal;
      var(spec[nothing], float3, param_11) = surfaceInfo.vR0;
      var(spec[nothing], float, param_12) = surfaceInfo.fSmoothness;
      vReflectance = Light_GetFresnel(param_9, param_10, param_11, param_12);
      rayInfo.vColor = ((surfaceInfo.vAlbedo * surfaceLighting.vDiffuse) + surfaceInfo.vEmissive) * (1.0F.xxx - vReflectance);
      var(spec[nothing], float3, vReflectAmount) = vReflectance;
      var(spec[nothing], float3, vTranmitAmount) = 1.0F.xxx - vReflectance;
      vTranmitAmount *= surfaceInfo.fTransparency;
      var(spec[nothing], bool, doReflection) = true;
      if (surfaceInfo.fTransparency > 0.0F) {
        var(spec[nothing], float3, vTestAmount) = vTranmitAmount * rayInfo.vAmount;
        if (((vTestAmount.x + vTestAmount.y) + vTestAmount.z) > 0.00999999977F) {
          refractRayInfo.vAmount = vTranmitAmount;
          refractRayInfo.vRayOrigin = surfaceInfo.vPos;
          refractRayInfo.iObjectId = traceResult.iObjectId;
          refractRayInfo.vRayDir = refract(rayInfo.vRayDir, surfaceInfo.vBumpNormal, rayInfo.fRefractiveIndex / surfaceInfo.fRefractiveIndex);
          if (traceResult.iObjectId == rayInfo.iObjectId) {
            refractRayInfo.iObjectId = -1;
          };
          if (length(refractRayInfo.vRayDir) > 0.0F) {
            refractRayInfo.vRayDir = normalize(refractRayInfo.vRayDir);
            refractRayInfo.fStartDist = abs(0.100000001F / dot(refractRayInfo.vRayDir, surfaceInfo.vNormal));
            refractRayInfo.fLengthRemaining = rayInfo.fLengthRemaining - traceResult.fDist;
            refractRayInfo.fDist = 1.0F - rayInfo.fDist;
            refractRayInfo.fRefractiveIndex = surfaceInfo.fRefractiveIndex;
            rayInfo.iChild1 = stackEnd;
            rayInfo.vColor *= (1.0F - surfaceInfo.fTransparency);
            refractRayInfo.vAmount *= surfaceInfo.fTransparency;
            var(spec[nothing], int, param_13) = stackEnd;
            var(spec[nothing], RayInfo, param_14) = refractRayInfo;
            var(spec[nothing], ArrRayInfo, param_15) = rayStack;
            RayStack_Set(param_13, param_14, param_15);
            rayStack = param_15;
            stackEnd++;
            stackEnd = clamp(stackEnd, 0, 11);
            doReflection = false;
          } else {
            vReflectAmount += vTranmitAmount;
          };
        };
      };
      if (doReflection) {
        var(spec[nothing], float3, vTestAmount_1) = vReflectAmount * rayInfo.vAmount;
        if (((vTestAmount_1.x + vTestAmount_1.y) + vTestAmount_1.z) > 0.00999999977F) {
          reflectRayInfo.vAmount = vReflectAmount;
          reflectRayInfo.vRayOrigin = surfaceInfo.vPos;
          reflectRayInfo.vRayDir = normalize(reflect(rayInfo.vRayDir, surfaceInfo.vBumpNormal));
          reflectRayInfo.iObjectId = rayInfo.iObjectId;
          reflectRayInfo.fStartDist = abs(0.00999999977F / dot(reflectRayInfo.vRayDir, surfaceInfo.vNormal));
          reflectRayInfo.fLengthRemaining = rayInfo.fLengthRemaining - traceResult.fDist;
          reflectRayInfo.fRefractiveIndex = rayInfo.fRefractiveIndex;
          rayInfo.iChild0 = stackEnd;
          var(spec[nothing], int, param_16) = stackEnd;
          var(spec[nothing], RayInfo, param_17) = reflectRayInfo;
          var(spec[nothing], ArrRayInfo, param_18) = rayStack;
          RayStack_Set(param_16, param_17, param_18);
          rayStack = param_18;
          stackEnd++;
          stackEnd = clamp(stackEnd, 0, 11);
        };
      };
      rayInfo.vColor += (surfaceLighting.vSpecular * vReflectance);
    };
    var(spec[nothing], int, param_19) = stackCurrent;
    var(spec[nothing], RayInfo, param_20) = rayInfo;
    var(spec[nothing], ArrRayInfo, param_21) = rayStack;
    RayStack_Set(param_19, param_20, param_21);
    rayStack = param_21;
    ix++;
  };
  for ([var(spec[nothing], int, iStackPos) = 11], [iStackPos >= 0], [iStackPos--]) {
    var(spec[nothing], int, param_22) = iStackPos;
    var(spec[nothing], ArrRayInfo, param_23) = rayStack;
    var(spec[nothing], RayInfo, rayInfo_1) = RayStack_Get(param_22, param_23);
    if (rayInfo_1.fLengthRemaining <= 0.0F) {
      continue;
    };
    if (rayInfo_1.iChild0 >= 0) {
      var(spec[nothing], int, param_24) = rayInfo_1.iChild0;
      var(spec[nothing], ArrRayInfo, param_25) = rayStack;
      var(spec[nothing], RayInfo, childRayInfo) = RayStack_Get(param_24, param_25);
      if (childRayInfo.fDist > 0.0F) {
        rayInfo_1.vColor += (childRayInfo.vAmount * childRayInfo.vColor);
      };
    };
    if (rayInfo_1.iChild1 >= 0) {
      var(spec[nothing], int, param_26) = rayInfo_1.iChild1;
      var(spec[nothing], ArrRayInfo, param_27) = rayStack;
      var(spec[nothing], RayInfo, childRayInfo_1) = RayStack_Get(param_26, param_27);
      if (childRayInfo_1.fDist > 0.0F) {
        rayInfo_1.vColor += (childRayInfo_1.vAmount * childRayInfo_1.vColor);
      };
    };
    rayInfo_1.vColor = Env_ApplyAtmosphere(rayInfo_1.vColor, rayInfo_1.vRayOrigin, rayInfo_1.vRayDir, rayInfo_1.fDist, rayInfo_1.iObjectId);
    var(spec[nothing], float3, param_28) = rayInfo_1.vColor;
    rayInfo_1.vColor = FX_Apply(param_28, rayInfo_1.vRayOrigin, rayInfo_1.vRayDir, rayInfo_1.fDist);
    var(spec[nothing], int, param_29) = iStackPos;
    var(spec[nothing], RayInfo, param_30) = rayInfo_1;
    var(spec[nothing], ArrRayInfo, param_31) = rayStack;
    RayStack_Set(param_29, param_30, param_31);
    rayStack = param_31;
  };
  var(spec[nothing], SceneResult, firstTraceResult);
  if (firstTraceResult.iObjectId >= 10) {
    firstTraceResult.fDist = -firstTraceResult.fDist;
  };
  return <- float4(rayStack.vColor[0], rayStack.fDist[0]);
};

func(spec[nothing], float, GetCoC)params(var(spec[nothing], float, fDistance), var(spec[nothing], float, fPlaneInFocus_1)) {
  var(spec[nothing], float, fAperture) = 0.0500000007F;
  var(spec[nothing], float, fFocalLength) = 0.800000011F;
  return <- abs((fAperture * (fFocalLength * (fDistance - fPlaneInFocus_1))) / (fDistance * (fPlaneInFocus_1 - fFocalLength)));
};

func(spec[nothing], float4, MainCommon)params(var(spec[nothing], float3, vRayOrigin), var(spec[nothing], float3, vRayDir), var(spec[nothing], float, fShade)) {
  var(spec[nothing], float4, vColorLinAmdDepth) = Scene_GetColorAndDepth(vRayOrigin, vRayDir);
  var(spec[nothing], float4, _2024) = vColorLinAmdDepth;
  var(spec[nothing], float3, _2026) = max(_2024.xyz, 0.0F.xxx);
  vColorLinAmdDepth.x = _2026.x;
  vColorLinAmdDepth.y = _2026.y;
  vColorLinAmdDepth.z = _2026.z;
  var(spec[nothing], float4, vFragColor) = vColorLinAmdDepth;
  var(spec[nothing], float4, _2036) = vFragColor;
  var(spec[nothing], float3, _2038) = _2036.xyz * fShade;
  vFragColor.x = _2038.x;
  vFragColor.y = _2038.y;
  vFragColor.z = _2038.z;
  var(spec[nothing], float, param) = vColorLinAmdDepth.w;
  var(spec[nothing], float, param_1) = fPlaneInFocus;
  vFragColor.w = GetCoC(param, param_1);
  return <- vFragColor;
};

func(spec[nothing], void, fillBufferA)params(var(spec[out, nothing], float4, vFragColor), var(spec[nothing], float2, vFragCoord)) {
  var(spec[nothing], float2, vUV) = vFragCoord / iResolution.xy;
  var(spec[nothing], float, fAngle) = (iMouse.x / iResolution.x) * 6.28318548F;
  var(spec[nothing], float, fElevation) = (iMouse.y / iResolution.y) * 1.57079637F;
  if (iMouse.x <= 0.0F) {
    fAngle = -2.29999995F;
    fElevation = 0.5F;
  };
  var(spec[nothing], float, fDist) = 6.0F;
  var(spec[nothing], CameraState, cam);
  cam.vPos = float3((sin(fAngle) * fDist) * cos(fElevation), sin(fElevation) * fDist, (cos(fAngle) * fDist) * cos(fElevation));
  cam.vTarget = float3(0.0F, 0.5F, 0.0F);
  cam.fFov = 20.0F;
  var(spec[nothing], float3, param);
  var(spec[nothing], float3, param_1);
  Cam_GetCameraRay(vUV, cam, param, param_1);
  var(spec[nothing], float3, vRayOrigin) = param;
  var(spec[nothing], float3, vRayDir) = param_1;
  var(spec[nothing], float, param_2) = 0.699999988F;
  var(spec[nothing], float, param_3) = 2.0F;
  var(spec[nothing], float, param_4) = 1.0F;
  var(spec[nothing], float, fShade) = GetVignetting(vUV, param_2, param_3, param_4);
  var(spec[nothing], float3, param_5) = vRayOrigin;
  var(spec[nothing], float3, param_6) = vRayDir;
  var(spec[nothing], float, param_7) = fShade;
  vFragColor = MainCommon(param_5, param_6, param_7);
};

func(spec[nothing], float3, ColorGrade)params(var(spec[inout, nothing], float3, vColor)) {
  var(spec[nothing], float3, vHue) = float3(1.0F, 0.699999988F, 0.200000003F);
  var(spec[nothing], float3, vGamma) = 1.0F.xxx + (vHue * 0.600000024F);
  var(spec[nothing], float3, vGain) = 0.899999976F.xxx + ((vHue * vHue) * 8.0F);
  vColor *= 2.0F;
  var(spec[nothing], float, fMaxLum) = 100.0F;
  vColor /= fMaxLum.xxx;
  vColor = pow(vColor, vGamma);
  vColor *= vGain;
  vColor *= fMaxLum;
  return <- vColor;
};

func(spec[nothing], float3, Tonemap)params(var(spec[nothing], float3, x)) {
  var(spec[nothing], float, a) = 0.00999999977F;
  var(spec[nothing], float, b) = 0.131999999F;
  var(spec[nothing], float, c) = 0.00999999977F;
  var(spec[nothing], float, d) = 0.163000003F;
  var(spec[nothing], float, e) = 0.101000004F;
  return <- (x * ((x * a) + b.xxx)) / ((x * ((x * c) + d.xxx)) + e.xxx);
};

func(spec[nothing], void, mainImage)params(var(spec[inout, nothing], float4, fragColor), var(spec[nothing], float2, fragCoord)) {
  var(spec[nothing], float2, vUV) = fragCoord / iResolution.xy;
  var(spec[nothing], float4, vSample) = iChannel0.SampleLevel(_iChannel0_sampler, vUV, 0.0F);
  var(spec[nothing], float, fCoC) = vSample.w;
  var(spec[nothing], float3, vResult) = vSample.xyz;
  var(spec[nothing], float, fTot) = 0.0F;
  var(spec[nothing], float2, vangle) = float2(0.0F, fCoC);
  if (abs(fCoC) > 0.0F) {
    vResult *= fCoC;
    fTot += fCoC;
    var(spec[nothing], float, fBlurTaps) = 32.0F;
    for ([var(spec[nothing], int, i) = 1], [i < 32], [i++]) {
      var(spec[nothing], float, t) = float(i) / fBlurTaps;
      var(spec[nothing], float, fTheta) = (t * fBlurTaps) * fGolden;
      var(spec[nothing], float, fRadius) = (fCoC * sqrt(t * fBlurTaps)) / sqrt(fBlurTaps);
      var(spec[nothing], float2, vTapUV) = vUV + (float2(sin(fTheta), cos(fTheta)) * fRadius);
      var(spec[nothing], float4, vTapSample) = iChannel0.SampleLevel(_iChannel0_sampler, vTapUV, 0.0F);
      var(spec[nothing], float, fCoC2) = vTapSample.w;
      var(spec[nothing], float, fWeight) = max(0.00100000005F, fCoC2);
      vResult += (vTapSample.xyz * fWeight);
      fTot += fWeight;
    };
    vResult /= fTot.xxx;
  };
  fragColor = float4(vResult, 1.0F);
  var(spec[nothing], float, fExposure) = 3.0F;
  var(spec[nothing], float4, _2327) = fragColor;
  var(spec[nothing], float3, _2330) = _2327.xyz * fExposure;
  fragColor.x = _2330.x;
  fragColor.y = _2330.y;
  fragColor.z = _2330.z;
  var(spec[nothing], float3, param) = fragColor.xyz;
  var(spec[nothing], float3, _2340) = ColorGrade(param);
  fragColor.x = _2340.x;
  fragColor.y = _2340.y;
  fragColor.z = _2340.z;
  var(spec[nothing], float3, param_1) = fragColor.xyz;
  var(spec[nothing], float3, _2350) = Tonemap(param_1);
  fragColor.x = _2350.x;
  fragColor.y = _2350.y;
  fragColor.z = _2350.z;
};

func(spec[nothing], void, frag_main)params() {
  g_vSunDir = float3(0.842151939F, 0.336860776F, 0.42107597F);
  g_vSunColor = float3(5.0F, 3.5F, 2.5F);
  g_vAmbientColor = float3(0.800000011F, 0.200000003F, 0.100000001F);
  fPlaneInFocus = 5.0F;
  fGolden = 2.39996266F;
  var(spec[nothing], float2, param_1) = inCoord;
  var(spec[nothing], float4, param);
  fillBufferA(param, param_1);
  outColor = param;
  var(spec[nothing], float2, param_3) = inCoord;
  var(spec[nothing], float4, param_2);
  mainImage(param_2, param_3);
  outColor = param_2;
};

func(spec[nothing], SPIRV_Cross_Output, main)params(var(spec[nothing], SPIRV_Cross_Input, stage_input)) {
  inCoord = stage_input.inCoord;
  frag_main();
  var(spec[nothing], SPIRV_Cross_Output, stage_output);
  stage_output.outColor = outColor;
  return <- stage_output;
};



