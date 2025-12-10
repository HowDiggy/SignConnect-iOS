//
//  SpeechService.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/9/25.
//

import Foundation
import Speech
import AVFoundation

@Observable
class SpeechService {
    var transcript: String = ""
    var isRecording: Bool = false
    var errorMessage: String?
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func startTranscribing() {
        // 1. Reset state
        transcript = ""
        errorMessage = nil
        
        // 2. Check permissions
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                self.errorMessage = "Speech recognition is not enabled for this app."
                return
            }
        }
        
        // 3. Configure the audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.errorMessage = "Could not start audio: \(error.localizedDescription)"
            return
        }
        
        // 4. Create the recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        // CRITICAL: Force on-device recognition for privacy
        recognitionRequest.requiresOnDeviceRecognition = true
        
        // 5. Setup the input node
        let inputNode = audioEngine.inputNode
        
        // 6. Start the recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                // Update the transcript on the main thread
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stopTranscribing()
            }
        }
        
        // 7. Install the tap on the microphone
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // 8. Start the engine
        do {
            try audioEngine.start()
            self.isRecording = true
        } catch {
            self.errorMessage = "Could not start audio: \(error.localizedDescription)"
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
