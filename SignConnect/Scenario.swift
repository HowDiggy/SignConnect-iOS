//
//  Scenario.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/10/25.
//

import Foundation
import SwiftData

@Model
class Scenario {
    var title: String
    var content: String // e.g., "I usually order a latte with oat milk."
    var embedding: [Double]? // The vector representation of the content
    
    init(title: String, content: String, embedding: [Double]? = nil) {
        self.title = title
        self.content = content
        self.embedding = embedding
    }
}

