//
//  Submission.swift
//  Roast Bot
//
//  Created by isaiahnields on 5/2/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import Foundation
import UIKit

struct Comment: Identifiable, Codable {
    let id: String
    let body: String
    let score: Int
}

struct Submission: Identifiable, Decodable, Equatable {
    let id: String
    let embedding: [Double]
    var score: Int
    var comments: [Comment] = []
    var similarity: Double?
    
    mutating func calculateSimilarity(facialEmbedding: [Double]) {
        self.similarity = zip(embedding, facialEmbedding).map { $0 * $1 }.reduce(0, +)
    }
    
    static func != (lhs: Submission, rhs: Submission) -> Bool {
        return lhs.id != rhs.id
    }
    
    static func == (lhs: Submission, rhs: Submission) -> Bool {
        return lhs.id == rhs.id
    }
}


