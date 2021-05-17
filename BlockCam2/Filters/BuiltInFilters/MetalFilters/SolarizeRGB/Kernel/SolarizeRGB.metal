//
//  SolarizeRGB.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/17/21.
//

#include <metal_stdlib>
using namespace metal;

struct SolarizeRGBParameters
{
    //0 = if channel < threshold, 1 = if pixel < red,
    //2 = if pixel < green,  3 = if hue in blue
    uint SolarizeHow;
    float Threshold;
    bool SolarizeIfGreater;
};

kernel void SolarizeRGB(texture2d<float, access::read> InTexture [[texture(0)]],
                        texture2d<float, access::write> OutTexture [[texture(1)]],
                        constant SolarizeRGBParameters &Solarize [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = InTexture.read(gid);
    float Red = InColor.r;
    float Green = InColor.g;
    float Blue = InColor.b;
    
    switch (Solarize.SolarizeHow)
        {
            case 0:
            if (Solarize.SolarizeIfGreater)
                {
                if (InColor.r > Solarize.Threshold && InColor.g > Solarize.Threshold && InColor.b > Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                if (InColor.r < Solarize.Threshold && InColor.g < Solarize.Threshold && InColor.b < Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 1:
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's red is in the range.
                if ((InColor.r >= Solarize.Threshold) && (InColor.r <= Solarize.Threshold))
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's red is out of the range.
                if ((InColor.r >= Solarize.Threshold) && (InColor.r <= Solarize.Threshold))
                    {
                    }
                else
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 2:
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's green is less than the saturation threshold.
                if (InColor.g < Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's green is greater than the saturation threshold.
                if (InColor.g > Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 3:
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's blue is less than the brightness threshold.
                if (InColor.b < Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's blue is greater than the brightness threshold.
                if (InColor.b > Solarize.Threshold)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
        }
    
    float4 OutColor = float4(Red, Green, Blue, 1.0);
    OutTexture.write(OutColor, gid);
}
