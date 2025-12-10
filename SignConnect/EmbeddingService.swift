//
//  EmbeddingService.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/10/25.
//

import Foundation
import NaturalLanguage
import Accelerate //  Uses the CPU's vector units for math
import SwiftData

actor EmbeddingService {
    // We use the built-in sentence embedding model (English)
    private let embeddingModel = NLEmbedding.sentenceEmbedding(for: .english)
    
    /// Converts a string into a vector (array of Doubles)
    func generateEmbedding(for text: String) -> [Double]? {
        // NLEmbedding vectors are automatically normalized (magnitude ≈ 1.0)
        return embeddingModel?.vector(for: text)
    }
    
/// Finds the closest Scenario ID using our thread-safe transfer objects
    func findBestMatchID(for query: String, in items: [ScenarioTransfer]) -> PersistentIdentifier? {
        guard let queryVector = generateEmbedding(for: query),
              embeddingModel != nil else { return nil }
        
        var bestMatchID: PersistentIdentifier?
        var highestScore: Double = -1.0
        
        for item in items {
            // Calculate Cosine Similarity
            let score = cosineSimilarity(queryVector, item.embedding)
            
            if score > highestScore {
                highestScore = score
                bestMatchID = item.id
            }
        }
        
        // Threshold > 0.6
        return highestScore > 0.6 ? bestMatchID : nil
    }
    
    /// Helper: Calculates Cosine Similarity between two vectors using Accelerate
    private func cosineSimilarity(_ vectorA: [Double], _ vectorB: [Double]) -> Double {
        guard vectorA.count == vectorB.count else { return 0.0 }
        
        // 1. Calculate Dot Product using vDSP (very fast)
        let dotProduct = vDSP.dot(vectorA, vectorB)
        
        // 2. Since NLEmbedding vectors are normalized, Magnitude is ~1.0.
        // Similarity ≈ Dot Product.
        // However, for strict correctness, we divide by magnitudes:
        let magA = vDSP.sumOfSquares(vectorA).squareRoot()
        let magB = vDSP.sumOfSquares(vectorB).squareRoot()
        
        if magA == 0 || magB == 0 { return 0.0 }
        
        return dotProduct / (magA * magB)
    }
}
