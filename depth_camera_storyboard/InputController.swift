//
//  InputController.swift
//  depth_camera_storyboard
//
//  Created by Alejandro Comas-Leon on 2024-01-02.
//

import Foundation
import UIKit
import AVFoundation

class InputController {
    var captureSession : AVCaptureSession!
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    var backCameraNeeded = true
    var frontCameraNeeded = false
    var backCameraOn = true
    
    var previewLayer : AVCaptureVideoPreviewLayer!
    
    var deviceTypeForBack = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    var deviceTypeForFront = AVCaptureDevice.DeviceType.builtInWideAngleCamera
    
    func selectView(view : UIView) {
        fatalError("Must Overide")
    }
    
    func startInput(using extraConfigs : @escaping () -> Void = {}) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setupAndStartCaptureSession(using: extraConfigs)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupAndStartCaptureSession(using: extraConfigs)
        @unknown default:
            break
        }
    }
    
    func setupAndStartCaptureSession(using extraConfigs : @escaping () -> Void = {}) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession = AVCaptureSession()
            
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            self.setupInputs()
            
            self.previewLayer.videoGravity = .resizeAspectFill
            self.previewLayer.session = self.captureSession
            
            extraConfigs()
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    func setupInputs(){
        if (backCameraNeeded) {
            if let device = AVCaptureDevice.default(deviceTypeForBack, for: .video, position: .back) {
                backCamera = device
            } else {
                fatalError("no back camera")
            }
            
            guard let bInput = try? AVCaptureDeviceInput(device: backCamera) else {
                fatalError("could not create input device from back camera")
            }
            backInput = bInput
            if !captureSession.canAddInput(backInput) {
                fatalError("could not add back camera input to capture session")
            }
        }
        
        if (frontCameraNeeded) {
            if let fdevice = AVCaptureDevice.default(deviceTypeForFront, for: .video, position: .front) {
                frontCamera = fdevice
            } else {
                fatalError("no front camera")
            }
            
            guard let fInput = try? AVCaptureDeviceInput(device: frontCamera) else {
                fatalError("could not create input device from front camera")
            }
            frontInput = fInput
            if !captureSession.canAddInput(frontInput) {
                fatalError("could not add front camera input to capture session")
            }
        }
        
        if backCameraOn {
            captureSession.addInput(backInput)
        } else {
            captureSession.addInput(frontInput)
        }
    }
}
