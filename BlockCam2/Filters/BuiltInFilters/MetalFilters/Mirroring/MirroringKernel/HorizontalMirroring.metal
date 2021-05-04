//
//  HorizontalMirroring.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/1/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void MirrorHorizontalLeftToRight(texture2d<float, access::read> Source [[texture(0)]],
                                        texture2d<float, access::write> Destination [[texture(1)]],
                                        uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_height();
    uint HWidth = Width / 2;
    uint2 NewLocation;
    if (gid.y > HWidth)
        {
        return;
        }
    float4 Pixel = Source.read(gid);
    Destination.write(Pixel, gid);
    NewLocation.x = gid.x;
    NewLocation.y = HWidth + (HWidth - gid.y);
    Destination.write(Pixel, NewLocation);
}

kernel void MirrorHorizontalRightToLeft(texture2d<float, access::read> Source [[texture(0)]],
                                        texture2d<float, access::write> Destination [[texture(1)]],
                                        uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_height();
    uint HWidth = Width / 2;
    uint2 NewLocation;
    float4 Pixel = Source.read(gid);
    if (gid.y < HWidth)
        {
        return;
        }
    Destination.write(Pixel, gid);
    NewLocation.x = gid.x;
    NewLocation.y = HWidth - (gid.y - HWidth);
    Destination.write(Pixel, NewLocation);
}

