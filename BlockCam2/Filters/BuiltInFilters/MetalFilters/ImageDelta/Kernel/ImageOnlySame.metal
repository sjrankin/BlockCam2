//
//  ImageOnlySame.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void ImageOnlySame(texture2d<float, access::read> Image1 [[texture(0)]],
                           texture2d<float, access::read> Image2 [[texture(1)]],
                           texture2d<float, access::write> OutTexture [[texture(2)]],
                           device float *ToCPU [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float4 Color1 = Image1.read(gid);
    float4 Color2 = Image2.read(gid);
    if (Color1.a == Color2.a && Color1.g == Color2.g && Color1.b == Color2.b)
        {
        OutTexture.write(Color1, gid);
        }
    OutTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
}
