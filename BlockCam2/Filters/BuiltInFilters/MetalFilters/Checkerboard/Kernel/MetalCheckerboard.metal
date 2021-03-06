//
//  MetalCheckerboard.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/31/21.
//

#include <metal_stdlib>
using namespace metal;

struct CheckerboardParameters
{
    float4 Q1Color;
    float4 Q2Color;
    float4 Q3Color;
    float4 Q4Color;
    float BlockSize;
};


kernel void MetalCheckerboard(texture2d<float, access::read> NotUsed [[texture(0)]],
                              texture2d<float, access::write> OutTexture [[texture(1)]],
                              constant CheckerboardParameters &Checker [[buffer(0)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float4 FinalColor = float4(0.0, 0.0, 0.0, 1.0);
    
    int XCell = (int)(gid.x / Checker.BlockSize);
    int YCell = (int)(gid.y / Checker.BlockSize);
    int XQ = XCell % 2;
    int YQ = YCell % 2;
    if (XQ == 0 && YQ == 0)
        {
        //In Quadrant I
        FinalColor = Checker.Q1Color;
        }
    else
        {
        if (XQ == 1 && YQ == 0)
            {
            //In Quadrant II
            FinalColor = Checker.Q2Color;
            }
        else
            {
            if (XQ == 1 && YQ == 1)
                {
                //In Quadrant III
                FinalColor = Checker.Q3Color;
                }
            else
                {
                //In Quadrant IV.
                FinalColor = Checker.Q4Color;
                }
            }
        }
    
    OutTexture.write(FinalColor, gid);
}
