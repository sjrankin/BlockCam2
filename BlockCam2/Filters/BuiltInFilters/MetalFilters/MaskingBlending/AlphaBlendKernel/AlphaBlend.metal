//
//  AlphaBlend.metal
//  BlockCam2
//  Adapted from BumpCamera, 3/23/19.
//
//  Created by Stuart Rankin on 4/26/21.
//

#include <metal_stdlib>
using namespace metal;


kernel void AlphaBlend(texture2d<float, access::read> BottomImage [[texture(0)]],
                       texture2d<float, access::read> TopImage [[texture(1)]],
                       texture2d<float, access::write> OutTexture [[texture(2)]],
                       device float *ToCPU [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    float4 Bottom = BottomImage.read(gid);
    float4 Top = TopImage.read(gid);
    
    float TopAlpha = 1.0 - Top.a;
    float BottomAlpha = Bottom.a;
    
    float FinalRed = (Top.r * TopAlpha) + (Bottom.r * BottomAlpha);
    float FinalGreen = (Top.g * TopAlpha) + (Bottom.g * BottomAlpha);
    float FinalBlue = (Top.b * TopAlpha) + (Bottom.b * BottomAlpha);
    
    float4 OutColor = float4(FinalRed, FinalGreen, FinalBlue, 1.0);
    OutTexture.write(OutColor, gid);
}
