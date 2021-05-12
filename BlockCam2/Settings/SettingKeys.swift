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
    
    case InitializationFlag = "InitializationFlag"
    case InstanceID = "InstanceID"
    
    // MARK: - User interface settings.
    
    /// Boolean: If true, audio waveforms are shown overlayed the image.
    case ShowAudioWaveform = "ShowAudioWaveform"
    /// Boolean: If true, the original image is saved along with the modified image.
    case SaveOriginalImage = "SaveOriginalImage"
    /// Integer: Index of the sample image.
    case SampleImageIndex = "SampleImageIndex"
    /// Integer: Index of the input source (0 = camera, 1 = photo album).
    case InputSourceIndex = "InputSourceIndex"
    
    // MARK: - Filter settings.
    /// String: Current filter in use.
    case CurrentFilter = "CurrentFilter"
    /// String: Current group in which the current filter resides.
    case CurrentGroup = "CurrentGroup"
    
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
}
