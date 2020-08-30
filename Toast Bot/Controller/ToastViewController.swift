//
//  ToastViewController.swift
//  Toast Bot
//
//  Created by isaiahnields on 5/22/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit
import AVFoundation

class ToastViewController: UIViewController {
    var model: Model!
    let cameraController = CameraController()
    
    @IBOutlet var imageView: ToastImageView!
    @IBOutlet var capturePreviewView: UIView!
    @IBOutlet var cameraControlsView: UIView!
    var toastCardStack: ToastCardStack?
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if image == nil {
            cameraController.prepare {(error) in
                if let error = error {
                    self.alertNoCameraFound()
                    print(error)
                }
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        else {
            self.removeCameraControls()
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.processImage()
            }
        }
        createToastCardStack()
    }
    
    @IBAction func flipCamera(_ sender: UIButton) {
        do { try cameraController.switchCameras() }
        catch {}
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage { (image, error) in
            if let error = error {
                print(error)
                self.alertNoCameraFound()
            }
            if let image = image {
                self.image = image
                self.imageView.image = image
                
                self.removeCameraControls()
                self.processImage()
            }
        }
    }
    
    func processImage() {
        self.imageView.addFaceScanner()
        self.model.takePhoto(image: self.image!) { (faceObservations) in
            if faceObservations == nil {
                self.alertNoFaceFound()
            }
            else if faceObservations!.isEmpty {
                self.alertNoFaceFound()
            }
            else {
                self.imageView.addFaceTarget(boundingBox: faceObservations!.first!.boundingBox)
                self.imageView.removeFaceScanner()
                self.addToastCardStack()
            }
        }
    }
    
    func alertNoFaceFound() {
        let alert = UIAlertController(title: "No face found!", message: "Please make sure there is a face clearly visible in your photo.", preferredStyle: .alert)
        self.present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
    }
    
    func alertNoCameraFound() {
        let alert = UIAlertController(title: "No camera found!", message: "Please make sure you have allowed access to your camera.", preferredStyle: .alert)
        self.present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true)
        }))
    }
    
    func removeCameraControls() {
        UIView.animate(withDuration: 0.25) {
            self.cameraControlsView.transform = self.cameraControlsView.transform.translatedBy(x: 0, y: self.cameraControlsView.frame.height)
        }
    }
    
    func createToastCardStack() {
        self.toastCardStack = Bundle.main.loadNibNamed("ToastCardStack", owner: self, options: nil)?.first as? ToastCardStack
        self.view.addSubview(toastCardStack!)
        self.toastCardStack!.transform = CGAffineTransform(translationX: 0, y: 300)
        self.toastCardStack!.translatesAutoresizingMaskIntoConstraints = false
        self.toastCardStack!.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.toastCardStack!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.toastCardStack!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.toastCardStack!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    
    }
    
    func addToastCardStack() {
        self.toastCardStack?.setUp(model: self.model)
        UIView.animate(withDuration: 0.25) {
            self.toastCardStack!.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    func removeToastCardStack() {
        UIView.animate(withDuration: 0.25) {
            self.toastCardStack!.transform = CGAffineTransform(translationX: 0, y: 300)
        }
    }
    
}
