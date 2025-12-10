//
//  LLMService.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/9/25.
//

import Foundation
import FoundationModels // Requires iOS 18.1+ / Xcode 26+

// 1. Define the Structure we want the Brain to output
// The @Generable macro forces the LLM to strictly follow this schema.
@Generable
struct ResponseSuggestion {
    @Guide(description: "A short, casual, and friendly reply to the input")
    var casual: String
    
    @Guide(description: "A polite, professional, and formal reply")
    var formal: String
    
    @Guide(description: "A very brief, one-word acknowledgment")
    var quick: String
}

@Observable
class LLMService {
    var suggestions: ResponseSuggestion?
    var isThinking: Bool = false
    var error: String?
    
    // 2. The System Model (Apple Intelligence)
    private let model = SystemLanguageModel.default
    
    func generateSuggestions(for transcript: String) async {
        guard !transcript.isEmpty else { return }
        
        await MainActor.run {
            self.isThinking = true
            self.error = nil
        }
        
        do {
            // Create the Worker (Session)
            // The 'model' is just the brain; the 'session' is the conversation.
            let session = LanguageModelSession(model: model)
            
            let prompt = """
            The user is deaf or non-verbal and using this app to communicate. 
            The conversation partner just said: "\(transcript)"
            
            Generate 3 likely replies for the user to choose from.
            """
            
            // 4. Ask the Neural Engine to generate the struct
            // This runs 100% offline on the NPU
            let response = try await session.respond(
                to: prompt,
                generating: ResponseSuggestion.self
            )
            
            await MainActor.run {
                self.suggestions = response.content // Extract the struct
                self.isThinking = false
            }
            
        } catch {
            await MainActor.run {
                self.error = "AI Error: \(error.localizedDescription)"
                self.isThinking = false
            }
        }
    }
}
