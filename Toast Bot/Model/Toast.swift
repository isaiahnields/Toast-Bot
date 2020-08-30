//
//  Roast.swift
//  Roast Bot
//
//  Created by isaiahnields on 6/20/20.
//  Copyright © 2020 com.isaiahnields. All rights reserved.
//

import Foundation

struct Toast {
    let submissionId: String
    let commentId: String
    let score: Double
    let body: String
    
    static func createToasts(submissions: [Submission]) -> [Toast] {
        var toasts: [Toast] = []
        for submission in submissions {
            for comment in submission.comments {
                toasts.append(Toast(
                    submissionId: submission.id,
                    commentId: comment.id,
                    score: max(min(Double(comment.score) / Double(submission.score), 1.0), 0.9) * submission.similarity!,
                    body: comment.body
                ))
            }
        }
        toasts.sort(by: { $0.score > $1.score })
        return toasts
    }
}
