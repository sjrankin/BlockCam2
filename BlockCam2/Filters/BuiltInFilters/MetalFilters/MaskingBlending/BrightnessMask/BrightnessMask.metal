//
//  BrightnessMask.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/27/21.
//

#include <metal_stdlib>
using namespace metal;

struct BrightnessMaskParameters
{
    bool Invert;
    float Trigger;
};

kernel void BrightnessMask(texture2d<float, access::read> InImage [[texture(0)]],
                            texture2d<float, access::write> OutImage [[texture(1)]],
                           constant BrightnessMaskParameters &Parameters [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    float4 InColor = InImage.read(gid);
    
    float r = InColor.r;
    float g = InColor.g;
    float b = InColor.b;
    
    float Brightness = max(r, max(g, b));
    
    if (Parameters.Invert)
        {
        if (Brightness > Parameters.Trigger)
            {
            InColor = float4(0.0, 0.0, 0.0, 0.0);
            }
        }
    else
        {
        if (Brightness < Parameters.Trigger)
            {
            InColor = float4(0.0, 0.0, 0.0, 0.0);
            }
        }
    
    OutImage.write(InColor, gid);
}
