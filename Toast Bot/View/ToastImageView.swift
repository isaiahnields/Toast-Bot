//
//  RoastImageView.swift
//  Roast Bot
//
//  Created by isaiahnields on 6/22/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import UIKit
import Vision


class ToastImageView: UIImageView {
    
    var faceScanner: UIView = UIView()
    var faceTargets: [UIView] = []
    
    func addFaceTarget(boundingBox: BoundingBox) {
        let newFaceTarget = UIView()
        
        var width: CGFloat
        var height: CGFloat
        var x: CGFloat
        var y: CGFloat
        
        if self.contentMode == .scaleAspectFill {
            width = self.frame.width * CGFloat(boundingBox.width)
            height = self.frame.height * CGFloat(boundingBox.height)
            x = self.frame.origin.x + (CGFloat(boundingBox.leftCol) * self.frame.width)
            y = self.frame.origin.y + (CGFloat(boundingBox.topRow) * self.frame.height)
        }
        else {
            
            let imageRect = calculateRectOfImageInImageView()
            width = imageRect.width * CGFloat(boundingBox.width)
            height = imageRect.height * CGFloat(boundingBox.height)
            x = imageRect.origin.x + (CGFloat(boundingBox.leftCol) * imageRect.width)
            y = imageRect.origin.y + (CGFloat(boundingBox.topRow) * imageRect.height)
        }
            
        newFaceTarget.layer.borderWidth = 3
        newFaceTarget.layer.cornerRadius = 10
        newFaceTarget.layer.borderColor = #colorLiteral(red: 0.9607843137, green: 0.8156862745, blue: 0.3803921569, alpha: 1)
        newFaceTarget.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.09736194349)
        newFaceTarget.frame = CGRect(x: (x + width) / 2.0, y: (y + height) / 2.0, width: 0, height: 0)
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            newFaceTarget.frame = CGRect(x: x, y: y, width: width, height: height)
        }, completion: nil)
        
        self.addSubview(newFaceTarget)
        self.faceTargets.append(newFaceTarget)
    }
    
    func removeFaceTargets() {
        faceTargets.forEach { (faceTarget) in
            faceTarget.removeFromSuperview()
        }
    }
    
    func addFaceScanner() {
        self.faceScanner.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        self.faceScanner.layer.shadowColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        self.faceScanner.layer.shadowOpacity = 1
        self.faceScanner.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.faceScanner.layer.shadowRadius = 15.0
        if self.contentMode == .scaleAspectFill {
            self.faceScanner.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 3.0)
        }
        else {
            let imageRect = calculateRectOfImageInImageView()
            self.faceScanner.frame = CGRect(x: 0, y: imageRect.origin.y, width: imageRect.width, height: 3.0)
        }
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat], animations: {
            if self.contentMode == .scaleAspectFill {
                self.faceScanner.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 3.0)
            }
            else {
                let imageRect = self.calculateRectOfImageInImageView()
                self.faceScanner.frame = CGRect(x: 0, y: imageRect.origin.y + imageRect.height, width: imageRect.width, height: 3.0)
            }
            
        }, completion: nil)
        
        self.addSubview(self.faceScanner)
        self.bringSubviewToFront(self.faceScanner)
    }
    
    func removeFaceScanner() {
        faceScanner.layer.removeAllAnimations()
        faceScanner.removeFromSuperview()
    }
    
    func calculateRectOfImageInImageView() -> CGRect {
        let imageViewSize = self.frame.size
        let imgSize = self.image?.size

        let scaleWidth = imageViewSize.width / imgSize!.width
        let scaleHeight = imageViewSize.height / imgSize!.height
        let aspect = fmin(scaleWidth, scaleHeight)

        var imageRect = CGRect(x: 0, y: 0, width: imgSize!.width * aspect, height: imgSize!.height * aspect)
        // Center image
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

        // Add imageView offset
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y

        return imageRect
    }
}
