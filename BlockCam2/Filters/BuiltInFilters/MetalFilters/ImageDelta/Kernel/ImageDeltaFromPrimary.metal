//
//  ImageDeltaFromPrimary.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

#include <metal_stdlib>
using namespace metal;

struct DeltaParameters
{
    float4 BackgroundColor;
    int Operation;
    float Threshold;
    bool UseEffectiveColor;
    float4 EffectiveColor;
};

/// Returns the primary (`Image1`) pixel unless it is different from the secondary (`Image2`) pixel in which
/// case if `UseEffectiveColor` is true, the `EffectiveColor` is returned, otherwise transparent black is
/// returned.
kernel void ImageDeltaFromPrimary(texture2d<float, access::read> Image1 [[texture(0)]],
                                  texture2d<float, access::read> Image2 [[texture(1)]],
                                  texture2d<float, access::write> OutTexture [[texture(2)]],
                                  constant DeltaParameters &Parameters [[buffer(0)]],
                                  uint2 gid [[thread_position_in_grid]])
{
    float4 Color1 = Image1.read(gid);
    float4 Color2 = Image2.read(gid);
    if (Color1.r != Color2.r || Color1.g != Color2.g || Color1.b != Color2.b)
        {
        if (Parameters.UseEffectiveColor)
            {
            OutTexture.write(Parameters.EffectiveColor, gid);
            }
        else
            {
            OutTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
            }
        return;
        }
    OutTexture.write(Color1, gid);
}

