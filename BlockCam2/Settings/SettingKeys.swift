//
//  SettingKeys.swift
//  BlockCam2
//  Adapted from FlatlandView, 5/24/20.
//
//  Created by Stuart Rankin on 4/27/21.
//

import Foundation

/// Settings. Each case refers to a single setting and is used
/// by the settings class to access the setting.
enum SettingKeys: String, CaseIterable
{
    // MARK: - Infrastructure/initialization-related settings.
    /// Boolean: Settings initialized flag
    case InitializationFlag = "InitializationFlag"
    /// String: Instance ID.
    case InstanceID = "InstanceID"
    
    // MARK: - Audio settings.
    /// Boolean: If true, audio waveforms are shown overlayed the image.
    case ShowAudioWaveform = "ShowAudioWaveform"
    
    // MARK: - Camera and image general settings.
    /// Boolean: If true, the original image is saved along with the modified image.
    case SaveOriginalImage = "SaveOriginalImage"
    /// Integer: Index of the input source (0 = camera, 1 = photo album).
    case InputSourceIndex = "InputSourceIndex"
    
    // MARK: - Sample image settings
    /// Integer: Index of the sample image.
    case SampleImageIndex = "SampleImageIndex"
    /// Boolean: Use the latest BlockCam image as a sample image.
    case UseLatestBlockCamImage = "UseLatestBlockCamImage"
    /// Boolean: Use the latest taken image in the photo album as a sample image.
    case UseMostRecentImage = "UseMostRecentImage"
    /// Boolean: If available, only use user-provided samples.
    case ShowUserSamplesOnlyIfAvailable = "ShowUserSamplesOnlyIfAvailable"
    /// String: List of user sample images.
    case UserSampleList = "UserSampleList"
    /// Boolean: If true use user samples for the set of sample images.
    case UseSampleImages = "UseSampleImages"
    /// Integer: Used for previews of sub-sample images.
    case SubSampleScratchKey = "SubSampleScratchKey"
    /// String: Name of the filter used on the sample image.
    case SampleImageFilter = "SampleImageFilter"
    /// Integer: Index of type of sample image background.
    case SampleImageBackground = "SampleImageBackground"
    
    // MARK: - Filter settings.
    /// String: Current filter in use.
    case CurrentFilter = "CurrentFilter"
    /// String: Current group in which the current filter resides.
    case CurrentGroup = "CurrentGroup"
    /// Integer: Which filter list to display.
    case FilterListDisplay = "FilterListDisplay"
    
    // MARK: - Hue Adjust
    /// Double: The angle of the hue for Hue Adjust
    case HueAngle = "HueAngle"
    
    // MARK: - Kaleidoscope
    /// Int: Number of segments for the kaleidoscope.
    case KaleidoscopeSegmentCount = "KaleidoscopeSegmentCount"
    /// Int: Angle of reflection for the kaleidoscope.
    case KaleidoscopeAngleOfReflection = "KaleidoscopeAngleOfReflection"
    /// Bool: If true, the background is filled in with a solid color.
    case KaleidoscopeFillBackground = "KaleidoscopeFillBackground"
    
    // MARK: - Triangular Kaleidoscope
    /// Double: Angle of rotation.
    case Kaleidoscope3Rotation = "Kaleidoscope3Rotation"
    /// Double: Size of triangles.
    case Kaleidoscope3Size = "Kaleidoscope3Size"
    /// Double: Color decay from center to edge.
    case Kaleidoscope3Decay = "Kaleidoscope3Decay"
    
    // MARK: - Mirroring
    /// Int: Determines how mirroring occurs: 0 = horizontally (controlled
    /// by `MirrorLeft`), 1 = vertically (controlled by `MirrorTop`),
    /// 2 = mirror by quadrants (controlled by `MirrorQuadrant`).
    case MirrorDirection = "MirrorDirection"
    /// Boolean: If true, the left side is mirrored to the right.
    /// if false, the right side is mirrored to the left.
    case MirrorLeft = "MirrorLeft"
    /// Boolean: If true, the top side is mirrored to the bottom. If
    /// false, the bottom side is mirrored to the top.
    case MirrorTop = "MirrorTop"
    /// Int: Determines which quadrant is mirrored.
    case MirrorQuadrant = "MirrorQuadrant"
    /// Bool: If true, quadrants are rotated by 180°.
    case QuadrantsRotated = "QuadrantsRotated"
    
    // MARK: - Color map
    /// String: Gradient description to use with the color map.
    case ColorMapGradient = "ColorMapGradient"
    /// UIColor: Top-most color for the color map.
    case ColorMapColor1 = "ColorMapColor1"
    /// UIColor: Bottom-most color for the color map.
    case ColorMapColor2 = "ColorMapColor2"
    
