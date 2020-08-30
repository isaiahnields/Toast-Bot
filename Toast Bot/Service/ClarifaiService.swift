//
//  ClarifaiService.swift
//  Toast Bot
//
//  Created by isaiahnields on 5/2/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import Foundation

class ClarifaiService: ObservableObject {
    
    func observeFaces(base64image: String, completion: @escaping ([FaceObservation]?) -> ()) {
        let url = URL(string: "https://api.clarifai.com/v2/models/d02b4508df58432fbb84e800597b8959/outputs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonBody: [String: Any] = [
            "inputs": [
                [
                    "data": [
                        "image": [
                            "base64": base64image
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody =  try? JSONSerialization.data(withJSONObject: jsonBody)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Key 13aaa51ec076476288f44eeb5dbd99c7", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response: ClarifaiResponse = try JSONDecoder().decode(ClarifaiResponse.self, from: data)
                let faceObservations = FaceObservation.parse(response)
                completion(faceObservations)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

struct BoundingBox {
    let topRow: Double
    let leftCol: Double
    let bottomRow: Double
    let rightCol: Double
    
    var width: Double {
        return rightCol - leftCol
    }
    
    var height: Double {
        return bottomRow - topRow
    }
}

struct FaceObservation {
    let embedding: [Double]
    let boundingBox: BoundingBox
    let toasts: [Toast]?
    
    static func parse(_ clarifaiResponse: ClarifaiResponse) -> [FaceObservation] {
        var observations: [FaceObservation] = []
        if clarifaiResponse.outputs.count == 0 {
            return observations
        }
        clarifaiResponse.outputs[0].data.regions.forEach { (region) in
            let embedding = region.data.embeddings[0].vector
            let boundingBox = BoundingBox(
                topRow: region.region_info.bounding_box.top_row,
                leftCol: region.region_info.bounding_box.left_col,
                bottomRow: region.region_info.bounding_box.bottom_row,
                rightCol: region.region_info.bounding_box.right_col
            )
            observations.append(FaceObservation(embedding: embedding, boundingBox: boundingBox, toasts: nil))
        }
        return observations
    }
    
    func addToasts(toasts: [Toast]) -> FaceObservation {
        return FaceObservation(embedding: embedding, boundingBox: boundingBox, toasts: toasts)
    }
}

struct ClarifaiResponse: Codable {
    let outputs: [ClarifaiOutput]
}

struct ClarifaiOutput: Codable {
    let data: ClarifaiData
}

struct ClarifaiData: Codable {
    let regions: [ClarifaiRegion]
}

struct ClarifaiRegion: Codable {
    let region_info: ClarifaiRegionInfo
    let data: ClarifaiEmbeddingData
}

struct ClarifaiEmbeddingData: Codable {
    let embeddings: [ClarifaiEmbedding]
}

struct ClarifaiEmbedding: Codable {
    let vector: [Double]
}

struct ClarifaiRegionInfo: Codable {
    let bounding_box: ClarifaiBoundingBox
}

struct ClarifaiBoundingBox: Codable {
    let top_row: Double
    let left_col: Double
    let bottom_row: Double
    let right_col: Double
}
