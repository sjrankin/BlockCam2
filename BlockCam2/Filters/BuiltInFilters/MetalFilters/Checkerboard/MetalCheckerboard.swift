//
//  MetalCheckerboard.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/31/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class MetalCheckerboard: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .MetalCheckerboard
    var NeedsInitialization: Bool = true
    
    // MARK: - Class variables.
    
    private let MetalDevice = MTLCreateSystemDefaultDevice()
    private var ComputePipelineState: MTLComputePipelineState? = nil
    private lazy var CommandQueue: MTLCommandQueue? =
        {
            return self.MetalDevice?.makeCommandQueue()
        }()
    private(set) var OutputFormatDescription: CMFormatDescription? = nil
    private(set) var InputFormatDescription: CMFormatDescription? = nil
    private var LocalBufferPool: CVPixelBufferPool? = nil
    var Initialized = false
    var ParameterBuffer: MTLBuffer! = nil
    var AccessLock = NSObject()
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "MetalCheckerboard")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }
    
    func Initialize(With FormatDescription: CMFormatDescription, BufferCountHint: Int)
    {
        if Initialized
        {
            return
        }
        
        Reset()
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription,
                                                                         BufferCountHint: BufferCountHint)
        guard LocalBufferPool != nil else
        {
            Debug.FatalError("LocalBufferPool is nil in MetalCheckerboard.Initialize.")
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            Debug.FatalError("Unable to allocate texture cache in MetalCheckerboard.")
        }
        TextureCache = MetalTextureCache
    }
    
    func Initialize(From Image: UIImage, BufferCountHint: Int)
    {
        if Initialized
        {
            return
        }
        Reset()
        /*
        let ImageFormat = Image.PixelBuffer()
        guard let FormatDescription = FilterHelper.GetFormatDescription(From: ImageFormat) else
        {
            Debug.FatalError("Error getting format description in MetalCheckerboard.Initial(From).")
        }
        (LocalBufferPool, _, OutputFormatDescription) = CreateBufferPool(From: FormatDescription,
                                                                         BufferCountHint: 3)
        guard LocalBufferPool != nil else
        {
            Debug.FatalError("LocalBufferPool is nil in MetalCheckerboard.Initialize(From).")
        }
        InputFormatDescription = FormatDescription
 */
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            Debug.FatalError("Unable to allocate texture cache in MetalCheckerboard.")
        }
        TextureCache = MetalTextureCache
    }
    
    func Reset()
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        LocalBufferPool = nil
        OutputFormatDescription = nil
        InputFormatDescription = nil
        TextureCache = nil
        Initialized = false
    }

    /// Returns the generated image. If the filter does not support generated images nil is returned.
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        if !Initialized
        {
            Debug.FatalError("Not initialized.")
        }
        
        let IWidth = Options[.Width] as! Int
        let IHeight = Options[.Height] as! Int
        
        // A dummy image is needed to drive the kernel for each pixel for the resultant image.
        var DummyImage: UIImage!
        if let duImage = UIImage.MakeColorImage(SolidColor: UIColor.red, Size: CGSize(width: IWidth, height: IHeight))
        {
            DummyImage = duImage
        }
        else
        {
            Debug.FatalError("Error returned by MakeColorImage.")
        }
        
        var DummyTexture: MTLTexture!
        if let DummyBuffer = GetPixelBufferFrom(DummyImage)
        {
            DummyTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: DummyBuffer, TextureFormat: .bgra8Unorm)
        }
        else
        {
            Debug.FatalError("Error returned by GetPixelBufferFrom")
        }
        
        let TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: Int(IWidth), height: Int(IHeight), mipmapped: true)
        guard let InputTexture = MetalDevice?.makeTexture(descriptor: TextureDescriptor) else
        {
            Debug.FatalError("Error creating input texture in MetalCheckerboard.")
        }
        /*
        let Region = MTLRegionMake2D(0, 0, Int(IWidth), Int(IHeight))
        var RawData = [UInt8](repeating: 0, count: Int(IWidth * IHeight * 4))
        let IBytesPerRow = 4 * IWidth
        InputTexture.replace(region: Region, mipmapLevel: 0, withBytes: &RawData, bytesPerRow: IBytesPerRow)
        let OutputTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: InputTexture.pixelFormat,
                                                                               width: InputTexture.width,
                                                                               height: InputTexture.height,
                                                                               mipmapped: true)
        OutputTextureDescriptor.usage = MTLTextureUsage.shaderWrite
        let OutputTexture = MetalDevice?.makeTexture(descriptor: OutputTextureDescriptor)
        */
        let DummyBuffer = DummyImage!.PixelBuffer()
        super.CreateBufferPool(Source: CIImage(image: DummyImage!)!, From: DummyBuffer)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating output buffer for MetalCheckerboard")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in MetalCheckerboard")
        }
        
        let CommandBuffer = CommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ComputePipelineState!)
        CommandEncoder?.setTexture(DummyTexture, index: 0)
        CommandEncoder?.setTexture(OutputTexture, index: 1)
        
        let C1 = Options[.Color0] as! UIColor
        let C2 = Options[.Color1] as! UIColor
        let C3 = Options[.Color2] as! UIColor
        let C4 = Options[.Color3] as! UIColor
        let BlockSize = Options[.Size] as! Double
        
        let Parameter = CheckerboardParameters(Q1Color: C1.ToFloat4(),
                                               Q2Color: C2.ToFloat4(),
                                               Q3Color: C3.ToFloat4(),
                                               Q4Color: C4.ToFloat4(),
                                               BlockSize: simd_float1(BlockSize))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<CheckerboardParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<CheckerboardParameters>.stride)
        
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let ThreadGroupCount  = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(InputTexture.width / ThreadGroupCount.width,
                                       InputTexture.height / ThreadGroupCount.height,
                                       1)
        
        CommandQueue = MetalDevice?.makeCommandQueue()
        
        CommandEncoder!.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder!.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    /// Returns the generated image. If the filter does not support generated images nil is returned.
    func RunFilter2(Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        let IWidth = Options[.Width] as! Int
        let IHeight = Options[.Height] as! Int
        
        // A dummy image is needed to drive the kernel for each pixel for the resultant image.
        var DummyImage: UIImage!
        if let duImage = UIImage.MakeColorImage(SolidColor: UIColor.red, Size: CGSize(width: IWidth, height: IHeight))
        {
            DummyImage = duImage
        }
        else
        {
            Debug.FatalError("Error returned by MakeColorImage.")
        }
        
        var DummyTexture: MTLTexture!
        if let DummyBuffer = GetPixelBufferFrom(DummyImage)
        {
            DummyTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: DummyBuffer, TextureFormat: .bgra8Unorm)
        }
        else
        {
            Debug.FatalError("Error returned by GetPixelBufferFrom")
        }
        
        let TextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                                         width: Int(IWidth),
                                                                         height: Int(IHeight),
                                                                         mipmapped: true)
        guard let InputTexture = MetalDevice?.makeTexture(descriptor: TextureDescriptor) else
        {
            Debug.FatalError("Error creating input texture in MetalCheckerboard.")
        }
 
        let DummyBuffer = DummyImage!.PixelBuffer()
        super.CreateBufferPool(Source: CIImage(image: DummyImage!)!, From: DummyBuffer)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard let OutputBuffer = NewPixelBuffer else
        {
            Debug.FatalError("Error creating output buffer for MetalCheckerboard")
        }
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in MetalCheckerboard")
        }
        
        let CommandBuffer = CommandQueue?.makeCommandBuffer()
        let CommandEncoder = CommandBuffer?.makeComputeCommandEncoder()
        
        CommandEncoder?.setComputePipelineState(ComputePipelineState!)
        CommandEncoder?.setTexture(DummyTexture, index: 0)
        CommandEncoder?.setTexture(OutputTexture, index: 1)
        
        let C1 = Options[.Color0] as! UIColor
        let C2 = Options[.Color1] as! UIColor
        let C3 = Options[.Color2] as! UIColor
        let C4 = Options[.Color3] as! UIColor
        let BlockSize = Options[.Size] as! Int
        
        let Parameter = CheckerboardParameters(Q1Color: C1.ToFloat4(),
                                               Q2Color: C2.ToFloat4(),
                                               Q3Color: C3.ToFloat4(),
                                               Q4Color: C4.ToFloat4(),
                                               BlockSize: simd_float1(BlockSize))
        let Parameters = [Parameter]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<CheckerboardParameters>.stride, options: [])
        memcpy(ParameterBuffer.contents(), Parameters, MemoryLayout<CheckerboardParameters>.stride)
        
        CommandEncoder?.setBuffer(ParameterBuffer, offset: 0, index: 0)
        
        let ThreadGroupCount  = MTLSizeMake(8, 8, 1)
        let ThreadGroups = MTLSizeMake(InputTexture.width / ThreadGroupCount.width,
                                       InputTexture.height / ThreadGroupCount.height,
                                       1)
        
        CommandQueue = MetalDevice?.makeCommandQueue()
        
        CommandEncoder!.dispatchThreadgroups(ThreadGroups, threadsPerThreadgroup: ThreadGroupCount)
        CommandEncoder!.endEncoding()
        CommandBuffer?.commit()
        CommandBuffer?.waitUntilCompleted()
        
        return OutputBuffer
    }
    
    public func MakeCheckerboard(Options: [FilterOptions: Any]) -> UIImage
    {
        let PixelBuffer = RunFilter([CVPixelBuffer](), LocalBufferPool!, CGColorSpaceCreateDeviceRGB(),
                                    Options: Options)
        guard let Final = UIImage(Buffer: PixelBuffer) else
        {
            Debug.FatalError("Error converting pixel buffer to UIImage.")
        }
        return Final
    }
    
    public static func Generate(Block: Int, Width: Int, Height: Int,
                                        Color0: UIColor, Color1: UIColor,
                                        Color2: UIColor, Color3: UIColor) -> UIImage
    {
        let Instance = MetalCheckerboard()
        Instance.Initialize(From: UIImage.MakeColorImage(SolidColor: UIColor(red: 0.35, green: 0.93, blue: 0.44, alpha: 1.0),
                                                         Size: CGSize(width: Width, height: Height))!,
                            BufferCountHint: 3)
        let Options: [FilterOptions: Any] =
        [
            .Color0: Color0 as Any,
            .Color1: Color1 as Any,
            .Color2: Color2 as Any,
            .Color3: Color3 as Any,
            .Size: Block as Any,
            .Width: Width as Any,
            .Height: Height as Any,
        ]
        let GeneratedBuffer = Instance.RunFilter2(Options: Options)
        guard let Result = UIImage(Buffer: GeneratedBuffer) else
        {
            Debug.FatalError("Error creating final image in MetalCheckerboard.Generated")
        }
        return Result
    }
    
    static func ResetFilter()
    {
        Settings.SetInt(.MCheckerCheckSize, Settings.SettingDefaults[.MCheckerCheckSize] as! Int)
        Settings.SetInt(.MCheckerWidth, Settings.SettingDefaults[.MCheckerWidth] as! Int)
        Settings.SetInt(.MCheckerHeight, Settings.SettingDefaults[.MCheckerHeight] as! Int)
        Settings.SetColor(.MCheckerColor0, Settings.SettingDefaults[.MCheckerColor0] as! UIColor)
        Settings.SetColor(.MCheckerColor1, Settings.SettingDefaults[.MCheckerColor1] as! UIColor)
        Settings.SetColor(.MCheckerColor2, Settings.SettingDefaults[.MCheckerColor2] as! UIColor)
        Settings.SetColor(.MCheckerColor3, Settings.SettingDefaults[.MCheckerColor3] as! UIColor)
    }
}
