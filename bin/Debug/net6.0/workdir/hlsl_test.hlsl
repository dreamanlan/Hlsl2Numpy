#pragma kernel VolumeFogStore
#define GROUP_SIZE_1D 8

int _CurFrameNo;
float2 _FogTexSize;
float3 _WorldSpaceCameraPos;
float4x4 _LAST_UNITY_MATRIX_VP;
float4x4 _UNITY_MATRIX_I_VP;
float _UNITY_NEAR_CLIP_VALUE;

Texture2D _CameraDepthTexture;
SamplerState sampler_CameraDepthTexture;

static const float3x3 k_identity3x3 = {1, 0, 0,
                                       0, 1, 0,
                                       0, 0, 1};

static const float4x4 k_identity4x4 = {1, 0, 0, 0,
                                       0, 1, 0, 0,
                                       0, 0, 1, 0,
                                       0, 0, 0, 1};

float4 ComputeClipSpacePosition(float2 positionNDC, float deviceDepth)
{
    float4 positionCS = float4(positionNDC * 2.0 - 1.0, deviceDepth, 1.0);

#if UNITY_UV_STARTS_AT_TOP
    // Our world space, view space, screen space and NDC space are Y-up.
    // Our clip space is flipped upside-down due to poor legacy Unity design.
    // The flip is baked into the projection matrix, so we only have to flip
    // manually when going from CS to NDC and back.
    positionCS.y = -positionCS.y;
#endif

    return positionCS;
}

// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float4 ComputeClipSpacePosition(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    return mul(clipSpaceTransform, float4(position, 1.0));
}

// The returned Z value is the depth buffer value (and NOT linear view space Z value).
// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float3 ComputeNormalizedDeviceCoordinatesWithZ(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    float4 positionCS = ComputeClipSpacePosition(position, clipSpaceTransform);

#if UNITY_UV_STARTS_AT_TOP
    // Our world space, view space, screen space and NDC space are Y-up.
    // Our clip space is flipped upside-down due to poor legacy Unity design.
    // The flip is baked into the projection matrix, so we only have to flip
    // manually when going from CS to NDC and back.
    positionCS.y = -positionCS.y;
#endif

    positionCS *= rcp(positionCS.w);
    positionCS.xy = positionCS.xy * 0.5 + 0.5;

    return positionCS.xyz;
}

// Use case examples:
// (position = positionCS) => (clipSpaceTransform = use default)
// (position = positionVS) => (clipSpaceTransform = UNITY_MATRIX_P)
// (position = positionWS) => (clipSpaceTransform = UNITY_MATRIX_VP)
float2 ComputeNormalizedDeviceCoordinates(float3 position, float4x4 clipSpaceTransform = k_identity4x4)
{
    return ComputeNormalizedDeviceCoordinatesWithZ(position, clipSpaceTransform).xy;
}

float3 ComputeViewSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invProjMatrix)
{
    float4 positionCS = ComputeClipSpacePosition(positionNDC, deviceDepth);
    float4 positionVS = mul(invProjMatrix, positionCS);
    // The view space uses a right-handed coordinate system.
    positionVS.z = -positionVS.z;
    return positionVS.xyz / positionVS.w;
}

float3 ComputeWorldSpacePosition(float2 positionNDC, float deviceDepth, float4x4 invViewProjMatrix)
{
    float4 positionCS  = ComputeClipSpacePosition(positionNDC, deviceDepth);
    float4 hpositionWS = mul(invViewProjMatrix, positionCS);
    return hpositionWS.xyz / hpositionWS.w;
}

float3 ComputeWorldSpacePosition(float4 positionCS, float4x4 invViewProjMatrix)
{
    float4 hpositionWS = mul(invViewProjMatrix, positionCS);
    return hpositionWS.xyz / hpositionWS.w;
}

[numthreads(GROUP_SIZE_1D, GROUP_SIZE_1D, 1)]
void main(uint2 dispatchThreadId : SV_DispatchThreadID,
                        uint2 groupId          : SV_GroupID,
                        uint2 groupThreadId    : SV_GroupThreadID)
{
    uint2 groupOffset = groupId * GROUP_SIZE_1D;
    uint2 coord  = groupOffset + groupThreadId;

    float2 uv = float2(coord.x / _FogTexSize.x, coord.y / _FogTexSize.y);
#if UNITY_REVERSED_Z
    float depth = _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, uv, 0).r;
#else
    // Adjust z to match NDC for OpenGL
    float depth = lerp(_UNITY_NEAR_CLIP_VALUE, 1, _CameraDepthTexture.SampleLevel(sampler_CameraDepthTexture, uv, 0).r);
#endif

    float2 geoUV = uv;
    geoUV.y = 1 - geoUV.y;

    float3 ro = _WorldSpaceCameraPos;
    float3 wpos = ComputeWorldSpacePosition(geoUV, depth, _UNITY_MATRIX_I_VP);
    float3 rd = wpos - _WorldSpaceCameraPos;
    float rz = length(rd);
    rd = normalize(rd);

    float4 vpos = mul(_LAST_UNITY_MATRIX_VP, float4(wpos, 1.0));
    float2 lastUV = vpos.xy / vpos.w / 2.0 + float2(0.5, 0.5);
    uint2 lastCoord = uint2(lastUV.x * _FogTexSize.x, lastUV.y * _FogTexSize.y);

    int ct = 0;
    [unroll(8)]
    while(ct < 256){
        float3 pt = ro + rd * d;
        wpos += pt;
        ++ct;
    }
}