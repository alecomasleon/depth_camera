//
//  ViewController.swift
//  depth_camera_storyboard
//
//  Created by Alejandro Comas-Leon on 2023-12-17.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var displayView : UIView!
    
    var cameraController : CameraController!
    var depthMapController : DepthMapController!
    
    let BUTTON_HEIGHT = 45.0
    let BUTTON_WIDTH = 65.0
    
    enum ButtonIdentifier : Int {
        case Camera, DepthMap, LastPhoto
    }
    
    var toolBarItems : [UIBarButtonItem]?
    let TOOL_BAR_HEIGHT = 83.0
    
    lazy var toolBar : UIToolbar = {
        let tb = UIToolbar(frame: CGRect(x: 0, y: view.bounds.maxY - TOOL_BAR_HEIGHT, width: view.bounds.width, height: TOOL_BAR_HEIGHT))
        tb.barStyle = .default
        tb.backgroundColor = .black
        tb.barTintColor = .black
        tb.tintColor = .black
        tb.overrideUserInterfaceStyle = .dark
        
        return tb
    }()
    
    lazy var cameraButton : UIBarButtonItem = {
        return createButton(title: "CA", tag: ButtonIdentifier.Camera.rawValue)
    }()
    
    lazy var depthMapButton : UIBarButtonItem = {
        return createButton(title: "DM", tag: ButtonIdentifier.DepthMap.rawValue)
    }()
    
    lazy var lastPhotoButton : UIBarButtonItem = {
        return createButton(title: "LP", tag: ButtonIdentifier.LastPhoto.rawValue)
    }()
    
    var currentView : Int!
    
    var lastImageTaken : UIImage!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spacer1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(spacerClicked(sender:)))
        let spacer2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(spacerClicked(sender:)))
        let spacer3 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(spacerClicked(sender:)))
        let spacer4 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: #selector(spacerClicked(sender:)))
        
        toolBarItems = [spacer1, cameraButton, spacer2, spacer2, depthMapButton, spacer3, spacer3, lastPhotoButton, spacer4]
        toolBar.setItems(toolBarItems, animated: true)
        toolBar.isUserInteractionEnabled = true
        
        lastImageTaken = nil
        
        displayView = UIView(frame: CGRect(x: 0, y:0, width: view.bounds.width, height: view.bounds.height - TOOL_BAR_HEIGHT))
        displayView.backgroundColor = .black
        
        cameraController = CameraController()
        depthMapController = DepthMapController(viewController: self)
        
        cameraController.selectView(view: displayView)
        currentView = ButtonIdentifier.Camera.rawValue
        updateButtons(selectedTag: ButtonIdentifier.Camera.rawValue)
        
        self.view.addSubview(displayView)
        self.view.addSubview(toolBar)
    }
    
    func createButton(title : String, tag : Int) -> UIBarButtonItem {
        let uibutton = UIButton(type: .custom)
        uibutton.frame = CGRect(x: 0.0, y: 0.0, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
        uibutton.setTitle(title, for: .normal)
        uibutton.setTitleColor(.white, for: .normal)
        
        uibutton.titleLabel?.font = UIFont.init(name: "Apple SD Gothic Neo", size: 22)
        uibutton.tag = tag
        uibutton.layer.cornerRadius = 11

        let barButton = UIBarButtonItem(customView: uibutton)
        barButton.style = .plain
        
        uibutton.addTarget(self, action: #selector(click(sender:)), for: UIControl.Event.touchUpInside)
        
        return barButton
    }
    
    func updateButtons(selectedTag : Int) {
        switch selectedTag {
        case ButtonIdentifier.Camera.rawValue:
            selected(barButton: cameraButton)
            notSelected(barButton: depthMapButton)
            notSelected(barButton: lastPhotoButton)
        case ButtonIdentifier.DepthMap.rawValue:
            notSelected(barButton: cameraButton)
            selected(barButton: depthMapButton)
            notSelected(barButton: lastPhotoButton)
        case ButtonIdentifier.LastPhoto.rawValue:
            notSelected(barButton: cameraButton)
            notSelected(barButton: depthMapButton)
            selected(barButton: lastPhotoButton)
        default:
            fatalError("selected tag not a button identifier")
        }
    }
    
    func selected(barButton : UIBarButtonItem) {
        barButton.isSelected = true
        barButton.customView?.backgroundColor = .darkGray
    }
    
    func notSelected(barButton : UIBarButtonItem) {
        barButton.isSelected = false
        barButton.customView?.backgroundColor = .clear
    }
    
    func clearView() {
        while let subview = displayView.subviews.last {
            subview.removeFromSuperview()
        }
        
         displayView.layer.sublayers?.removeAll()
    }
    
    @objc func click(sender: UIBarButtonItem){
        if sender.tag == currentView {
            return
        }
        
        toolBar.isUserInteractionEnabled = false
        
        currentView = sender.tag
        
        clearView()
        
        switch sender.tag {
        case ButtonIdentifier.Camera.rawValue:
            cameraController.selectView(view: displayView)
            
        case ButtonIdentifier.DepthMap.rawValue:
            depthMapController.selectView(view: displayView)
            
        case ButtonIdentifier.LastPhoto.rawValue:
            displayLastImage()
            
        default:
            fatalError("Button tag not a button identifier")
        }
        
        updateButtons(selectedTag: sender.tag)
        
        toolBar.isUserInteractionEnabled = true
    }
    
    func displayLastImage() {
        if (lastImageTaken == nil) {
            displayView.backgroundColor = .black
            let label = UILabel()
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "No depth photos taken yet"
            label.font = UIFont.systemFont(ofSize: 20)
        
            displayView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: displayView.safeAreaLayoutGuide.centerXAnchor, constant: 0),
                label.centerYAnchor.constraint(equalTo: displayView.safeAreaLayoutGuide.centerYAnchor, constant: 0),
            ])
            
        } else {
            let uiImageView = UIImageView(image: lastImageTaken.withHorizontallyFlippedOrientation())
            
            uiImageView.contentMode = .scaleAspectFit
            uiImageView.frame.size = CGSize(width: displayView.frame.height * lastImageTaken.size.width / lastImageTaken.size.height, height: displayView.frame.height)

            displayView.addSubview(uiImageView)
        }
    }
    
    func depthPhotoTaken(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        toolBar.isUserInteractionEnabled = false
        
        clearView()
        
        displayView.backgroundColor = .red

        let depthDataMap = photo.depthData!.applyingExifOrientation(.right).depthDataMap
        
        let ciImage = CIImage(cvPixelBuffer: depthDataMap)
        let context = CIContext.init(options: nil)
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let uncroppedImage = UIImage.init(cgImage: cgImage)
        
        let finalWidth = uncroppedImage.size.height * displayView.frame.width / displayView.frame.height
        lastImageTaken = cropImage(uncroppedImage, toRect: CGRect(x: (uncroppedImage.size.width - finalWidth) / 2.0, y: 0, width: finalWidth, height: uncroppedImage.size.height))
        
        displayLastImage()
  
        updateButtons(selectedTag: ButtonIdentifier.LastPhoto.rawValue)
        currentView = ButtonIdentifier.LastPhoto.rawValue
        
        toolBar.isUserInteractionEnabled = true
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage? {
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropRect)
        else {
            return nil
        }

        let croppedImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    @objc func spacerClicked(sender: UIBarButtonItem) {
        return
    }
}

