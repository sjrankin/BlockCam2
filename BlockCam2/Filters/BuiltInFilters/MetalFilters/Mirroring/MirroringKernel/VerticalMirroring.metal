//
//  VerticalMirroring.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/1/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void MirrorVerticalTopToBottom(texture2d<float, access::read> Source [[texture(0)]],
                                        texture2d<float, access::write> Destination [[texture(1)]],
                                        uint2 gid [[thread_position_in_grid]])
{
    uint Height = Source.get_width();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    if (gid.x > HHeight)
        {
        return;
        }
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, gid);
    NewLocation.x = Height - gid.x;
    NewLocation.y = gid.y;
    Destination.write(Pixel, NewLocation);
}

kernel void MirrorVerticalBottomToTop(texture2d<float, access::read> Source [[texture(0)]],
                                        texture2d<float, access::write> Destination [[texture(1)]],
                                        uint2 gid [[thread_position_in_grid]])
{
    uint Height = Source.get_width();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    if (gid.x < HHeight)
        {
        return;
        }
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, gid);
    NewLocation.x = Height - gid.x;
    NewLocation.y = gid.y;
    Destination.write(Pixel, NewLocation);
}
