//
//  Pixellatekernel.metal
//  BumpCamera
//
//  Created by Stuart Rankin on 1/28/19.
//  Copyright © 2019 - 2021 Stuart Rankin. All rights reserved.
//

#include <metal_stdlib>
#include <metal_geometric>
using namespace metal;

struct BlockInfoParameters
{
    uint Width;
    uint Height;
    // Highlight values: 0 = Hue, 1 = Saturation, 2 = Brightness, 3 = none
    uint HighlightAction;
    uint HighlightPixelBy;
    uint BrightnessHighlight;
    float4 Highlight_Color;
    uint ColorDetermination;
    float HighlightValue;
    bool HighlightIfGreater;
    bool AddBorder;
    float4 BorderColor;
    float4 BGColor;
};

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 RGBtoYCbCr(float4 Source)
{
    float R = Source.r * 255.0;
    float G = Source.g * 255.0;
    float B = Source.b * 255.0;
    float Y = (0.257 * R) + (0.504 * G) + (0.098 * B) + 16.0;
    float Cb = (-0.148 * R) - (0.291 * G) + (0.439 * B) + 128.0;
    float Cr = (0.439 * R) - (0.368 * G) - (0.071 * B) + 128.0;
    return float4(Y, Cb, Cr, 1.0);
}

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 YCbCrtoRGB(float4 Source)
{
    float R = (1.164 * (Source.r - 16.0)) + (1.596 * (Source.b - 128.0));
    R = R / 255.0;
    float G = (1.164 * (Source.r - 16.0)) - (0.813 * (Source.b - 128.0)) - (0.392 * (Source.g - 128.0));
    G = G / 255.0;
    float B = (1.164 * (Source.r - 16.0)) + (2.017 * (Source.g - 128.0));
    B = B / 255.0;
    return float4(R, G, B, 1.0);
}

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 RGBtoYUV(float4 Source)
{
    float Y = (0.299 * Source.r) + (0.587 * Source.g) + (0.114 * Source.b);
    float U = (Source.b - Y) * 0.492; //or, -0.147 * R - 0.289 * G + 0.436 * B
    float V = (Source.r - Y) * 0.877; //or, 0.615 * R - 0.515 * G - 0.100 * B
    return float4(Y, U, V, 1.0);
}

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 YUVtoRGB(float4 Source)
{
    float R = Source.r + (1.140 * Source.b);
    float G = Source.r - (0.394 * Source.g) - (0.581 * Source.b);
    float B = Source.r + (2.032 * Source.g);
    return float4(R, G, B, 1.0);
}

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 RGBtoXYZ(float4 Source)
{
    float X = (0.412453 * Source.r) + (0.35758 * Source.g) + (0.180423 * Source.b);
    float Y = (0.212671 * Source.r) + (0.71516 * Source.g) + (0.072169 * Source.b);
    float Z = (0.019334 * Source.r) + (0.119193 * Source.g) + (0.950227 * Source.b);
    return float4(X, Y, Z, 1.0);
}

//https://software.intel.com/en-us/ipp-dev-reference-color-models
float4 XYZtoRGB(float4 Source)
{
    float R = (3.240479 * Source.x) - (1.53715 * Source.y) - (0.498535 * Source.z);
    float G = (-0.969256 * Source.x) + (1.875991 * Source.y) + (0.041556 * Source.z);
    float B = (0.055648 * Source.x) - (0.204043 * Source.y) + (1.057311 * Source.z);
    return float4(R, G, B, 1.0);
}

