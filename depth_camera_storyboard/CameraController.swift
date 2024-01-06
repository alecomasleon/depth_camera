//
//  CameraController.swift
//  depth_camera_storyboard
//
//  Created by Alejandro Comas-Leon on 2023-12-17.
//

import Foundation
import UIKit
import AVFoundation

class CameraController : InputController {
    override init() {
        super.init()
        
        backCameraNeeded = true
        frontCameraNeeded = true
        backCameraOn = true
    }
    
    private let switchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 40, y:0, width: 200, height: 200))
        button.layer.cornerRadius = 40
        button.layer.borderWidth = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func selectView(view : UIView) {
        view.backgroundColor = .black
        
        previewLayer = AVCaptureVideoPreviewLayer()
        previewLayer.frame = view.layer.frame
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(switchButton)
        
        startInput()
        
        NSLayoutConstraint.activate([
            switchButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            switchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            switchButton.widthAnchor.constraint(equalToConstant: 80),
            switchButton.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        switchButton.addTarget(self, action: #selector(switchFBCamera(_:)), for: .touchUpInside)
    }
    
    private func switchCameraInput() {
        switchButton.isUserInteractionEnabled = false
        
        captureSession.beginConfiguration()
        
        if backCameraOn {
            captureSession.removeInput(backInput)
            captureSession.addInput(frontInput)
            backCameraOn = false
        } else {
            captureSession.removeInput(frontInput)
            captureSession.addInput(backInput)
            backCameraOn = true
        }
        
        captureSession.commitConfiguration()
        
        switchButton.isUserInteractionEnabled = true
    }
    
    @objc func switchFBCamera(_ sender: UIButton?){
        switchCameraInput()
    }
}
