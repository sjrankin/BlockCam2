//
//  ImageDelta.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 4/28/21.
//

#include <metal_stdlib>
using namespace metal;

struct DeltaParameters
{
    float4 BackgroundColor;
    int Operation;
    float Threshold;
    bool UseEffectiveColor;
    float4 EffectiveColor;
};

kernel void ImageDelta(texture2d<float, access::read> Image1 [[texture(0)]],
                       texture2d<float, access::read> Image2 [[texture(1)]],
                       texture2d<float, access::write> OutTexture [[texture(2)]],
                       constant DeltaParameters &Parameters [[buffer(0)]],
                       device float *ToCPU [[buffer(1)]],
                       uint2 gid [[thread_position_in_grid]])
{
    float4 Color1 = Image1.read(gid);
    float4 Color2 = Image2.read(gid);
    float DeltaR = Color1.r - Color2.r;
    float DeltaG = Color1.g - Color2.g;
    float DeltaB = Color1.b - Color2.b;
    
    DeltaR = abs(DeltaR);
    DeltaG = abs(DeltaG);
    DeltaB = abs(DeltaB);
    
    switch (Parameters.Operation)
        {
            case 0:
            // only the differnt parts of the images are returned.
            if (DeltaR >= Parameters.Threshold || DeltaG >= Parameters.Threshold || DeltaB >= Parameters.Threshold)
                {
                if (Parameters.UseEffectiveColor)
                    {
                    OutTexture.write(Parameters.EffectiveColor, gid);
                    }
                else
                    {
                    OutTexture.write(float4(DeltaR, DeltaG, DeltaB, 1.0), gid);
                    }
                return;
                }
            break;
            
            case 1:
            // Only the similar parts of the images are returned.
            if (DeltaR <= Parameters.Threshold && DeltaG <= Parameters.Threshold && DeltaB <= Parameters.Threshold)
                {
                if (Parameters.UseEffectiveColor)
                    {
                    OutTexture.write(Parameters.EffectiveColor, gid);
                    }
                else
                    {
                    OutTexture.write(Color1, gid);
                    }
                }
            return;
            
            case 2:
            // Image abs difference
            OutTexture.write(float4(DeltaR, DeltaG, DeltaB, 1.0), gid);
            return;
            
            default:
            break;
        }
    OutTexture.write(Parameters.BackgroundColor, gid);
}
