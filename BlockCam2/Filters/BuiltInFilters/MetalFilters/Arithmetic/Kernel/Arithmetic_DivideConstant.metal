//
//  Arithmetic_DivideConstant.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/3/21.
//

#include <metal_stdlib>
using namespace metal;

struct DivideParameters
{
    bool NormalClamp;
    float r;
    float g;
    float b;
    float a;
    bool UseR;
    bool UseG;
    bool UseB;
    bool UseA;
};

kernel void Arithmetic_DivideRGB(texture2d<float, access::read> SourceImage [[texture(0)]],
                                 texture2d<float, access::write> Target [[texture(1)]],
                                 constant DivideParameters &Parameters [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float r = Source.r / Parameters.r;
    float g = Source.g / Parameters.g;
    float b = Source.b / Parameters.b;
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
        if (b > 1.0)
            {
            b = 1.0;
            }
        }
    Target.write(float4(r, g, b, 1.0), gid);
}

kernel void Arithmetic_DivideRG(texture2d<float, access::read> SourceImage [[texture(0)]],
                                texture2d<float, access::write> Target [[texture(1)]],
                                constant DivideParameters &Parameters [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float r = Source.r / Parameters.r;
    float g = Source.g / Parameters.g;
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
        }
    Target.write(float4(r, g, Source.b, 1.0), gid);
}

kernel void Arithmetic_DivideRB(texture2d<float, access::read> SourceImage [[texture(0)]],
                                texture2d<float, access::write> Target [[texture(1)]],
                                constant DivideParameters &Parameters [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float r = Source.r / Parameters.r;
    float b = Source.b / Parameters.b;
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
        if (b < 0.0)
            {
            b = 0.0;
            }
        if (b > 1.0)
            {
            b = 1.0;
            }
        }
    Target.write(float4(r, Source.g, b, 1.0), gid);
}

kernel void Arithmetic_DivideGB(texture2d<float, access::read> SourceImage [[texture(0)]],
                                texture2d<float, access::write> Target [[texture(1)]],
                                constant DivideParameters &Parameters [[buffer(0)]],
                                uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float g = Source.g / Parameters.g;
    float b = Source.b / Parameters.b;
    if (Parameters.NormalClamp)
        {
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
        if (b > 1.0)
            {
            b = 1.0;
            }
        }
    Target.write(float4(Source.r, g, b, 1.0), gid);
}

kernel void Arithmetic_DivideR(texture2d<float, access::read> SourceImage [[texture(0)]],
                                 texture2d<float, access::write> Target [[texture(1)]],
                                 constant DivideParameters &Parameters [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float r = Source.r / Parameters.r;
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
        }
    Target.write(float4(r, Source.g, Source.b, 1.0), gid);
}

kernel void Arithmetic_DivideG(texture2d<float, access::read> SourceImage [[texture(0)]],
                                 texture2d<float, access::write> Target [[texture(1)]],
                                 constant DivideParameters &Parameters [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float g = Source.g / Parameters.g;
    if (Parameters.NormalClamp)
        {
        if (g < 0.0)
            {
            g = 0.0;
            }
        if (g > 1.0)
            {
            g = 1.0;
            }
        }
    Target.write(float4(Source.r, g, Source.b, 1.0), gid);
}

kernel void Arithmetic_DivideB(texture2d<float, access::read> SourceImage [[texture(0)]],
                                 texture2d<float, access::write> Target [[texture(1)]],
                                 constant DivideParameters &Parameters [[buffer(0)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float4 Source = SourceImage.read(gid);
    float b = Source.b / Parameters.b;
    if (Parameters.NormalClamp)
        {
        if (b < 0.0)
            {
            b = 0.0;
            }
        if (b > 1.0)
            {
            b = 1.0;
            }
        }
    Target.write(float4(Source.r, Source.g, b, 1.0), gid);
}
