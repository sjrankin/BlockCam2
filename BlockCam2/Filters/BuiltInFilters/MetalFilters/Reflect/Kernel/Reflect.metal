//
//  Reflect.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void HorizontalReflect(texture2d<float, access::read> Source [[texture(0)]],
                       texture2d<float, access::write> Destination [[texture(1)]],
                       uint2 gid [[thread_position_in_grid]])
{
    int Width = Source.get_width();
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, uint2(Width - gid.x, gid.y));
}

kernel void VerticalReflect(texture2d<float, access::read> Source [[texture(0)]],
                              texture2d<float, access::write> Destination [[texture(1)]],
                              uint2 gid [[thread_position_in_grid]])
{
    int Height = Source.get_height();
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, uint2(gid.x, Height - gid.y));
}

kernel void HorizontalVerticalReflect(texture2d<float, access::read> Source [[texture(0)]],
                              texture2d<float, access::write> Destination [[texture(1)]],
                              uint2 gid [[thread_position_in_grid]])
{
    int Width = Source.get_width();
    int Height = Source.get_height();
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, uint2(Width - gid.x, Height - gid.y));
}
