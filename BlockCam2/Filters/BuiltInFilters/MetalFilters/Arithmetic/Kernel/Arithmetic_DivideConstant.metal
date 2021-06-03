//
//  Arithmetic_DivideConstant.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

#include <metal_stdlib>
using namespace metal;

struct Divide_Parameters
{
    float Count;
};

kernel void Arithmetic_Divide(texture2d<float, access::read> Storage [[texture(0)]],
                           texture2d<float, access::write> Result [[texture(1)]],
                           constant Divide_Parameters &Parameters [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float4 Sum = Storage.read(gid);
    float r = Sum.r / Parameters.Count;
    float g = Sum.g / Parameters.Count;
    float b = Sum.b / Parameters.Count;
    Result.write(float4(r, g, b, 1.0), gid);
}
