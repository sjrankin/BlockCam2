//
//  Solarize.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/16/21.
//

#include <metal_stdlib>
using namespace metal;

struct SolarizeParameters
{
    //0 = if channel < threshold, 1 = if pixel < brightness,
    //2 = if pixel < saturation,  3 = if hue in range
    uint SolarizeHow;
    float LowThreshold;
    float HighThreshold;
    float LowHue;
    float HighHue;
    float BrightnessThresholdLow;
    float BrightnessThresholdHigh;
    float SaturationThresholdLow;
    float SaturationThresholdHigh;
    bool SolarizeIfGreater;
};


float4 ToHSB_ForSolarize(float4 Source)
{
    float r = Source.r;
    float g = Source.g;
    float b = Source.b;
    
    float H = 0.0;
    float S = 0.0;
    float B = 0.0;
    
    float MinV = min(r, min(g, b));
    float MaxV = max(r, max(g, b));
    float Delta = MaxV - MinV;
    float Hue = 0.0;
    
    if (Delta != 0)
        {
        if (r == MaxV)
            {
            Hue = (g - b) / Delta;
            }
        else
            if (g == MaxV)
                {
                Hue = 2.0 + ((b - r) / Delta);
                }
            else
                {
                Hue = 4.0 + ((r - g) / Delta);
                }
        
        Hue = Hue * 60.0;
        if (Hue < 0)
            {
            Hue = Hue + 360.0;
            }
        }
    
    float Saturation = MaxV == 0.0 ? 0.0 : (Delta / MaxV);
    float Brightness = MaxV;
    
    H = Hue / 360.0;
    S = Saturation;
    B = Brightness;
    float4 Results = float4(H, S, B, 1.0);
    return Results;
}

kernel void SolarizeKernel(texture2d<float, access::read> InTexture [[texture(0)]],
                           texture2d<float, access::write> OutTexture [[texture(1)]],
                           constant SolarizeParameters &Solarize [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = InTexture.read(gid);
    float Red = InColor.r;
    float Green = InColor.g;
    float Blue = InColor.b;
    float4 HSB = ToHSB_ForSolarize(InColor);
    
    switch (Solarize.SolarizeHow)
        {
            case 0:
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if channel value is in the threshold range
                if ((InColor.r >= Solarize.LowThreshold) && (InColor.r <= Solarize.HighThreshold))
                    {
                    Red = 1.0 - Red;
                    }
                if ((InColor.g >= Solarize.LowThreshold) && (InColor.g <= Solarize.HighThreshold))
                    {
                    Green = 1.0 - Green;
                    }
                if ((InColor.b >= Solarize.LowThreshold) && (InColor.b <= Solarize.HighThreshold))
                    {
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if channel value is less than the threshold
                if ((InColor.r >= Solarize.LowThreshold) && (InColor.r <= Solarize.HighThreshold))
                    {
                    }
                else
                    {
                    Red = 1.0 - Red;
                    }
                if ((InColor.g >= Solarize.LowThreshold) && (InColor.g <= Solarize.HighThreshold))
                    {
                    }
                else
                    {
                    Green = 1.0 - Green;
                    }
                if ((InColor.b >= Solarize.LowThreshold) && (InColor.b <= Solarize.HighThreshold))
                    {
                    }
                else
                    {
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 1:
            //Saturation is returned in the g (for green) channel.
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's saturation is less than the saturation threshold.
                if (HSB.g < Solarize.SaturationThresholdLow)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's saturation is greater than the saturation threshold.
                if (HSB.g > Solarize.SaturationThresholdHigh)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 2:
            //Brightness is returned in the b (for blue) channel.
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's brightness is less than the brightness threshold.
                if (HSB.b < Solarize.BrightnessThresholdLow)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's brightness is greater than the brightness threshold.
                if (HSB.b > Solarize.BrightnessThresholdHigh)
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            break;
            
            case 3:
            //Saturation is returned in the r (for red) channel.
            if (Solarize.SolarizeIfGreater)
                {
                //Solarize if the pixel's hue is in the range.
                if ((HSB.r >= Solarize.LowHue) && (HSB.r <= Solarize.HighHue))
                    {
                    Red = 1.0 - Red;
                    Green = 1.0 - Green;
                    Blue = 1.0 - Blue;
                    }
                }
            else
                {
                //Solarize if the pixel's hue is out of the range.
                if ((HSB.r >= Solarize.LowHue) && (HSB.r <= Solarize.HighHue))
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
        }
    
    float4 OutColor = float4(Red, Green, Blue, 1.0);
    OutTexture.write(OutColor, gid);
}
