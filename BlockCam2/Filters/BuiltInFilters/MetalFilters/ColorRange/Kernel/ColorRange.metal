//
//  ColorRange.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

#include <metal_stdlib>
using namespace metal;

struct ColorRangeParameters
{
    float RangeStart;
    float RangeEnd;
    bool InvertRange;
    uint NonRangeAction;
    float4 NonRangeColor;
};

float4 MakeRGB(float FromH, float FromS, float FromL)
{
    float C = (1.0 - abs(2.0 * FromL - 1.0)) * FromS;
    float HPrime = (FromH * 360.0) / 60.0;
    float HPrimeM2 = fmod(HPrime, 2.0);
    float X = C * (1.0 - abs(HPrimeM2 - 1.0));
    float m = FromL - (C / 2.0);
    float R = 0.0;
    float G = 0.0;
    float B = 0.0;
    
    if (FromH >= 0.0 && FromH < 60.0)
        {
        R = C;
        G = X;
        B = 0.0;
        }
    else
        if (FromH >= 60.0 && FromH < 120.0)
            {
            R = X;
            G = C;
            B = 0.0;
            }
        else
            if (FromH >= 120.0 && FromH < 180.0)
                {
                R = 0.0;
                G = C;
                B = X;
                }
            else
                if (FromH >= 180.0 && FromH < 240.0)
                    {
                    R = 0.0;
                    G = X;
                    B = C;
                    }
                else
                    if (FromH >= 240.0 && FromH < 300.0)
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
    return float4(R, G, B, 1.0);
}

kernel void ColorRange(texture2d<float, access::read> Image [[texture(0)]],
                       texture2d<float, access::write> OutTexture [[texture(1)]],
                       constant ColorRangeParameters &Parameters [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = Image.read(gid);
    
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
    
    bool InRange = false;
    if (Parameters.InvertRange)
        {
        if (H < Parameters.RangeStart || H > Parameters.RangeEnd)
            {
            InRange = true;
            }
        }
    else
        {
        if (H >= Parameters.RangeStart && H <= Parameters.RangeEnd)
            {
            InRange = true;
            }
        }
    
    if (InRange)
        {
        OutTexture.write(InColor, gid);
        return;
        }
    
    switch (Parameters.NonRangeAction)
        {
            case 0:
            {
            float g = (InColor.r + InColor.g + InColor.b) / 3.0;
            OutTexture.write(float4(g, g, g, 1.0), gid);
            break;
            }
            
            case 1:
            {
            float gmax = max(InColor.r, max(InColor.g, InColor.b));
            OutTexture.write(float4(gmax, gmax, gmax, 1.0), gid);
            break;
            }
            
            case 2:
            {
            float gmin = min(InColor.r, min(InColor.g, InColor.b));
            OutTexture.write(float4(gmin, gmin, gmin, 1.0), gid);
            break;
            }
            
            case 3:
            {
            H = 1.0 - H;
            OutTexture.write(MakeRGB(H, S, L), gid);
            break;
            }
            
            case 4:
            {
            L = 1.0 - L;
            OutTexture.write(MakeRGB(H, S, L), gid);
            break;
            }
            
            case 5:
            {
            L = L * 0.5;
            OutTexture.write(MakeRGB(H, S, L), gid);
            break;
            }
            
            case 6:
            {
            S = S * 0.5;
            OutTexture.write(MakeRGB(H, S, L), gid);
            break;
            }
            
            case 7:
            {
            OutTexture.write(Parameters.NonRangeColor, gid);
            break;
            }
            
            default:
            {
            OutTexture.write(float4(0.0, 0.0, 0.0, 0.0), gid);
            break;
            }
        }
}
