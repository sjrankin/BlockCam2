//
//  HSB.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/6/21.
//

#include <metal_stdlib>
using namespace metal;


struct HSBParameters
{
    bool ChangeHue;
    float HueMultiplier;
    bool ChangeSaturation;
    float SaturationMultiplier;
    bool ChangeBrightness;
    float BrightnessMultiplier;
};

kernel void HSB(texture2d<float, access::read> InTexture [[texture(0)]],
                     texture2d<float, access::write> OutTexture [[texture(1)]],
                     constant HSBParameters &Parameters [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = InTexture.read(gid);
    
    if (!Parameters.ChangeHue && !Parameters.ChangeSaturation && !Parameters.ChangeBrightness)
        {
        OutTexture.write(InColor, gid);
        return;
        }
    
    float r = InColor.r;
    float g = InColor.g;
    float b = InColor.b;
    
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
    
    float H = Hue / 360.0;
    float S = Saturation;
    float L = Brightness;
    
    if (Parameters.ChangeHue)
        {
        H = H * Parameters.HueMultiplier;
        }
    if (Parameters.ChangeSaturation)
        {
        S = S * Parameters.SaturationMultiplier;
        }
    if (Parameters.ChangeBrightness)
        {
        L = L * Parameters.BrightnessMultiplier;
        }
    
    float C = (1.0 - abs(2.0 * L - 1.0)) * S;
    float HPrime = (H * 360.0) / 60.0;
    float HPrimeM2 = fmod(HPrime, 2.0);
    float X = C * (1.0 - abs(HPrimeM2 - 1.0));
    float m = L - (C / 2.0);
    float R = 0.0;
    float G = 0.0;
    float B = 0.0;
    
    if (H >= 0.0 && H < 60.0)
        {
        R = C;
        G = X;
        B = 0.0;
        }
    else
        if (H >= 60.0 && H < 120.0)
            {
            R = X;
            G = C;
            B = 0.0;
            }
    else
        if (H >= 120.0 && H < 180.0)
            {
            R = 0.0;
            G = C;
            B = X;
            }
    else
        if (H >= 180.0 && H < 240.0)
            {
            R = 0.0;
            G = X;
            B = C;
            }
    else
        if (H >= 240.0 && H < 300.0)
            {
            R = X;
            G = 0.0;
            B = C;
            }
    else
        {
        R = C;
        G = 0.0;
        B = X;
        }
    
    R += m;
    G += G;
    B += B;
    
    OutTexture.write(float4(R, G, B, 1.0), gid);
}
