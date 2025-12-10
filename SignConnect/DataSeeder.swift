//
//  DataSeeder.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/10/25.
//

import Foundation
import SwiftData

class DataSeeder {
    @MainActor
    static func seed(context: ModelContext) async {
        // 1. clear existing data to avoid duplicates for this test
        try? context.delete(model: Scenario.self)
        
        let service = EmbeddingService()
        
        // 2. Define test scenarios
        let scenarios = [
            ("Coffee Shop", "I would like a large latte with oat milk, please."),
            ("Medical", "I am deaf. I communicate using this app. Please speak clearly."),
            ("Emergency", "I need help. Please call an ambulance to my location."),
            ("Greeting", "Hello! Nice to meet you.")
        ]
        
        // 3. Generate vectors and save
        for (title, content) in scenarios {
            if let vector = await service.generateEmbedding(for: content) {
                let scenario = Scenario(title: title, content: content, embedding: vector)
                context.insert(scenario)
            }
        }
        
        try? context.save()
        print("Database seeded with \(scenarios.count) scenarios!")
    }
}