//https://stackoverflow.com/questions/11704664/converting-hsb-color-to-rgb-in-objective-c
float4 HSBtoRGB(float4 Source)
{
    float Hue = Source.r;
    float Saturation = Source.g;
    float Luminance = Source.b;
    if (Saturation == 0.0)
        {
        return float4(Source.b, Source.b, Source.b, 1.0);
        }
    float H = Hue / 60.0;
    float I = floor(H);
    float F = H - I;
    float P = Luminance * (1.0 - Saturation);
    float Q = Luminance * (1.0 - (Saturation * F));
    float T = Luminance * (1.0 - (Saturation * (1.0 - F)));
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    switch ((int)I)
        {
            case 0:
            r = Luminance;
            g = T;
            b = P;
            break;
            
            case 1:
            r = Q;
            g = Luminance;
            b = P;
            break;
            
            case 2:
            r = P;
            g = Luminance;
            b = T;
            break;
            
            case 3:
            r = P;
            g = Q;
            b = Luminance;
            break;
            
            case 4:
            r = T;
            g = P;
            b = Luminance;
            break;
            
            default:
            r = Luminance;
            g = P;
            b = Q;
            break;
        }
    return float4(r, g, b, 1.0);
}

//https://www.cs.rit.edu/~ncs/color/t_convert.html
float4 RGBtoHSB(float4 Source)
{
    float r = Source.r;
    float g = Source.g;
    float b = Source.b;
    
    float S = 0.0;
    float L = 0.0;
    
    float CMin = min(r, min(g, b));
    float CMax = max(r, max(g, b));
    float Delta = CMax - CMin;
    float Hue = 0.0;
    
    if (Delta == 0.0)
        {
        Hue = 0.0;
        }
    else
        {
        if (CMax == r)
            {
            Hue = (g - b) / Delta + (g < b ? 6.0 : 0.0);
            }
        else
            if (CMax == g)
                {
                Hue = (((b - r) / Delta) + 2.0);
                }
            else
                if (CMax == b)
                    {
                    Hue = (((r - g) / Delta) + 4.0);
                    }
        }
    Hue = Hue * 60.0;
    if (Hue < 0.0)
        {
        Hue = Hue + 360.0;
        }
    L = CMax;
    S = CMax == 0.0 ? 0.0 : (CMax - CMin) / CMax;
    
    return float4(Hue, S, L, 1);
}

// Input is HSB color to potentially modify. Output is RGB color ready to be sent to the output texture.
float4 ApplyHighlight(float4 Source, uint Action)
{
    switch (Action)
        {
            case 0:
            {
            //grayscale
            float4 RGB = HSBtoRGB(Source);
            float Gray = (RGB.r + RGB.g + RGB.b) / 3.0;
            float4 Grayscale = float4(Gray, Gray, Gray, 1.0);
            return Grayscale;
            }
            
            case 1:
            {
            //transparent
            return float4(1.0, 1.0, 1.0, 0.0);
            }
            
            case 2:
            {
            //set to black
            return float4(0.0, 0.0, 0.0, 1.0);
            }
            
            case 3:
            {
            //set to white
            return float4(1.0, 1.0, 1.0, 1.0);
            }
            
            case 4:
            {
            //set to gray
            return float4(0.5, 0.5, 0.5, 1.0);
            }
            
            case 5:
            {
            //invert color
            float4 RGB = HSBtoRGB(Source);
            return float4(1.0 - RGB.r, 1.0 - RGB.g, 1.0 - RGB.b, 1.0);
            }
            
            case 6:
            {
            //invert hue
            float H = 360.0 - Source.r;
            float4 scratch = float4(H, Source.g, Source.b, 1.0);
            return HSBtoRGB(scratch);
            }
            
            case 7:
            {
            //brightness to max
            float4 scratch = float4(Source.r, Source.g, 1.0, 1.0);
            return HSBtoRGB(scratch);
            }
            
            case 8:
            {
            //saturation to max
            float4 scratch = float4(Source.r, 1.0, Source.b, 1.0);
            return HSBtoRGB(scratch);
            }
            
            case 9:
            {
            //draw border
            return HSBtoRGB(Source);
            }
            
            case 10:
            {
            float4 RGB = HSBtoRGB(Source);
            return float4(RGB.b, RGB.g, RGB.r, 1.0);
            }
            
            default:
            {
            return HSBtoRGB(Source);
            }
        }
}

