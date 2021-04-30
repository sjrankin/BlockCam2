//
//  Mirroring.metal
//  BlockCam2
//  Adapted from BumpCamera, 2/2/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

#include <metal_stdlib>
using namespace metal;


struct MirrorParameters
{
    //0 = horizontal (left to right), 1 = vertical (top to bottom)
    uint Direction;
    //0 = left, 1 = right
    uint HorizontalSide;
    //0 = top, 1 = bottom
    uint VerticalSide;
    //quadrant to reflect
    uint Quadrant;
    //determines if the image is rotated due to AV-iness
    bool IsAVRotated;
};

constant const uint Top = 0;
constant const uint Bottom = 1;
constant const uint Left = 0;
constant const uint Right = 1;
constant const uint ReflectHorizontally = 0;
constant const uint ReflectVertically = 1;
constant const uint QuadrantReflection = 2;
constant const uint MirrorHorizontally = 3;
constant const uint MirrorVertically = 4;

// The mirroring/reflection kernel.
kernel void MirroringKernel(texture2d<float, access::read> inTexture [[texture(0)]],
                            texture2d<float, access::write> outTexture [[texture(1)]],
                            constant MirrorParameters &Mirror [[buffer(0)]],
                            device float *Output [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = inTexture.read(gid);
    uint2 NewLocation;
    
    uint Width = inTexture.get_width();
    uint HWidth = Width / 2;
    uint Height = inTexture.get_height();
    uint HHeight = Height / 2;
    Output[0] = (float)Width;
    Output[1] = (float)Height;
    
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
    
    switch (Mirror.Direction)
        {
            case ReflectHorizontally: //left-to-right or right-to-left
            {
            if (Mirror.HorizontalSide == Left)
                {
                if (gid.x > HWidth)
                    {
                    return;
                    }
                outTexture.write(InColor, gid);
                NewLocation.x = HWidth + (HWidth - gid.x);
                NewLocation.y = gid.y;
                outTexture.write(InColor, NewLocation);
                return;
                }
            if (Mirror.HorizontalSide == Right)
                {
                if (gid.x < HWidth)
                    {
                    return;
                    }
                outTexture.write(InColor, gid);
                NewLocation.x = HWidth - (gid.x - HWidth);
                NewLocation.y = gid.y;
                outTexture.write(InColor, NewLocation);
                return;
                }
            }
            break;
            
            case ReflectVertically: //top-to-bottom or bottom-to-top
            {
            if (Mirror.VerticalSide == Top)
                {
                if (gid.y > HHeight)
                    {
                    return;
                    }
                outTexture.write(InColor, gid);
                NewLocation.x = gid.x;
                NewLocation.y = HHeight + (HHeight - gid.y);
                outTexture.write(InColor, NewLocation);
                //            float4 test = float4(1.0,1.0,0.0,1.0);
                //            outTexture.write(test, NewLocation);
                return;
                }
            if (Mirror.VerticalSide == Bottom)
                {
                if (gid.y < HHeight)
                    {
                    return;
                    }
                outTexture.write(InColor, gid);
                NewLocation.x = gid.x;
                NewLocation.y = HHeight - (gid.y - HHeight);
                outTexture.write(InColor, NewLocation);
                return;
                }
            }
            break;
            
            case QuadrantReflection:
            {
            switch (Mirror.Quadrant)
                {
                    case 1:
                    if (PointInQuadrant == 1)
                        {
                        //Quadrant I point.
                        outTexture.write(InColor, gid);
                        //Quadrant II point.
                        NewLocation.x = HWidth + (HWidth - gid.x);
                        NewLocation.y = gid.y;
                        outTexture.write(InColor, NewLocation);
                        //Quadrant III point.
                        NewLocation.x = HWidth + (HWidth - gid.x);
                        NewLocation.y = HHeight + (HHeight - gid.y);
                        outTexture.write(InColor, NewLocation);
                        //Quadrant IV point.
                        NewLocation.x = gid.x;
                        NewLocation.y = HHeight + (HHeight - gid.y);
                        outTexture.write(InColor, NewLocation);
                        return;
                        }
                    break;
                    
                    case 2:
                    if (PointInQuadrant == 2)
                        {
                        //Quadrant II point.
                        outTexture.write(InColor, gid);
                        //Quadrant I point.
                        NewLocation.x = HWidth - (gid.x - HWidth);
                        NewLocation.y = gid.y;
                        outTexture.write(InColor, NewLocation);
                        //Quadrant III point.
                        NewLocation.x = gid.x;
                        NewLocation.y = HHeight + (HHeight - gid.y);
                        outTexture.write(InColor, NewLocation);
                        //Quadrant IV point.
                        NewLocation.x = HWidth - (gid.x - HWidth);
                        NewLocation.y = HHeight + (HHeight - gid.y);
                        outTexture.write(InColor, NewLocation);
                        return;
                        }
                    break;
                    
                    case 3:
                    if (PointInQuadrant == 3)
                        {
                        //Quadrant III point.
                        outTexture.write(InColor, gid);
                        //Quadrant IV point.
                        NewLocation.x = HWidth - (gid.x - HWidth);
                        NewLocation.y = gid.y;
                        outTexture.write(InColor, NewLocation);
                        //Quadrant I point.
                        NewLocation.x = HWidth - (gid.x - HWidth);
                        NewLocation.y = HHeight - (gid.y - HHeight);
                        outTexture.write(InColor, NewLocation);
                        //Quadrant II point.
                        NewLocation.x = gid.x;
                        NewLocation.y = HHeight - (gid.y - HHeight);
                        outTexture.write(InColor, NewLocation);
                        return;
                        }
                    break;
                    
                    case 4:
                    if (PointInQuadrant == 4)
                        {
                        //Quadrant IV point.
                        outTexture.write(InColor, gid);
                        //Quadrant I point.
                        NewLocation.x = gid.x;
                        NewLocation.y = HHeight - (gid.y - HHeight);
                        outTexture.write(InColor, NewLocation);
                        //Quadrant II point.
                        NewLocation.x = HWidth + (HWidth - gid.x);
                        NewLocation.y = HHeight - (gid.y - HHeight);
                        outTexture.write(InColor, NewLocation);
                        //Quadrant III point.
                        NewLocation.x = HWidth + (HWidth - gid.x);
                        NewLocation.y = gid.y;
                        outTexture.write(InColor, NewLocation);
                        return;
                        }
                    break;
                    
                    default:
                    return;
                }
            return;
            }
            
            case MirrorHorizontally:
            {
            NewLocation.y = gid.y;
            NewLocation.x = (Width - 1) - gid.x;
            outTexture.write(InColor, NewLocation);
            return;
            }
            
            case MirrorVertically:
            {
            NewLocation.x = gid.x;
            NewLocation.y = (Height - 1) - gid.y;
            outTexture.write(InColor, NewLocation);
            return;
            }
            
            default:
            break;
        }
    
    //We should never get here...
}