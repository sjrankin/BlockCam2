//
//  Arithmetic_MeanB.metal
//  BlockCam2
//
//  Created by Stuart Rankin on 6/5/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void Arithmetic_Mean2B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::write> Target [[texture(2)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b) / 2.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean3B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::write> Target [[texture(3)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b) / 3.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean4B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::write> Target [[texture(4)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b + Image4.read(gid).b) / 4.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean5B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::write> Target [[texture(5)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image5.read(gid).b) / 5.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean6B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::write> Target [[texture(6)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image6.read(gid).b + Image6.read(gid).b) / 6.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean7B(texture2d<float, access::read> Image1 [[texture(0)]],
                              texture2d<float, access::read> Image2 [[texture(1)]],
                              texture2d<float, access::read> Image3 [[texture(2)]],
                              texture2d<float, access::read> Image4 [[texture(3)]],
                              texture2d<float, access::read> Image5 [[texture(4)]],
                              texture2d<float, access::read> Image6 [[texture(5)]],
                              texture2d<float, access::read> Image7 [[texture(6)]],
                              texture2d<float, access::write> Target [[texture(7)]],
                              uint2 gid [[thread_position_in_grid]])
{
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image6.read(gid).b + Image6.read(gid).b +
               Image7.read(gid).b) / 7.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean8B(texture2d<float, access::read> Image1 [[texture(0)]],
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
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image6.read(gid).b + Image6.read(gid).b +
               Image7.read(gid).b + Image8.read(gid).b) / 8.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean9B(texture2d<float, access::read> Image1 [[texture(0)]],
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
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image6.read(gid).b + Image6.read(gid).b +
               Image7.read(gid).b + Image8.read(gid).b + Image9.read(gid).b) / 9.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}

kernel void Arithmetic_Mean10B(texture2d<float, access::read> Image1 [[texture(0)]],
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
    float b = (Image1.read(gid).b + Image2.read(gid).b + Image3.read(gid).b +
               Image4.read(gid).b + Image6.read(gid).b + Image6.read(gid).b +
               Image7.read(gid).b + Image8.read(gid).b + Image9.read(gid).b +
               Image10.read(gid).b) / 10.0;
    Target.write(float4(Image1.read(gid).r, Image1.read(gid).g, b, 1.0), gid);
}




