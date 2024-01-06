//
//  DepthMapCaptureProcessor.swift
//  depth_camera_storyboard
//
//  Created by Alejandro Comas-Leon on 2024-01-02.
//

import Foundation
import UIKit
import AVFoundation

class DepthMapCaptureProcessor : NSObject, AVCapturePhotoCaptureDelegate {
    var viewController : ViewController!
    
    override init() {
        super.init()
    }
    
    init(viewController: ViewController!) {
        self.viewController = viewController
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {}
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {}
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {}

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        viewController.depthPhotoTaken(output, didFinishProcessingPhoto: photo, error: error)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: Error?) {}
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {}
}
