//
//  TrailingFramesFadeOut.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 5/29/21.
//

#include <metal_stdlib>
using namespace metal;


struct TrailingFramesParameters
{
    uint FrameCount;
};

kernel void TrailingFramesReduceAlpha(texture2d<float, access::read> Texture0 [[texture(0)]],
                                      texture2d<float, access::read> Texture1 [[texture(1)]],
                                      texture2d<float, access::read> Texture2 [[texture(2)]],
                                      texture2d<float, access::read> Texture3 [[texture(3)]],
                                      texture2d<float, access::read> Texture4 [[texture(4)]],
                                      texture2d<float, access::read> Texture5 [[texture(5)]],
                                      texture2d<float, access::read> Texture6 [[texture(6)]],
                                      texture2d<float, access::read> Texture7 [[texture(7)]],
                                      texture2d<float, access::read> Texture8 [[texture(8)]],
                                      texture2d<float, access::read> Texture9 [[texture(9)]],
                                      texture2d<float, access::write> OutTexture [[texture(10)]],
                                      constant TrailingFramesParameters &Parameters [[buffer(0)]],
                                      uint2 gid [[thread_position_in_grid]])
{
    if (Parameters.FrameCount < 2)
        {
        float4 Final = Texture0.read(gid);
        OutTexture.write(Final, gid);
        return;
        }
    
    float AlphaInterval = 1.0 / Parameters.FrameCount;
    float4 Frame0 = Texture0.read(gid);
    
    if (Parameters.FrameCount <= 2)
        {
        float4 Frame1 = Texture1.read(gid);
        float TopAlpha = 1.0 - AlphaInterval;
        float BottomAlpha = Frame0.a;
        float R = (Frame1.r * TopAlpha) + (Frame0.r * BottomAlpha);
        float G = (Frame1.g * TopAlpha) + (Frame0.g * BottomAlpha);
        float B = (Frame1.b * TopAlpha) + (Frame0.b * BottomAlpha);
        float4 Final = float4(R, G, B, 1.0);
        OutTexture.write(Final, gid);
        return;
        }
    
    if (Parameters.FrameCount <= 3)
        {
        float4 Frame1 = Texture1.read(gid);
        float TopAlpha = 1.0 - (AlphaInterval * 2.0);
        float BottomAlpha = Frame0.a;
        float R = (Frame1.r * TopAlpha) + (Frame0.r * BottomAlpha);
        float G = (Frame1.g * TopAlpha) + (Frame0.g * BottomAlpha);
        float B = (Frame1.b * TopAlpha) + (Frame0.b * BottomAlpha);
        Frame1 = float4(R, G, B, 1.0);
        
        float4 Frame2 = Texture2.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 1.0);
        BottomAlpha = Frame2.a;
        R = (Frame2.r * TopAlpha) + (Frame1.r * BottomAlpha);
        G = (Frame2.g * TopAlpha) + (Frame1.g * BottomAlpha);
        B = (Frame2.b * TopAlpha) + (Frame1.b * BottomAlpha);
        
        float4 Final = float4(R, G, B, 1.0);
        OutTexture.write(Final, gid);
        return;
        }
    
    if (Parameters.FrameCount <= 4)
        {
        float4 Frame1 = Texture1.read(gid);
        float TopAlpha = 1.0 - (AlphaInterval * 3.0);
        float BottomAlpha = Frame0.a;
        float R = (Frame1.r * TopAlpha) + (Frame0.r * BottomAlpha);
        float G = (Frame1.g * TopAlpha) + (Frame0.g * BottomAlpha);
        float B = (Frame1.b * TopAlpha) + (Frame0.b * BottomAlpha);
        Frame1 = float4(R, G, B, 1.0);
        
        float4 Frame2 = Texture2.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 2.0);
        BottomAlpha = Frame2.a;
        R = (Frame2.r * TopAlpha) + (Frame1.r * BottomAlpha);
        G = (Frame2.g * TopAlpha) + (Frame1.g * BottomAlpha);
        B = (Frame2.b * TopAlpha) + (Frame1.b * BottomAlpha);
        Frame2 = float4(R, G, B, 1.0);
        
        float4 Frame3 = Texture3.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 1.0);
        BottomAlpha = Frame3.a;
        R = (Frame3.r * TopAlpha) + (Frame2.r * BottomAlpha);
        G = (Frame3.g * TopAlpha) + (Frame2.g * BottomAlpha);
        B = (Frame3.b * TopAlpha) + (Frame2.b * BottomAlpha);
        
        float4 Final = float4(R, G, B, 1.0);
        OutTexture.write(Final, gid);
        return;
        }
    
    if (Parameters.FrameCount <= 5)
        {
        float4 Frame1 = Texture1.read(gid);
        float TopAlpha = 1.0 - (AlphaInterval * 4.0);
        float BottomAlpha = Frame0.a;
        float R = (Frame1.r * TopAlpha) + (Frame0.r * BottomAlpha);
        float G = (Frame1.g * TopAlpha) + (Frame0.g * BottomAlpha);
        float B = (Frame1.b * TopAlpha) + (Frame0.b * BottomAlpha);
        Frame1 = float4(R, G, B, 1.0);
        
        float4 Frame2 = Texture2.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 2.0);
        BottomAlpha = Frame2.a;
        R = (Frame2.r * TopAlpha) + (Frame1.r * BottomAlpha);
        G = (Frame2.g * TopAlpha) + (Frame1.g * BottomAlpha);
        B = (Frame2.b * TopAlpha) + (Frame1.b * BottomAlpha);
        Frame2 = float4(R, G, B, 1.0);
        
        float4 Frame3 = Texture3.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 2.0);
        BottomAlpha = Frame3.a;
        R = (Frame3.r * TopAlpha) + (Frame2.r * BottomAlpha);
        G = (Frame3.g * TopAlpha) + (Frame2.g * BottomAlpha);
        B = (Frame3.b * TopAlpha) + (Frame2.b * BottomAlpha);
        Frame3 = float4(R, G, B, 1.0);
        
        float4 Frame4 = Texture4.read(gid);
        TopAlpha = 1.0 - (AlphaInterval * 1.0);
        BottomAlpha = Frame4.a;
        R = (Frame4.r * TopAlpha) + (Frame3.r * BottomAlpha);
        G = (Frame4.g * TopAlpha) + (Frame3.g * BottomAlpha);
        B = (Frame4.b * TopAlpha) + (Frame3.b * BottomAlpha);
        
        float4 Final = float4(R, G, B, 1.0);
        OutTexture.write(Final, gid);
        return;
        }
    
    OutTexture.write(float4(1.0 - Frame0.r, 1.0 - Frame0.g, 1.0 - Frame0.b, 1.0), gid);
}
