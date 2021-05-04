//
//  QuadrantMirroring.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/1/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void MirrorQuadrant1(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    float4 Pixel = Source.read(gid);
    uint2 NewLocation;
    if (!((gid.x <= HWidth) && (gid.y >= HHeight)))
        {
        return;
        }
    
    // Quadrant I
    Destination.write(Pixel, gid);
    
    // Quadrant II
    NewLocation.x = HWidth - (gid.x - HWidth);
    NewLocation.y = Height - gid.y;
    Destination.write(Pixel, NewLocation);
    
    // Quadrant III
    NewLocation.x = Width - gid.x;
    NewLocation.y = gid.y;
    Destination.write(Pixel, NewLocation);
    
    // Quadrant IV
    NewLocation.x = Width - gid.x;
    NewLocation = Height - gid.y;
    //Destination.write(Pixel, NewLocation);
}

kernel void MirrorQuadrant3(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(float4(0.25,0.15,0.0,1.0),gid);
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(float4(0.5,0.0,0.0,1.0),gid);
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(Source.read(gid),gid);
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(float4(0.5,0.5,0.0,1.0),gid);
        }
}

kernel void MirrorQuadrant4(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(float4(0.0,0.15,0.25,1.0),gid);
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(float4(0.0,0.0,0.5,1.0),gid);
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(float4(0.5,0.0,0.5,1.0),gid);
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(Source.read(gid),gid);
        }
}

kernel void MirrorQuadrant2(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(Source.read(gid),gid);
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(float4(0.0,0.0,0.5,1.0),gid);
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        Destination.write(float4(0.5,0.0,0.5,1.0),gid);
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        Destination.write(float4(0.0,0.0,1.0,1.0),gid);
        //Destination.write(Source.read(gid),gid);
        }
}

#if false
kernel void MirrorQuadrant2(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    
    uint PointInQuadrant = 1;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 1;
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 4;
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 2;
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 3;
        }
    
    if (PointInQuadrant == 2)
        {
        float4 Pixel = Source.read(gid);
        //Quadrant I point
        Destination.write(Pixel, gid);
        //Quadrant II point
        NewLocation.x = HWidth + (HWidth - gid.x);
        NewLocation.y = gid.y;
        Destination.write(Pixel, NewLocation);
        //Quadrant III Point
        NewLocation.x = HWidth + (HWidth - gid.x);
        NewLocation.y = HHeight + (HHeight - gid.y);
        Destination.write(Pixel, NewLocation);
        //Quadrant IV Point
        NewLocation.x = gid.x;
        NewLocation.y = HHeight + (HHeight - gid.y);
        Destination.write(Pixel, NewLocation);
        }
}
#endif

#if false
kernel void MirrorQuadrant1(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    
    uint PointInQuadrant = 1;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 1;
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 4;
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 2;
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 3;
        }
    
    if (PointInQuadrant == 1)
        {
        float4 Pixel = Source.read(gid);
        //Quadrant II point
        Destination.write(Pixel, gid);
        //Quadrant I point
        NewLocation.x = HWidth + (HWidth - gid.x);
        NewLocation.y = gid.y;
        Destination.write(Pixel, NewLocation);
        //Quadrant III Point
        NewLocation.x = gid.x;
        NewLocation.y = HHeight + (HHeight - gid.y);
        Destination.write(Pixel, NewLocation);
        //Quadrant IV Point
        NewLocation.x = HWidth - (gid.x - HWidth);
        NewLocation.y = HHeight + (HHeight - gid.y);
        Destination.write(Pixel, NewLocation);
        }
}
#endif

#if false
kernel void MirrorQuadrant1(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    
    uint PointInQuadrant = 1;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 1;
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 4;
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 2;
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 3;
        }
    
    Destination.write(float4(0.0,1.0,0.6,1.0),gid);
    if (PointInQuadrant == 1)
        {
        float4 Pixel = Source.read(gid);
        //Quadrant III point
        Destination.write(Pixel, gid);
        //Quadrant IV point
        NewLocation.x = HWidth - (gid.x - HWidth);
        NewLocation.y = gid.y;
        Destination.write(Pixel, NewLocation);
        //Quadrant I Point
        NewLocation.x = HWidth - (gid.x - HWidth);
        NewLocation.y = HHeight - (gid.y - HHeight);
        Destination.write(Pixel, NewLocation);
        //Quadrant II Point
        NewLocation.x = gid.x;
        NewLocation.y = HHeight + (gid.y - HHeight);
        Destination.write(Pixel, NewLocation);
        }
}
#endif

#if false
kernel void MirrorQuadrant1(texture2d<float, access::read> Source [[texture(0)]],
                            texture2d<float, access::write> Destination [[texture(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = Source.get_width();
    uint HWidth = Width / 2;
    uint Height = Source.get_height();
    uint HHeight = Height / 2;
    uint2 NewLocation;
    
    uint PointInQuadrant = 1;
    if ((gid.x <= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 1;
        }
    if ((gid.x <= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 4;
        }
    if ((gid.x >= HWidth) && (gid.y <= HHeight))
        {
        PointInQuadrant = 2;
        }
    if ((gid.x >= HWidth) && (gid.y >= HHeight))
        {
        PointInQuadrant = 3;
        }
    
    if (PointInQuadrant == 1)
        {
        float4 Pixel = Source.read(gid);
        //Quadrant IV point
        Destination.write(Pixel, gid);
        //Quadrant I point
        NewLocation.x = gid.x;
        NewLocation.y = HHeight - (gid.y - HHeight);
        Destination.write(Pixel, NewLocation);
        //Quadrant II Point
        NewLocation.x = HWidth + (HWidth - gid.x);
        NewLocation.y = HHeight - (gid.y - HHeight);
        Destination.write(Pixel, NewLocation);
        //Quadrant III Point
        NewLocation.x = HWidth + (HWidth - gid.x);
        NewLocation.y = gid.y;
        Destination.write(Pixel, NewLocation);
        }
}
#endif
