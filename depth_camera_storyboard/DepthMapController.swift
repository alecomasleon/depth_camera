//
//  DepthMapController.swift
//  depth_camera_storyboard
//
//  Created by Alejandro Comas-Leon on 2024-01-02.
//

import Foundation
import UIKit
import AVFoundation

class DepthMapController : InputController {
    var captureProcessor : AVCapturePhotoCaptureDelegate!
    var photoSettings : AVCapturePhotoSettings!
    var photoOutput : AVCapturePhotoOutput!
    
    var viewController : ViewController!
    
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 40, y:0, width: 200, height: 200))
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewController : ViewController) {
        super.init()
        
        self.viewController = viewController
        
        backCameraNeeded = false
        frontCameraNeeded = true
        backCameraOn = false

        deviceTypeForFront = .builtInTrueDepthCamera
        captureProcessor = DepthMapCaptureProcessor(viewController: viewController)
        
        shutterButton.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
    }
    
    override func selectView(view : UIView) {
        view.backgroundColor = .black
        
        previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.frame = view.layer.frame
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        
        self.photoOutput = AVCapturePhotoOutput()
        
        startInput() {
            guard self.captureSession.canAddOutput(self.photoOutput)
                else { fatalError("Can't add photo output.") }
            self.captureSession.addOutput(self.photoOutput)
            self.captureSession.sessionPreset = .photo

            self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported

        }
        
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    @objc func takePhoto(_ sender: UIButton?){
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
    }
}
