//
//  Crop.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/2/21.
//

#include <metal_stdlib>
using namespace metal;

struct CropParameters
{
    int StartX;
    int StartY;
    int Width;
    int Height;
};

kernel void Crop(texture2d<float, access::read> Source [[texture(0)]],
                 texture2d<float, access::write> Destination [[texture(1)]],
                 constant CropParameters &Parameters [[buffer(0)]],
                 uint2 gid [[thread_position_in_grid]])
{
    if ((gid.x < uint(Parameters.StartX)) || (gid.x > uint(Parameters.StartX + Parameters.Width)))
        {
        return;
        }
    if ((gid.y < uint(Parameters.StartY)) || (gid.y > uint(Parameters.StartY + Parameters.Height)))
        {
        return;
        }
    float4 Pixel = Source.read(gid);
    uint2 TargetPoint;
    TargetPoint.x = gid.x - Parameters.StartX;
    TargetPoint.y = gid.y - Parameters.StartY;
    Destination.write(Pixel, TargetPoint);
}
