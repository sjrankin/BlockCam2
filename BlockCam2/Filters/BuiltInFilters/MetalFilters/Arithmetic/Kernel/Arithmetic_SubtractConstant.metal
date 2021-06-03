//
//  Arithmetic_SubtractConstant.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

#include <metal_stdlib>
using namespace metal;

struct AddConstant
{
    float r;
    float g;
    float b;
    bool NormalClamp;
};

kernel void Arithmetic_SubtractConstant(texture2d<float, access::read> SourceImage [[texture(0)]],
                                   texture2d<float, access::read_write> Storage [[texture(1)]],
                                   constant AddConstant &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float r = Source.r - Parameters.r;
    float g = Source.g - Parameters.g;
    float b = Source.b - Parameters.b;
    if (Parameters.NormalClamp)
        {
        if (r < 0.0)
            {
            r = 0.0;
            }
        if (r > 1.0)
            {
            r = 1.0;
            }
        if (g < 0.0)
            {
            g = 0.0;
            }
        if (g > 1.0)
            {
            g = 1.0;
            }
        if (b < 0.0)
            {
            b = 0.0;
            }
        if (g > 1.0)
            {
            b = 1.0;
            }
        }
    Storage.write(float4(r, g, b, 1.0), gid);
}
