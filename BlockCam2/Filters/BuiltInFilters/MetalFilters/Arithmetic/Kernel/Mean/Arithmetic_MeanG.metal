//
//  Arithmetic_MeanG.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/5/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void Arithmetic_Mean2G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::write> Target [[texture(2)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g) / 2.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean3G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::write> Target [[texture(3)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g) / 3.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean4G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::write> Target [[texture(4)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g + Image4.read(gid).g) / 4.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean5G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::write> Target [[texture(5)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g) / 5.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean6G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::write> Target [[texture(6)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g + Image6.read(gid).g) / 6.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean7G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::read> Image7 [[texture(6)]],
                              texture2d<float, access::write> Target [[texture(7)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g + Image6.read(gid).g +
               Image7.read(gid).g) / 7.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean8G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::read> Image7 [[texture(6)]],
                              texture2d<float, access::read> Image8 [[texture(7)]],
                              texture2d<float, access::write> Target [[texture(8)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g + Image6.read(gid).g +
               Image7.read(gid).g + Image8.read(gid).g) / 8.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean9G(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::read> Image7 [[texture(6)]],
                              texture2d<float, access::read> Image8 [[texture(7)]],
                              texture2d<float, access::read> Image9 [[texture(8)]],
                              texture2d<float, access::write> Target [[texture(9)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g + Image6.read(gid).g +
               Image7.read(gid).g + Image8.read(gid).g + Image9.read(gid).g) / 9.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}

kernel void Arithmetic_Mean10G(texture2d<float, access::read> Image1 [[texture(0)]],
                               texture2d<float, access::read> Image2 [[texture(1)]],
                               texture2d<float, access::read> Image3 [[texture(2)]],
                               texture2d<float, access::read> Image4 [[texture(3)]],
                               texture2d<float, access::read> Image5 [[texture(4)]],
                               texture2d<float, access::read> Image6 [[texture(5)]],
                               texture2d<float, access::read> Image7 [[texture(6)]],
                               texture2d<float, access::read> Image8 [[texture(7)]],
                               texture2d<float, access::read> Image9 [[texture(8)]],
                               texture2d<float, access::read> Image10 [[texture(9)]],
                               texture2d<float, access::write> Target [[texture(10)]],
                               uint2 gid [[thread_position_in_grid]])
{
    float g = (Image1.read(gid).g + Image2.read(gid).g + Image3.read(gid).g +
               Image4.read(gid).g + Image5.read(gid).g + Image6.read(gid).g +
               Image7.read(gid).g + Image8.read(gid).g + Image9.read(gid).g +
               Image10.read(gid).g) / 10.0;
    Target.write(float4(Image1.read(gid).r, g, Image1.read(gid).b, 1.0), gid);
}




