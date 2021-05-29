//
//  MultiFrameCombiner.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

#include <metal_stdlib>
using namespace metal;

struct MultiFrameParameters
{
    bool InvertComparison;
    uint Comparison;
};

kernel void MultiFrameCombiner2Bright(texture2d<float, access::read> Texture0 [[texture(0)]],
                                      texture2d<float, access::read> Texture1 [[texture(1)]],
                                      texture2d<float, access::write> OutTexture [[texture(2)]],
                                      constant MultiFrameParameters &Parameters [[buffer(0)]],
                                      uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    float Bright0 = max(Color0.r, max(Color0.g, Color0.b));
    float Bright1 = max(Color1.r, max(Color1.g, Color1.b));
    
    if (Bright0 > Bright1)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Red(texture2d<float, access::read> Texture0 [[texture(0)]],
                                   texture2d<float, access::read> Texture1 [[texture(1)]],
                                   texture2d<float, access::write> OutTexture [[texture(2)]],
                                   constant MultiFrameParameters &Parameters [[buffer(0)]],
                                   uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    if (Color0.r > Color1.r)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Green(texture2d<float, access::read> Texture0 [[texture(0)]],
                                     texture2d<float, access::read> Texture1 [[texture(1)]],
                                     texture2d<float, access::write> OutTexture [[texture(2)]],
                                     constant MultiFrameParameters &Parameters [[buffer(0)]],
                                     uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    if (Color0.g > Color1.g)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Blue(texture2d<float, access::read> Texture0 [[texture(0)]],
                                    texture2d<float, access::read> Texture1 [[texture(1)]],
                                    texture2d<float, access::write> OutTexture [[texture(2)]],
                                    constant MultiFrameParameters &Parameters [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    if (Color0.b > Color1.b)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Cyan(texture2d<float, access::read> Texture0 [[texture(0)]],
                                    texture2d<float, access::read> Texture1 [[texture(1)]],
                                    texture2d<float, access::write> OutTexture [[texture(2)]],
                                    constant MultiFrameParameters &Parameters [[buffer(0)]],
                                    uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    float Cyan0 = (Color0.g + Color0.b) / 2.0;
    float Cyan1 = (Color1.g + Color1.b) / 2.0;
    
    if (Cyan0 > Cyan1)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Magenta(texture2d<float, access::read> Texture0 [[texture(0)]],
                                       texture2d<float, access::read> Texture1 [[texture(1)]],
                                       texture2d<float, access::write> OutTexture [[texture(2)]],
                                       constant MultiFrameParameters &Parameters [[buffer(0)]],
                                       uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    float Magenta0 = (Color0.r + Color0.b) / 2.0;
    float Magenta1 = (Color1.r + Color1.b) / 2.0;
    
    if (Magenta0 > Magenta1)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

kernel void MultiFrameCombiner2Yellow(texture2d<float, access::read> Texture0 [[texture(0)]],
                                      texture2d<float, access::read> Texture1 [[texture(1)]],
                                      texture2d<float, access::write> OutTexture [[texture(2)]],
                                      constant MultiFrameParameters &Parameters [[buffer(0)]],
                                      uint2 gid [[thread_position_in_grid]])
{
    float4 Color0 = Texture0.read(gid);
    float4 Color1 = Texture1.read(gid);
    float4 Final = float4(0.0, 0.0, 0.0, 1.0);
    
    float Yellow0 = (Color0.r + Color0.g) / 2.0;
    float Yellow1 = (Color1.r + Color1.g) / 2.0;
    
    if (Yellow0 > Yellow1)
        {
        Final = Color0;
        }
    else
        {
        Final = Color1;
        }
    OutTexture.write(Final, gid);
}

