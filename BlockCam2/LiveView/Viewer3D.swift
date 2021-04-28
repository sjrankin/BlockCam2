//
//  Viewer3D.swift
//  BlockCam2
//
//  Created by Stuart Rankin on 4/15/21.
//

import Foundation
import UIKit
import SceneKit

class Viewer3D: SCNView, SCNSceneRendererDelegate
{
    /// Initializer.
    /// - Parameter frame: Frame for the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter frame: Frame for the view.
    /// - Parameter options: Options to pass to `super.init`.
    override init(frame: CGRect, options: [String: Any]?)
    {
        super.init(frame: frame, options: options)
        Initialize()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the scene.
    /// - Note: **If this function is not called, nothing will appear.**
    func Initialize()
    {
        let Scene = SCNScene()
        self.scene = Scene
        delegate = self
        isPlaying = true
        loops = true
        InitializeView()
        ReloadScene()
        AddCameraObserver()
    }
    
    /// Initialize the view.
    private func InitializeView()
    {
        allowsCameraControl = true
        preferredFramesPerSecond = 30
        rendersContinuously = false
    }
    
    func ReloadScene()
    {
        
    }
    
    func Clear()
    {
        
    }
    
    var CameraObserver: NSKeyValueObservation? = nil
    
    /// Adds an observer to the point-of-view node's position value. This allows us to track the scene when it is moved
    /// which in turn lets us save a frame for each change, which can then be assembled in to a video. Additionally, if
    /// proper settings are enabled, a histogram is generated for the processed image.
    private func AddCameraObserver()
    {
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
            {
                /*
                if self.RecordScene
                {
                    let Now = CACurrentMediaTime()
                    let DefaultCamera = Node.defaultCameraController
                    let POVNode = DefaultCamera.pointOfView
                    self.SceneRecords?.append((POVNode!.position, Now))
                }
 */
            }
        }
    }
    
    func ProcessImage(_ Image: UIImage, CalledFrom: String? = nil)
    {
        
    }
    
    func ProcessImage(_ Colors: [[UIColor]], CalledFrom: String)
    {
        
    }
}
