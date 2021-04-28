//
//  ConditionalTransparency.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

#include <metal_stdlib>
using namespace metal;

struct TransparencyParameters
{
    float BrightnessThreshold;
    bool InvertThreshold;
};

kernel void ConditionalTransparency(texture2d<float, access::read> InTexture [[texture(0)]],
                                    texture2d<float, access::write> OutTexture [[texture(1)]],
                                    constant TransparencyParameters &Parameters [[buffer(0)]],
                                    device float *ToCPU [[buffer(1)]],
                                    uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = InTexture.read(gid);
    
    float PixelLuminance = (InColor.r * 0.2126) + (InColor.g * 0.7152) + (InColor.b * 0.0722);
    if (Parameters.InvertThreshold)
        {
        if (PixelLuminance >= Parameters.BrightnessThreshold)
            {
            OutTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
            return;
            }
        }
    else
        {
        if (PixelLuminance <= Parameters.BrightnessThreshold)
            {
            OutTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
            return;
            }
        }
    OutTexture.write(InColor, gid);
}
