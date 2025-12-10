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
    @State private var speechService = SpeechService()
    @State private var llmService = LLMService()
    
    // Timer to debounce typing (don't ask AI on every character, wait for a pause)
    @State private var debounceTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            HStack {
                Text("SignConnect")
                    .font(.headline)
                Spacer()
                if llmService.isThinking {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // 2. Transcription Area (The "Ears")
            ScrollViewReader { proxy in
                ScrollView {
                    Text(speechService.transcript.isEmpty ? "Listening..." : speechService.transcript)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .id("bottom")
                }
                .onChange(of: speechService.transcript) { _, newValue in
                    // Auto-scroll to bottom
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    
                    // Trigger AI logic
                    scheduleAIRequest(for: newValue)
                }
            }
            
            Divider()
            
            // 3. AI Suggestions Area (The "Brain")
            VStack(spacing: 12) {
                if let suggestions = llmService.suggestions {
                    SuggestionButton(title: suggestions.casual, icon: "hand.wave", color: .blue)
                    SuggestionButton(title: suggestions.formal, icon: "briefcase", color: .purple)
                    SuggestionButton(title: suggestions.quick, icon: "bolt", color: .orange)
                } else if speechService.transcript.isEmpty {
                    Text("Waiting for conversation...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // 4. Controls
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
    }
    
    // Logic: Wait for 1.5 seconds of silence before asking AI
    private func scheduleAIRequest(for text: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            Task {
                await llmService.generateSuggestions(for: text)
            }
        }
    }
}

// Helper View for the buttons
struct SuggestionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Placeholder for TTS (Text to Speech)
            print("Selected: \(title)")
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    ContentView()
}
