//
//  ViewViewModel.swift
//  Toast Bot
//
//  Created by isaiahnields on 5/2/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import Foundation
import SwiftUI

class Model {
    
    private var submissions: [Submission] = []
    var faceObservations: [FaceObservation] = []
    var nextToastIndex = 1
    var observationIndex = 0
    
    private var clarifaiService: ClarifaiService!
    
    init() {
        clarifaiService = ClarifaiService()
        
        // load submissions
        let path = Bundle.main.path(forResource: "scrape", ofType: "json")!
        let fileUrl = URL(fileURLWithPath: path)
        let data = try! Data(contentsOf: fileUrl)
        submissions = try! JSONDecoder().decode([Submission].self, from: data)
    }
    
    func takePhoto(image: UIImage, completion: @escaping ([FaceObservation]?) -> Void) {
        let base64Image = image.resized(withPercentage: CGFloat(0.50))!.pngData()!.base64EncodedString()
        self.clarifaiService.observeFaces(base64image: base64Image) { (faceObservations) in
            DispatchQueue.main.async {
                if let faceObservations = faceObservations {
                    self.faceObservations = faceObservations.map { (faceObservation) -> FaceObservation in
                        for idx in 0..<self.submissions.count {
                            self.submissions[idx].calculateSimilarity(facialEmbedding: faceObservation.embedding)
                        }
                        let toasts = Toast.createToasts(submissions: self.submissions)
                        return faceObservation.addToasts(toasts: toasts)
                    }
                    completion(self.faceObservations)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