    // MARK: - Color monochrome
    /// UIColor: Color for the color monochrome filter.
    case ColorMonochromeColor = "ColorMonochromeColor"
    
    // MARK: - Bump distortion
    /// Double: Radius of the bump distortion.
    case BumpDistortionRadius = "BumpDistorionRadius"
    /// Double: Scale of the bump distortion.
    case BumpDistortionScale = "BumpDistortionScale"
    
    // MARK: - Color controls
    /// Double: Brightness value.
    case ColorControlsBrightness = "ColorControlsBrightness"
    /// Double: Contrast value.
    case ColorControlsContrast = "ColorControlsContrast"
    /// Double: Saturation value.
    case ColorControlsSaturation = "ColorControlsSaturation"
    
    // MARK: - HSB settings
    /// Double: Multiplier for hue.
    case HSBHueValue = "HSBHueValue"
    /// Double: Multiplier for Saturation.
    case HSBSaturationValue = "HSBSaturationValue"
    /// Double: Multiplier for brightness.
    case HSBBrightnessValue = "HSBBrightnessValue"
    /// Boolean: If true, brightness will be changed.
    case HSBChangeBrightness = "HSBChangeBrightness"
    /// Boolean: If true, saturation will be changed.
    case HSBChangeSaturation = "HSBChangeSaturation"
    /// Boolean: If true, hue will be changed.
    case HSBChangeHue = "HSBChangeHue"
    
    // MARK: - Circle splash distortion
    /// Double: Radius of the circle splash distortion effect.
    case CircleSplashDistortionRadius = "CircleSplashDistortionRadius"
    
    // MARK: - Vibrance settings
    /// Double: Amount to apply to the vibrance filter.
    case VibranceAmount = "VibranceAmount"
    
    // MARK: - CMYK halftone settings
    /// Double: Width of a halftone cell.
    case CMYKHalftoneWidth = "CMYKHalftoneWidth"
    /// Double: Sharpness of halftone processing.
    case CMYKHalftoneSharpness = "CMYKHalftoneSharpness"
    /// Double: Halftone angle.
    case CMYKHalftoneAngle = "CMYKHalftoneAngle"
    
    // MARK: - Dither filter settings
    /// Double: Intensity of the dithering.
    case DitherIntensity = "DitherIntensity"
    
    // MARK: - Dot screen settings
    /// Double: Width of a dot screen cell.
    case DotScreenWidth = "DotScreenWidth"
    /// Double: Sharpness of dot screen processing.
    case DotScreenSharpness = "DotScreenSharpness"
    /// Double: Halftone dot screen.
    case DotScreenAngle = "DotScreenAngle"
    
    // MARK: - Droste settings
    /// Double: Number of strands for the filter.
    case DrosteStrands = "DrosteStrands"
    /// Double: Periodicity for the filter.
    case DrostePeriodicity = "DrostePeriodicity"
    /// Double: Rotational value for the filter.
    case DrosteRotation = "DrosteRotation"
    /// Double: Zoom level for the filter.
    case DrosteZoom = "DrosteZoom"
    
    // MARK: - Edges settings
    /// Double: Intensity for the edges filter.
    case EdgesIntensity = "EdgesIntensity"
    
    // MARK: - Exposure value settings
    /// Double: Exposure setting value.
    case ExposureValue = "ExposureValue"
    
    // MARK: - Unsharp settings
    /// Double: Intensity of the unsharp mask.
    case UnsharpIntensity = "UnsharpIntensity"
    /// Double: Radius of the unsharp mask.
    case UnsharpRadius = "UnsharpRadius"
    
    // MARK: - Twirl distortion
    /// Double: Radius of the twirl.
    case TwirlRadius = "TwirlRadius"
    /// Double: Angle of the twirl.
    case TwirlAngle = "TwirlAngle"
    
    // MARK: - Sepia
    /// Double: Intensity of the sepia filter.
    case SepiaIntensity = "SepiaIntensity"
    
    // MARK: - EdgeWork settings
    /// Double: Thickness of the edges
    case EdgeWorkThickness = "EdgeWorkThickness"
    
    // MARK: - Threshold filter settings
    /// Double: Value at which high colors become active.
    case ThresholdValue = "ThresholdValue"
    /// Boolean: Essentially switches the low and high colors.
    case ThresholdApplyIfGreater = "ThresholdApplyIfGreater"
    /// Integer: The channel to use for the threshold.
    case ThresholdInputChannel = "ThresholdInputChannel"
    /// UIColor: The color to use for areas below the threshold
    case ThresholdLowColor = "ThresholdLowColor"
    /// UIColor: The color to use for areas above the threshold.
    case ThresholdHighColor = "ThresholdHighColor"
    
