//
//  SimpleInversion.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/1/21.
//

#include <metal_stdlib>
using namespace metal;


struct SimpleInversionParameters
{
    int Channel;
};

kernel void InvertHSB(texture2d<float, access::read> Source  [[texture(0)]],
                      texture2d<float, access::write> Output [[texture(1)]],
                      constant SimpleInversionParameters &Parameters [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float4 SourcePixel = Source.read(gid);
    float r = SourcePixel.r;
    float g = SourcePixel.g;
    float b = SourcePixel.b;
    
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
        }
    
    float Saturation = MaxV == 0.0 ? 0.0 : (Delta / MaxV);
    float Brightness = MaxV;
    
    switch (Parameters.Channel)
        {
            case 3:
            Hue = 1.0 - Hue;
            break;
            
            case 4:
            Saturation = 1.0 - Saturation;
            break;
            
            case 5:
            Brightness = 1.0 - Brightness;
            break;
            
            default:
            Output.write(SourcePixel, gid);
            return;
        }
    
    //https://www.rapidtables.com/convert/color/hsv-to-rgb.html
    float C = Brightness * Saturation;
    float X = C * (1 - abs(fmod(Hue, 2.0) - 1));
    float m = Brightness - C;
    float H = Hue * 60.0;
    float Rp = 0.0;
    float Gp = 0.0;
    float Bp = 0.0;
    if (H >= 0 && H < 60.0)
        {
        Rp = C;
        Gp = X;
        }
    else
        if (H >= 60.0 && H < 120.0)
            {
            Rp = X;
            Gp = C;
            }
    else
        if (H >= 120.0 && H < 180.0)
            {
            Gp = C;
            Bp = X;
            }
    else
        if (H >= 180.0 && H < 240.0)
            {
            Gp = X;
            Bp = C;
            }
    else
        if (H >= 240.0 && H < 300.0)
            {
            Rp = X;
            Bp = C;
            }
    else
        {
        Rp = C;
        Bp = X;
        }
    Rp += m;
    Gp += m;
    Bp += m;
    Output.write(float4(Rp, Gp, Bp, 1.0), gid);
}

kernel void InvertCMYK(texture2d<float, access::read> Source  [[texture(0)]],
                      texture2d<float, access::write> Output [[texture(1)]],
                      constant SimpleInversionParameters &Parameters [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]])
{
    float4 SourcePixel = Source.read(gid);
    float r = SourcePixel.r;
    float g = SourcePixel.g;
    float b = SourcePixel.b;
    float K = 0.0;
    float Y = 0.0;
    float M = 0.0;
    float C = 0.0;
    K = 1.0 - max(r, max(g, b));
    if (K == 0.0)
        {
        C = K;
        M = K;
        Y = K;
        }
    else
        {
        C = (1.0 - r - K) / (1.0 - K);
        M = (1.0 - g - K) / (1.0 - K);
        Y = (1.0 - b - K) / (1.0 - K);
        }
    
    switch (Parameters.Channel)
        {
            case 6:
            C = 1.0 - C;
            break;
            
            case 7:
            M = 1.0 - M;
            break;
            
            case 8:
            Y = 1.0 - Y;
            break;
            
            case 9:
            K = 1.0 - K;
            break;
            
            default:
            Output.write(SourcePixel, gid);
            return;
        }
    
    r = (1.0 - C) * (1.0 - K);
    g = (1.0 - M) * (1.0 - K);
    b = (1.0 - Y) * (1.0 - K);
    Output.write(float4(r, g, b, 1.0), gid);
}

kernel void InvertRGB(texture2d<float, access::read> Source  [[texture(0)]],
                         texture2d<float, access::write> Output [[texture(1)]],
                         constant SimpleInversionParameters &Parameters [[buffer(0)]],
                         uint2 gid [[thread_position_in_grid]])
{
    float4 SourcePixel = Source.read(gid);
    float r = SourcePixel.r;
    float g = SourcePixel.g;
    float b = SourcePixel.b;
    
    switch (Parameters.Channel)
        {
            case 0:
            r = 1.0 - r;
            break;
            
            case 1:
            g = 1.0 - g;
            break;
            
            case 2:
            b = 1.0 - b;
            break;
            
            default:
            Output.write(SourcePixel, gid);
            return;
        }
    
    Output.write(float4(r, g, b, 1.0), gid);
}
