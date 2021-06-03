//
//  Arithmetic_Add.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void Arithmetic_Add(texture2d<float, access::read> SourceImage [[texture(0)]],
                           texture2d<float, access::read_write> Storage [[texture(1)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float4 Target = Storage.read(gid);
    float r = Target.r + Source.r;
    float g = Target.g + Source.g;
    float b = Target.b + Source.b;
    Storage.write(float4(r, g, b, 1.0), gid);
}