    // MARK: - Convolution filter settings
    /// Double: Bias value
    case ConvolutionBias = "ConvolutionBias"
    /// String: Kernel of doubles stored as an array.
    case ConvolutionKernel = "Convolutionkernel"
    /// Integer: Width of the convolution kernel.
    case ConvolutionWidth = "ConvolutionWidth"
    /// Integer: Height of the convolution kernel.
    case ConvolutionHeight = "ConvolutionHeight"
    /// Integer: Index of the pre-defined convolution kernel.
    case ConvolutionPredefinedKernel = "ConvolutionPredefinedKernel"

    // MARK: - Metal grayscale filter
    /// Integer: Command ID
    case GrayscaleMetalCommand = "GrayscaleMetalCommand"
    /// Double: Red channel multiplier.
    case GrayscaleRedMultiplier = "GrayscaleRedMultiplier"
    /// Double: Green channel multiplier.
    case GrayscaleGreenMultiplier = "GrayscaleGreenMultiplier"
    /// Double: Blue channel multiplier.
    case GrayscaleBlueMultiplier = "GrayscelBlueMultiplier"
    
    // MARK: - Metal color inverter
    /// Integer: Which color inversion method to use.
    case ColorInverterColorSpace = "ColorInverterColorSpace"
    /// Boolean: Invert channel 1.
    case ColorInverterInvertChannel1 = "ColorInverterInvertChannel1"
    /// Boolean: Invert channel 2.
    case ColorInverterInvertChannel2 = "ColorInverterInvertChannel2"
    /// Boolean: Invert channel 3.
    case ColorInverterInvertChannel3 = "ColorInverterInvertChannel3"
    /// Boolean: Invert channel 4.
    case ColorInverterInvertChannel4 = "ColorInverterInvertChannel4"
    /// Boolean: Enable channel 1 threshold.
    case ColorInverterEnableChannel1Threshold = "ColorInverterEnableChannel1Threshold"
    /// Boolean: Enable channel 2 threshold.
    case ColorInverterEnableChannel2Threshold = "ColorInverterEnableChannel2Threshold"
    /// Boolean: Enable channel 3 threshold.
    case ColorInverterEnableChannel3Threshold = "ColorInverterEnableChannel3Threshold"
    /// Boolean: Enable channel 4 threshold.
    case ColorInverterEnableChannel4Threshold = "ColorInverterEnableChannel4Threshold"
    /// Double: Threshold level for channel 1.
    case ColorInverterChannel1Threshold = "ColorInverterChannel1Threshold"
    /// Double: Threshold level for channel 2.
    case ColorInverterChannel2Threshold = "ColorInverterChannel2Threshold"
    /// Double: Threshold level for channel 3.
    case ColorInverterChannel3Threshold = "ColorInverterChannel3Threshold"
    /// Double: Threshold level for channel 4.
    case ColorInverterChannel4Threshold = "ColorInverterChannel4Threshold"
    /// Boolean: Invert channel 1 if the threshold value is greater.
    case ColorInverterInvertChannel1IfGreater = "ColorInverterInvertChannel1IfGreater"
    /// Boolean: Invert channel 2 if the threshold value is greater.
    case ColorInverterInvertChannel2IfGreater = "ColorInverterInvertChannel2IfGreater"
    /// Boolean: Invert channel 3 if the threshold value is greater.
    case ColorInverterInvertChannel3IfGreater = "ColorInverterInvertChannel3IfGreater"
    /// Boolean: Invert channel 4 if the threshold value is greater.
    case ColorInverterInvertChannel4IfGreater = "ColorInverterInvertChannel4IfGreater"
    /// Boolean: Determines if alpha is inverted.
    case ColorInverterInvertAlpha = "ColorInverterInvertAlpha"
    /// Boolean: Threshold for alpha processing.
    case ColorInverterEnableAlphaThreshold = "ColorInverterEnableAlphaThreshold"
    /// Boolean: Alpha threshold value.
    case ColorInverterAlphaThreshold = "ColorInverterAlphaThreshold"
    /// Boolean: Reverses alpha inversion.
    case ColorInverterInvertAlphaIfGreater = "ColorInverterInvertAlphaIfGreater"