kernel void PixelBlockColor(texture2d<float, access::read> Texture [[texture(0)]],
                            //texture2d<float, access::read> NotUsed [[texture(1)]],
                            constant BlockInfoParameters &BlockInfo [[buffer(0)]],
                            device float4 *Output [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = BlockInfo.Width;
    uint Height = BlockInfo.Height;
    uint CenterX = (gid.x / Width * Width);
    uint CenterY = (gid.y / Width * Height);
    
    uint2 PixellatedGrid = uint2(CenterX, CenterY);
    float4 ColorAtPixel = Texture.read(PixellatedGrid);
    
    uint MinX = CenterX - (Width / 2);
    if (MinX < 0)
        {
        MinX = 0;
        }
    uint MaxX = CenterX + (Width / 2);
    if (MaxX > Texture.get_width() - 1)
        {
        MaxX = Texture.get_width() - 1;
        }
    uint MinY = CenterY - (Height / 2);
    if (MinY < 0)
        {
        MinY = 0;
        }
    uint MaxY = CenterY + (Height / 2);
    if (MaxY > Texture.get_height() - 1)
        {
        MaxY = Texture.get_height() - 1;
        }
    
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    
    for (uint Y = MinY; Y < MaxY; Y++)
        {
        for (uint X = MinX; X < MaxX; X++)
            {
            r = r + Texture.read(uint2(X, Y)).r;
            g = g + Texture.read(uint2(X, Y)).g;
            b = b + Texture.read(uint2(X, Y)).b;
            }
        }
    r = r / (Height * Width);
    g = g / (Height * Width);
    b = b / (Height * Width);
    ColorAtPixel = float4(r, g, b, 1.0);
    int HBlocks = int(float(Texture.get_width()) / float(Width));
    int XBlock = int(float(gid.x) / float(Width));
    int YBlock = int(float(gid.y) / float(Height));
    int OutIndex = (YBlock * HBlocks) + XBlock;
    
    Output[OutIndex] = ColorAtPixel;
}

kernel void PixelCircle(texture2d<float, access::read> Texture [[texture(0)]],
                        texture2d<float, access::write> Output [[texture(1)]],
                        constant BlockInfoParameters &BlockInfo [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    uint Width = BlockInfo.Width;
    uint Height = BlockInfo.Height;
    uint CenterX = ((gid.x / Width) * Width);
    uint CenterY = ((gid.y / Width) * Height);
    
    uint MinX = CenterX - (Width / 2);
    if (MinX < 0)
        {
        MinX = 0;
        }
    uint MaxX = CenterX + (Width / 2);
    if (MaxX > Texture.get_width() - 1)
        {
        MaxX = Texture.get_width() - 1;
        }
    uint MinY = CenterY - (Height / 2);
    if (MinY < 0)
        {
        MinY = 0;
        }
    uint MaxY = CenterY + (Height / 2);
    if (MaxY > Texture.get_height() - 1)
        {
        MaxY = Texture.get_height() - 1;
        }
    
    float r = 0.0;
    float g = 0.0;
    float b = 0.0;
    
    for (uint Y = MinY; Y < MaxY; Y++)
        {
        for (uint X = MinX; X < MaxX; X++)
            {
            r = r + Texture.read(uint2(X, Y)).r;
            g = g + Texture.read(uint2(X, Y)).g;
            b = b + Texture.read(uint2(X, Y)).b;
            }
        }
    r = r / (Height * Width);
    g = g / (Height * Width);
    b = b / (Height * Width);
    float4 ColorAtPixel = float4(r, g, b, 1.0);
    
#if true
    if (gid.x == CenterX && gid.y == CenterY)
        {
        Output.write(ColorAtPixel, gid);
        }
#else
    int Radius = float(min(Width, Height) / 2);
    int FX = CenterX - (Width / 2);
    int FY = CenterY - (Height / 2);
//    float Distance = distance(float2(gid.x, gid.y), float2(FX, FY));//float2(CenterX, CenterY));
    float Distance = distance(float2(gid.x, gid.y), float2(CenterX, CenterY));
    
    //Output.write(BlockInfo.BGColor, gid);
    if (Distance <= Radius)
        {
        int FinalCenterX = CenterX - (Width / 2);
        int FinalCenterY = CenterY - (Height / 2);
        Output.write(ColorAtPixel, gid);//uint2(gid.x + CenterX, gid.y + CenterY));
        Output.write(ColorAtPixel, uint2(gid.x + gid.x, CenterY + gid.y));
        }
   // else
   //     {
   //     Output.write(float4(1.0, 1.0, 0.0, 1.0), gid);
   //     }
#endif
}

kernel void PixellateKernel(texture2d<float, access::read> InTexture [[texture(0)]],
                            texture2d<float, access::write> OutTexture [[texture(1)]],
                            constant BlockInfoParameters &BlockInfo [[buffer(0)]],
                            device float *Output [[buffer(1)]],
                            uint2 gid [[thread_position_in_grid]])
{
    uint Width = BlockInfo.Width;
    uint Height = BlockInfo.Height;
    uint CenterX = (gid.x / Width * Width);
    uint CenterY = (gid.y / Width * Height);
     
    uint2 PixellatedGrid = uint2(CenterX, CenterY);
    float4 ColorAtPixel = InTexture.read(PixellatedGrid);
    
    if (BlockInfo.ColorDetermination > 0)
        {
        uint MinX = CenterX - (Width / 2);
        if (MinX < 0)
            {
            MinX = 0;
            }
        uint MaxX = CenterX + (Width / 2);
        if (MaxX > InTexture.get_width() - 1)
            {
            MaxX = InTexture.get_width() - 1;
            }
        uint MinY = CenterY - (Height / 2);
        if (MinY < 0)
            {
            MinY = 0;
            }
        uint MaxY = CenterY + (Height / 2);
        if (MaxY > InTexture.get_height() - 1)
            {
            MaxY = InTexture.get_height() - 1;
            }
        
        float r = 0.0;
        float g = 0.0;
        float b = 0.0;
        
        for (uint Y = MinY; Y < MaxY; Y++)
            {
            for (uint X = MinX; X < MaxX; X++)
                {
                r = r + InTexture.read(uint2(X,Y)).r;
                g = g + InTexture.read(uint2(X,Y)).g;
                b = b + InTexture.read(uint2(X,Y)).b;
                }
            }
        r = r / (Height * Width);
        g = g / (Height * Width);
        b = b / (Height * Width);
        ColorAtPixel = float4(r, g, b, 1.0);
        }
    
    if (BlockInfo.HighlightPixelBy < 3)
        {
        float4 FinalColor = float4(1.0, 1.0, 1.0, 1.0);
        float4 HSB = RGBtoHSB(ColorAtPixel);
        switch (BlockInfo.HighlightPixelBy)
            {
                case 0:
                {
                float Hue = HSB.r / 360.0;
                if (BlockInfo.HighlightIfGreater)
                    {
                    if (Hue > BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                else
                    {
                    if (Hue < BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                break;
                }
                
                case 1:
                {
                float Saturation = HSB.g;
                if (BlockInfo.HighlightIfGreater)
                    {
                    if (Saturation > BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                else
                    {
                    if (Saturation < BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                break;
                }
                
                case 2:
                {
                float Brightness = HSB.b;
                if (BlockInfo.HighlightIfGreater)
                    {
                    if (Brightness > BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                else
                    {
                    if (Brightness < BlockInfo.HighlightValue)
                        {
                        FinalColor = ColorAtPixel;
                        }
                    else
                        {
                        FinalColor = float4(1.0, 1.0, 1.0, 0.0);
                        }
                    }
                break;
                }
                
                default:
                break;
            }
        ColorAtPixel = FinalColor;
        }
    
    if (BlockInfo.AddBorder)
        {
        if (gid.x % Width == 0)
            {
            ColorAtPixel = BlockInfo.BorderColor;
            }
        if (gid.y % Height == 0)
            {
            ColorAtPixel = BlockInfo.BorderColor;
            }
        }
    
    OutTexture.write(ColorAtPixel, gid);
    return;
}
