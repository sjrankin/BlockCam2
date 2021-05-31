//
//  MetalPixellate.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 5/19/21.
//

import Foundation
import UIKit
import CoreMedia
import CoreVideo
import MetalKit

class MetalPixellate: MetalFilterParent, BuiltInFilterProtocol
{
    // MARK: - Required by BuiltInFilterProtocol.
    
    static var FilterType: BuiltInFilters = .MetalPixellate
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
    
    required override init()
    {
        let DefaultLibrary = MetalDevice?.makeDefaultLibrary()
        let KernelFunction = DefaultLibrary?.makeFunction(name: "PixelBlockColor")//"PixellateKernel")
        do
        {
            ComputePipelineState = try MetalDevice?.makeComputePipelineState(function: KernelFunction!)
        }
        catch
        {
            print("Unable to create pipeline state: \(error.localizedDescription)")
        }
    }
    
    private var BufferPool: CVPixelBufferPool? = nil
    
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
            print("LocalBufferPool is nil in MetalPixellate.Initialize.")
            return
        }
        InputFormatDescription = FormatDescription
        Initialized = true
        var MetalTextureCache: CVMetalTextureCache? = nil
        guard CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, MetalDevice!, nil, &MetalTextureCache) == kCVReturnSuccess else
        {
            fatalError("Unable to allocate texture cache in MetalPixellate.")
        }
        TextureCache = MetalTextureCache
    }
    
    func Reset()
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        BufferPool = nil
        OutputFormatDescription = nil
        InputFormatDescription = nil
        TextureCache = nil
        Initialized = false
    }
    
    var AccessLock = NSObject()
    
    func RunFilter0(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        if !Initialized
        {
            fatalError("Pixellate_Metal not initialized at Render(CVPixelBuffer) call.")
        }
        
        let FinalWidth = Options[.Width] as! Int
        let FinalHeight = Options[.Height] as! Int
        let HAction = Options[.Highlight] as! Int
        let HIfGreat = Options[.IsGreater] as! Bool
        let HBy = Options[.By] as! Int
        let CDet = Options[.ColorDetermination] as! Int
        let HValue = Options[.Threshold] as! Double
        let ShowBorder = Options[.ShowBorder] as! Bool
        let BorderColor = Options[.BorderColor] as! UIColor
        
        let ParameterData = BlockInfoParameters(Width: simd_uint1(FinalWidth),
                                                Height: simd_uint1(FinalHeight),
                                                HighlightAction: simd_uint1(HAction),
                                                HighlightPixelBy: simd_uint1(HBy),
                                                BrightnessHighlight: simd_uint1(0),
                                                HighlightColor: UIColor.yellow.ToFloat4(),
                                                ColorDetermination: simd_uint1(CDet),
                                                HighlightValue: simd_float1(HValue),
                                                HighlightIfGreater: simd_bool(HIfGreat),
                                                AddBorder: simd_bool(ShowBorder),
                                                BorderColor: BorderColor.ToFloat4())
        let Parameters = [ParameterData]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<BlockInfoParameters>.stride, options: [])
        memcpy(ParameterBuffer?.contents(), Parameters, MemoryLayout<BlockInfoParameters>.stride)
        
        let ResultCount = 10
        let ResultsBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ReturnBufferType>.stride * ResultCount, options: [])
        let Results = UnsafeBufferPointer<ReturnBufferType>(start: UnsafePointer(ResultsBuffer!.contents().assumingMemoryBound(to: ReturnBufferType.self)),
                                                            count: ResultCount)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for MetalPixellate.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in MetalPixellate.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in MetalPixellate.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Pixellate Metal"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder.setBuffer(ResultsBuffer, offset: 0, index: 1)
        
        let w = ComputePipelineState!.threadExecutionWidth
        let h = ComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let ThreadGroupsPerGrid = MTLSize(width: (InputTexture.width + w - 1) / w,
                                          height: (InputTexture.height + h - 1) / h,
                                          depth: 1)
        CommandEncoder.dispatchThreadgroups(ThreadGroupsPerGrid, threadsPerThreadgroup: ThreadsPerThreadGroup)
        CommandEncoder.endEncoding()
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        if (Options[.Merge] as? Bool ?? false)
        {
            let MaskFilter = Masking1()
            MaskFilter.Initialize(With: InputFormatDescription!, BufferCountHint: 3)
            OutputBuffer = MaskFilter.RenderWith(PixelBuffer: Buffer, And: OutputBuffer)!
        }
        
        return OutputBuffer
    }
    
    func RunFilter(_ Buffer: [CVPixelBuffer], _ BufferPool: CVPixelBufferPool,
                   _ ColorSpace: CGColorSpace, Options: [FilterOptions: Any]) -> CVPixelBuffer
    {
        objc_sync_enter(AccessLock)
        defer{objc_sync_exit(AccessLock)}
        if !Initialized
        {
            fatalError("Pixellate_Metal not initialized at Render(CVPixelBuffer) call.")
        }
        
        let FinalWidth = Options[.Width] as! Int
        let FinalHeight = Options[.Height] as! Int
        let HAction = Options[.Highlight] as! Int
        let HIfGreat = Options[.IsGreater] as! Bool
        let HBy = Options[.By] as! Int
        let CDet = Options[.ColorDetermination] as! Int
        let HValue = Options[.Threshold] as! Double
        let ShowBorder = Options[.ShowBorder] as! Bool
        let BorderColor = Options[.BorderColor] as! UIColor
        
        let ParameterData = BlockInfoParameters(Width: simd_uint1(FinalWidth),
                                                Height: simd_uint1(FinalHeight),
                                                HighlightAction: simd_uint1(HAction),
                                                HighlightPixelBy: simd_uint1(HBy),
                                                BrightnessHighlight: simd_uint1(0),
                                                HighlightColor: UIColor.yellow.ToFloat4(),
                                                ColorDetermination: simd_uint1(CDet),
                                                HighlightValue: simd_float1(HValue),
                                                HighlightIfGreater: simd_bool(HIfGreat),
                                                AddBorder: simd_bool(ShowBorder),
                                                BorderColor: BorderColor.ToFloat4())
        let Parameters = [ParameterData]
        ParameterBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<BlockInfoParameters>.stride, options: [])
        memcpy(ParameterBuffer?.contents(), Parameters, MemoryLayout<BlockInfoParameters>.stride)
        
        let BWidth = CVPixelBufferGetWidth(Buffer.first!)
        let BHeight = CVPixelBufferGetHeight(Buffer.first!)
        let HBlockCount = BWidth / FinalWidth
        let VBlockCount = BHeight / FinalHeight
        let ResultCount = HBlockCount * VBlockCount
        let ResultsBuffer = MetalDevice!.makeBuffer(length: MemoryLayout<ColorReturnType>.stride * ResultCount, options: [])
        let Results = UnsafeBufferPointer<ColorReturnType>(start: UnsafePointer(ResultsBuffer!.contents().assumingMemoryBound(to: ColorReturnType.self)),
                                                            count: ResultCount)
        
        super.CreateBufferPool(Source: CIImage(cvPixelBuffer: Buffer.first!), From: Buffer.first!)
        var NewPixelBuffer: CVPixelBuffer? = nil
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, super.BasePool!, &NewPixelBuffer)
        guard var OutputBuffer = NewPixelBuffer else
        {
            fatalError("Error creation textures for MetalPixellate.")
        }
        
        guard let InputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: Buffer.first!, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating input texture in MetalPixellate.")
        }
        
        guard let OutputTexture = MakeTextureFromCVPixelBuffer(PixelBuffer: OutputBuffer, TextureFormat: .bgra8Unorm) else
        {
            Debug.FatalError("Error creating output texture in MetalPixellate.")
        }
        
        guard let CommandQ = CommandQueue,
              let CommandBuffer = CommandQ.makeCommandBuffer(),
              let CommandEncoder = CommandBuffer.makeComputeCommandEncoder() else
        {
            Debug.FatalError("Error creating Metal command queue.")
        }
        
        CommandEncoder.label = "Pixellate Metal"
        CommandEncoder.setComputePipelineState(ComputePipelineState!)
        CommandEncoder.setTexture(InputTexture, index: 0)
        CommandEncoder.setTexture(OutputTexture, index: 1)
        CommandEncoder.setBuffer(ParameterBuffer, offset: 0, index: 0)
        CommandEncoder.setBuffer(ResultsBuffer, offset: 0, index: 1)
        
        let w = ComputePipelineState!.threadExecutionWidth
        let h = ComputePipelineState!.maxTotalThreadsPerThreadgroup / w
        let ThreadsPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let ThreadGroupsPerGrid = MTLSize(width: (InputTexture.width + w - 1) / w,
                                          height: (InputTexture.height + h - 1) / h,
                                          depth: 1)
        CommandEncoder.dispatchThreadgroups(ThreadGroupsPerGrid, threadsPerThreadgroup: ThreadsPerThreadGroup)
        CommandEncoder.endEncoding()
        CommandBuffer.commit()
        CommandBuffer.waitUntilCompleted()
        
        if (Options[.Merge] as? Bool ?? false)
        {
            let MaskFilter = Masking1()
            MaskFilter.Initialize(With: InputFormatDescription!, BufferCountHint: 3)
            OutputBuffer = MaskFilter.RenderWith(PixelBuffer: Buffer, And: OutputBuffer)!
        }
        
        var Colors = [UIColor]()
        for RawResult in Results
        {
            let SomeColor = UIColor.From(Float4: RawResult)
            Colors.append(SomeColor)
        }
        
        return OutputBuffer
    }
    
    static func ResetFilter()
    {
        Settings.SetInt(.MetalPixWidth, Settings.SettingDefaults[.MetalPixWidth] as! Int)
        Settings.SetInt(.MetalPixHeight, Settings.SettingDefaults[.MetalPixHeight] as! Int)
        Settings.SetInt(.MetalPixColorDetermination,
                        Settings.SettingDefaults[.MetalPixColorDetermination] as! Int)
        Settings.SetBool(.MetalPixMergeImage,
                         Settings.SettingDefaults[.MetalPixMergeImage] as! Bool)
        Settings.SetInt(.MetalPixHighlightPixel,
                        Settings.SettingDefaults[.MetalPixHighlightPixel] as! Int)
        Settings.SetDouble(.MetalPixThreshold,
                           Settings.SettingDefaults[.MetalPixThreshold] as! Double)
        Settings.SetBool(.MetalPixShowBorder,
                         Settings.SettingDefaults[.MetalPixShowBorder] as! Bool)
        Settings.SetBool(.MetalPixInvertThreshold,
                         Settings.SettingDefaults[.MetalPixInvertThreshold] as! Bool)
        Settings.SetColor(.MetalPixBorderColor,
                          Settings.SettingDefaults[.MetalPixBorderColor] as! UIColor)
    }
}