    // MARK: - Conditional silhouette
    /// Integer: Silhouette trigger.
    case ConditionalSilhouetteTrigger = "ConditionalSilhouetteTrigger"
    /// Double: Threshold for hue.
    case ConditionalSilhouetteHueThreshold = "ConditionalSilhouetteHueThreshold"
    /// Double: Range for hue.
    case ConditionalSilhouetteHueRange = "ConditionalSilhouetteHueRange"
    /// Double: Threshold for saturation.
    case ConditionalSilhouetteSatThreshold = "ConditionalSilhouetteSatThreshold"
    /// Double: Range for saturation.
    case ConditionalSilhouetteSatRange = "ConditionalSilhouetteSatRange"
    /// Double: Threshold for brightness.
    case ConditionalSilhouetteBriThreshold = "ConditionalSilhouetteBriThreshold"
    /// Double: Range for brightness.
    case ConditionalSilhouetteBriRange = "ConditionalSilhouetteBriRange"
    /// Boolean: Switches threshold calculation.
    case ConditionalSilhouetteGreaterThan = "ConditionalSilhouetteGreaterThan"
    /// UIColor: Color to use for the silhouette.
    case ConditionalSilhouetteColor = "ConditionalSilhouetteColor"

    // MARK: - Channel mangler
    /// Integer: Operation to perform to mangle channels.
    case ChannelManglerOperation = "ChannelManglerOperation"
    
    // MARK: - Channel mixer
    /// Integer: Channel 1 input source
    case ChannelMixerChannel1 = "ChannelMixerChannel1"
    /// Integer: Channel 2 input source
    case ChannelMixerChannel2 = "ChannelMixerChannel2"
    /// Integer: Channel 3 input source
    case ChannelMixerChannel3 = "ChannelMixerChannel3"
    /// Boolean: Invert channel 1.
    case ChannelMixerInvertChannel1 = "ChannelMixerInvertChannel1"
    /// Boolean: Invert channel 2.
    case ChannelMixerInvertChannel2 = "ChannelMixerInvertChannel2"
    /// Boolean: Invert channel 3.
    case ChannelMixerInvertChannel3 = "ChannelMixerInvertChannel3"
    
    // MARK: - Bayer decoding
    /// Integer: Order of the channels.
    case BayerDecodeOrder = "BayerDecodeOrder"
    /// Integer: Decoding method.
    case BayerDecodeMethod = "BayerDecodeMethod"
    
    // MARK: - Solarization
    /// Integer: Determines how to solarize the image.
    case SolarizeHow = "SolarizeHow"
    /// Double: Solarization threshold low value.
    case SolarizeThresholdLow = "SolarizeThresholdLow"
    /// Double: Solarization threshold high value.
    case SolarizeThresholdHigh = "SolarizeThresholdHigh"
    /// Boolean: Determines where solarization occurs.
    case SolarizeIfGreater = "SolarizeIfGreater"
    /// Double: Low range value for solarization.
    case SolarizeLowHue = "SolarizeLowHue"
    /// Double: High range value for solarization.
    case SolarizeHighHue = "SolarizeHighHue"
    /// Double: Brightness low threshold.
    case SolarizeBrightnessThresholdLow = "SolarizeBrightnessThresholdLow"
    /// Double: Brightness high threshold.
    case SolarizeBrightnessThresholdHigh = "SolarizeBrightnessThresholdHigh"
    /// Double: Saturation low threshold.
    case SolarizeSaturationThresholdLow = "SolarizeSaturationThresholdLow"
    /// Double: Saturation high threshold.
    case SolarizeSaturationThresholdHigh = "SolarizeSaturationThresholdHigh"
    /// Double: Red channel threshold.
    case SolarizeRedThreshold = "SolarizeRedThreshold"
    /// Double: Green channel threshold.
    case SolarizeGreenThreshold = "SolarizeGreenThreshold"
    /// Double: Blue channel threshold.
    case SolarizeBlueThreshold = "SolarizeBlueThreshold"
    /// Boolean: If true only the specified RGB channel will be solarized. Otherwise, all
    ///          RGB channels will be solarized.
    case SolarizeOnlyChannel = "SolarizeOnlyChannel"
    
    // MARK: - Kuwahara
    /// Double: Radius of Kuwahara effect
    case KuwaharaRadius = "KuwaharaRadius"
    
