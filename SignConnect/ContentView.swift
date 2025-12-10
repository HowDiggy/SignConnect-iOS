//
//  ContentView.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/9/25.
//

import SwiftUI
import SwiftData
import FoundationModels

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var scenarios: [Scenario] // Fetch all scenarios from DB
    
    @State private var speechService = SpeechService()
    @State private var llmService = LLMService()
    @State private var voiceService = VoiceService()
    
    // The "Memory" Service
    private let embeddingService = EmbeddingService()
    @State private var currentContext: Scenario? // The best matching scenario
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header & Context Indicator
            VStack(alignment: .leading) {
                HStack {
                    Text("SignConnect")
                        .font(.headline)
                    Spacer()
                    if llmService.isThinking { ProgressView().controlSize(.mini) }
                }
                
                // Show what the 'Memory' found
                if let context = currentContext {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Context: \(context.title)")
                            .font(.caption)
                            .bold()
                    }
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
                    .transition(.opacity)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // 2. Transcription Area
            ScrollViewReader { proxy in
                ScrollView {
                    Text(speechService.transcript.isEmpty
                         ? (speechService.isRecording ? "Listening..." : "Tap the microphone to start")
                         : speechService.transcript
                    )
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id("bottom")
                }
                .onChange(of: speechService.transcript) { _, newValue in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    handleNewSpeech(text: newValue)
                }
            }
            
            Divider()
            
            // 3. AI Suggestions
            VStack(spacing: 12) {
                if let suggestions = llmService.suggestions {
                    SuggestionButton(title: suggestions.casual, icon: "hand.wave", color: .blue, action: {
                        speechService.stopTranscribing()
                        voiceService.speak(suggestions.casual)
                    })
                    SuggestionButton(title: suggestions.formal, icon: "briefcase", color: .purple, action: {
                        speechService.stopTranscribing()
                        voiceService.speak(suggestions.formal)
                    })
                    SuggestionButton(title: suggestions.quick, icon: "bolt", color: .orange, action: {
                        speechService.stopTranscribing()
                        voiceService.speak(suggestions.quick)
                    })
                } else {
                    Text("Start speaking to see suggestions...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // 4. Mic Control
            HStack {
                Button(action: {
                    speechService.isRecording ? speechService.stopTranscribing() : speechService.startTranscribing()
                }) {
                    Image(systemName: speechService.isRecording ? "mic.slash.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(speechService.isRecording ? .red : .green)
                }
            }
            .padding()
        }
        .onAppear {
            // Seed data for testing (only if empty)
            if scenarios.isEmpty {
                Task { await DataSeeder.seed(context: modelContext) }
            }
            
            // setup auto-resume logic
            voiceService.onSpeechEnded = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !speechService.isRecording {
                        speechService.startTranscribing()
                    }
                }
            }
        }
    }
    
    // Orchestrator: Transcript -> Vector Search -> LLM
        private func handleNewSpeech(text: String) {
            debounceTimer?.invalidate()
            
            // 1. Prepare data (Main Thread -> Background Safe)
            let safeScenarios = scenarios.compactMap { scenario -> ScenarioTransfer? in
                guard let embedding = scenario.embedding else { return nil }
                return ScenarioTransfer(id: scenario.persistentModelID, embedding: embedding, title: scenario.title)
            }
            
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                Task {
                    // 2. Check Memory (Background)
                    var foundContextTitle: String? = nil
                    
                    if let bestMatchID = await embeddingService.findBestMatchID(for: text, in: safeScenarios) {
                        
                        // Switch to Main Thread ONLY to update UI and fetch the Title
                        foundContextTitle = await MainActor.run {
                            if let match = scenarios.first(where: { $0.persistentModelID == bestMatchID }) {
                                withAnimation { self.currentContext = match }
                                return match.title // Return the title directly back to the background task
                            }
                            return nil
                        }
                    }
                    
                    // 3. Ask Brain (Background)
                    // Now we use the 'foundContextTitle' which was safely returned to us
                    await llmService.generateSuggestions(for: text, context: foundContextTitle)
                }
            }
        }
}

// Helper View
struct SuggestionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    ContentView()
}
