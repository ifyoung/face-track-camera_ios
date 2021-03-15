#include <metal_stdlib>
using namespace metal;

//typedef struct {
//    float2 center;
//} StretchDistortionUniform;

//fragment half4 stretchDistortionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
//                                 texture2d<half> inputTexture [[texture(0)]],
//                                 constant StretchDistortionUniform& uniform [[buffer(1)]])

kernel void stretchKernel(texture2d<half, access::write> outputTexture [[texture(0)]],
                                    texture2d<half, access::sample> inputTexture [[texture(1)]],
                                    constant float2 *centerPointer [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]])

{
    if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
    constexpr sampler quadSampler;
    //    float2 normCoord = 2.0 * fragmentInput.textureCoordinate - 1.0;
    //    float2 normCenter = 2.0 * uniform.center - 1.0;
    
    const float2 center = float2(*centerPointer);
    
    
    const float2 textureCoordinate = float2(float(gid.x) / outputTexture.get_width(), float(gid.y) / outputTexture.get_height());
    
    float2 normCoord = 2.0 * textureCoordinate - 1.0;
    float2 normCenter = 2.0 * center - 1.0;
    
    normCoord -= normCenter;
    float2 s = sign(normCoord);
    normCoord = abs(normCoord);
    normCoord = 0.5 * normCoord + 0.5 * smoothstep(0.25, 0.5, normCoord) * normCoord;
    normCoord = s * normCoord;
    
    normCoord += normCenter;
    
    float2 textureCoordinateToUse = normCoord / 2.0 + 0.5;
    const half4 outColor = inputTexture.sample(quadSampler, textureCoordinateToUse );
    outputTexture.write(outColor, gid);
}