    // MARK: - Metal pixellate
    /// Integer: Width of pixels.
    case MetalPixWidth = "MetalPixWidth"
    /// Integer: Height of pixels.
    case MetalPixHeight = "MetalPixHeight"
    /// Integer: Determines how to calculate pixel's color.
    case MetalPixColorDetermination = "MetalPixColorDetermination"
    /// Boolean: Merge pixellated image with the background image.
    case MetalPixMergeImage = "MetalPixMergeImage"
    /// Integer: Highlight pixel determination.
    case MetalPixHighlightPixel = "MetalPixHighlightPixel"
    /// Double: Threshold for when using pixel highlighting.
    case MetalPixThreshold = "MetalPixThreshold"
    /// Boolean: Invert the threshold calculation.
    case MetalPixInvertThreshold = "MetalPixInvertThreshold"
    /// Boolean: Show a border around the pixel.
    case MetalPixShowBorder = "MetalPixShowBorder"
    /// UIColor: The border color if `MetalPixShowBorder` is true.
    case MetalPixBorderColor = "MetalPixBorderColor"
    
    // MARK: - Twirl bump distortion
    /// Double: Radius for the twirl.
    case TwirlBumpTwirlRadius = "TwirlBumpTwirlRadius"
    /// Double: Radius for the bump.
    case TwirlBumpBumpRadius = "TwirlBumpBumpRadius"
    /// Double: Angle for the twirl.
    case TwirlBumpAngle = "TwirlBumpAngle"
    
    // MARK: - Line screen halftone
    /// Double: Angle for the line screen.
    case LineScreenAngle = "LineScreenAngle"
    
    // MARK: - Smooth linear gradient
    /// UIColor: Linear color 0.
    case SmoothLinearColor0 = "SmoothLinearColor0"
    /// UIColor: Linear color 1.
    case SmoothLinearColor1 = "SmoothLinearColor1"
    
    // MARK: - Circular wrap
    /// Double: Circular wrap radius.
    case CircularWrapRadius = "CircularWrapRadius"
    /// Double: Circular wrap angle.
    case CircularWrapAngle = "CircularWrapAngle"
    
    // MARK: - Multi-frame combiner
    /// Integer: Determines how to combine frames.
    case MultiFrameCombinerCommand = "MultiFrameCombinerCommand"
    /// Bool: Determines if the command is inverted.
    case MultiFrameCombinerInvertCommand = "MultiFrameCombinerInvertCommand"
    /// Integer: Index for the first sub-sample image.
    case MultiFrameSubImage0 = "MultiFrameSubImage0"
    /// Integer: Index for the second sub-sample image.
    case MultiFrameSubImage1 = "MultiFrameSubImage1"
    
    // MARK: - Imgage delta frame combiner
    /// Integer: How to perform the image delta.
    case ImageDeltaCommand = "ImageDeltaCommand"
    /// UIColor: Background color for results near black.
    case ImageDeltaBackground = "ImageDeltaBackground"
    /// Double: Threshold to determine if `ImageDeltaBackground` is used.
    case ImageDeltaThreshold = "ImageDeltaThreshold"
    /// Integer: Index for the first sub-sample image.
    case ImageDeltaSubImage0 = "ImageDeltaSubImage0"
    /// Integer: Index for the second sub-sample image.
    case ImageDeltaSubImage1 = "ImageDeltaSubImage1"
    /// Boolean: Determines if the effective color is used.
    case ImageDeltaUseEffectiveColor = "ImageDeltaUseEffectiveColor"
    /// UIColor: The effective color to use with standand image delta.
    case ImageDeltaEffectiveColor = "ImageDeltaEffectiveColor"
    
    // MARK: - Color range filter.
    /// Double: Start of the color range.
    case ColorRangeStart = "ColorRangeStart"
    /// Double: End of the color range.
    case ColorRangeEnd = "ColorRangeEnd"
    /// Boolean: Invert the color range.
    case ColorRangeInvertRange = "ColorRangeInvertRange"
    /// Integer: Method to use to de-emphasize colors not in the range.
    case ColorRangeOutOfRangeAction = "ColorRangeOutOfRangeAction"
    /// UIColor: Color for the use color out of range action.
    case ColorRangeOutOfRangeColor = "ColorRangeOutOfRangeColor"
    /// Integer: Index of the pre-defined color range to use.
    case ColorRangePredefinedRangesIndex = "ColorRangePredefinedRangesIndex"

    // MARK: - Metal checkerboard
    /// Integer: Width and height of each color check.
    case MCheckerCheckSize = "MCheckerCheckSize"
    /// Integer: Width of the final image.
    case MCheckerWidth = "MCheckerWidth"
    /// Integer: Height of the final image.
    case MCheckerHeight = "MCheckerHeight"
    /// UIColor: Upper-left color.
    case MCheckerColor0 = "MCheckerColor0"
    /// UIColor: Upper-right color.
    case MCheckerColor1 = "MCheckerColor1"
    /// UIColor: Lower-right color.
    case MCheckerColor2 = "MCheckerColor2"
    /// UIColor: Lower-left color.
    case MCheckerColor3 = "MCheckerColor3"
}
