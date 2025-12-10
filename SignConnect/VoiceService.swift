//
//  VoiceService.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/10/25.
//

import Foundation
import AVFoundation

@Observable
class VoiceService: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    var isSpeaking: Bool = false
    
    // 1. The callback hook
    var onSpeechEnded: (() -> Void)?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(_ text: String) {
        // 1. Stop any current speech immediately
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // 2. Configure the utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Default English
        utterance.rate = 0.5 // Normal conversational speed
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        
        // 3. Speak
        synthesizer.speak(utterance)
        self.isSpeaking = true
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    // 2. Delegate method to track when speech finishes
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        // Reset audio session to record (for the mic) if needed,
        // though we usually keep the mic running in the background service.
        
        // notify the app that we are done
        DispatchQueue.main.async {
            self.onSpeechEnded?()
        }
    }
}
