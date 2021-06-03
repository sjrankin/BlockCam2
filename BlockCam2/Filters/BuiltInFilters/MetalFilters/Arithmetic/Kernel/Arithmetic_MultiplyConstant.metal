//
//  Arithmetic_MultiplyConstant.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

#include <metal_stdlib>
using namespace metal;

struct Multiply_Parameters
{
    float Value;
};

kernel void Arithmetic_Multiply(texture2d<float, access::read> Storage [[texture(0)]],
                              texture2d<float, access::write> Result [[texture(1)]],
                              constant Multiply_Parameters &Parameters [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float4 Sum = Storage.read(gid);
    float r = Sum.r * Parameters.Value;
    float g = Sum.g * Parameters.Value;
    float b = Sum.b * Parameters.Value;
    Result.write(float4(r, g, b, 1.0), gid);
}
