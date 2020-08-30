//
//  ViewController.swift
//  Toast Bot
//
//  Created by isaiahnields on 5/21/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let model = Model()
    let imagePicker = UIImagePickerController()
    var image: UIImage?
    
    @IBOutlet var proButton: UIButton!
    
    @IBAction func openPhotoLibrary(_ sender: UIButton) {
        if isPremium() {
            present(imagePicker, animated: true, completion: nil)
        }
        else if numUses() > 0 {
            useToast()
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            alertNoUsesLeft()
        }
        
    }
    @IBAction func openCamera(_ sender: UIButton) {
        if isPremium() {
            self.performSegue(withIdentifier: "showCamera", sender: nil)
        }
        else if numUses() > 0 {
            useToast()
            self.performSegue(withIdentifier: "showCamera", sender: nil)
        }
        else {
            alertNoUsesLeft()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isPremium() {
            self.proButton.isHidden = true
        }

        // set up image picker
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        addParticalView(birthRates: (Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2)), velocities: (Float.random(in: 90.0...150.0), Float.random(in: 90.0...150.0), Float.random(in: 90.0...150.0)), particalImage: #imageLiteral(resourceName: "glasses"))
        addParticalView(birthRates: (Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2)), velocities: (Float.random(in: 90.0...150.0), Float.random(in: 90.0...150.0), Float.random(in: 90.0...150.0)), particalImage: #imageLiteral(resourceName: "popper"))
        addParticalView(birthRates: (Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2), Float.random(in: 0.1...0.2)), velocities: (Float.random(in: 50.0...60.0), Float.random(in: 60.0...90.0), Float.random(in: 50.0...60.0)), particalImage: #imageLiteral(resourceName: "balloon"))
    }
    
    func addParticalView(birthRates: (Float, Float, Float), velocities: (Float, Float, Float), particalImage: UIImage) {
        let fireView = ParticleView(birthRates: birthRates, velocities: velocities, frame: self.view.frame, particleImage: particalImage)
        let topConstraint = NSLayoutConstraint(item: fireView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: fireView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0.0)
        let leadingConstraint = NSLayoutConstraint(item: fireView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: fireView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0.0)
        fireView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(fireView)
        self.view.addConstraints([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        self.view.layoutIfNeeded()
        self.view.sendSubviewToBack(fireView)
    }
    
    func isPremium() -> Bool {
        return UserDefaults.standard.bool(forKey: "isaiahnields.ToastBot.Pro")
    }
    
    func useToast() {
        let currentUses = UserDefaults.standard.integer(forKey: "uses")
        UserDefaults.standard.set(currentUses - 1, forKey: "uses")
    }
    
    func numUses() -> Int {
        return UserDefaults.standard.integer(forKey: "uses")
    }
    
    func alertNoUsesLeft() {
        let alert = UIAlertController(title: "No uses left!", message: "Please upgrade to Toast Bot Pro to unlock more uses.", preferredStyle: .alert)
        self.present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.performSegue(withIdentifier: "showUpgrade", sender: nil)
        }))
    }
    
}


extension HomeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = pickedImage
            self.imagePicker.dismiss(animated: true) {
                self.performSegue(withIdentifier: "showToast", sender: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showToast" {
            let vc = segue.destination as! ToastViewController
            vc.image = image!
            vc.model = model
        }
        else if segue.identifier == "showCamera" {
            let vc = segue.destination as! ToastViewController
            vc.model = model
        }
    }
}

