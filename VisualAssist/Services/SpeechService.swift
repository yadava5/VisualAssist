//
//  SpeechService.swift
//  VisualAssist
//
//  Text-to-speech service with natural reading and immediate modes
//

import Foundation
import AVFoundation

/// Priority level for speech utterances
enum SpeechPriority {
    case low
    case normal
    case high
    case urgent
}

/// Speech mode for different contexts
enum SpeechMode {
    case natural      // For reading text - adds pauses, doesn't interrupt
    case immediate    // For navigation/alerts - interrupts instantly
}

/// Service for text-to-speech functionality
class SpeechService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isSpeaking = false
    @Published var currentRate: Float = 0.5
    @Published var currentPitch: Float = 1.0
    
    // MARK: - Private Properties
    
    private let synthesizer = AVSpeechSynthesizer()
    private var completionHandler: (() -> Void)?
    
    private let defaultVoice = AVSpeechSynthesisVoice(language: "en-US")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }
    
    // MARK: - Audio Session
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Speech Control
    
    /// Speak text with optional priority and completion handler
    /// Mode determines if speech should be natural (for reading) or immediate (for navigation)
    func speak(_ text: String, mode: SpeechMode = .immediate, priority: SpeechPriority = .normal, completion: (() -> Void)? = nil) {
        // Immediate mode: always interrupt for instant feedback
        if mode == .immediate {
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            speakImmediate(text, completion: completion)
        } else {
            // Natural mode: for reading text with pauses
            speakNatural(text, completion: completion)
        }
    }
    
    /// Speak with immediate interruption (for navigation, alerts, mode changes)
    private func speakImmediate(_ text: String, completion: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = currentRate
        utterance.pitchMultiplier = currentPitch
        utterance.voice = defaultVoice
        utterance.preUtteranceDelay = 0  // No delay - instant start
        utterance.postUtteranceDelay = 0.05
        
        completionHandler = completion
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    /// Speak with natural pauses for reading (processes text for better flow)
    private func speakNatural(_ text: String, completion: (() -> Void)? = nil) {
        // Format text for natural reading with pauses
        let formattedText = formatForNaturalReading(text)
        
        let utterance = AVSpeechUtterance(string: formattedText)
        utterance.rate = currentRate * 0.9  // Slightly slower for reading
        utterance.pitchMultiplier = currentPitch
        utterance.voice = defaultVoice
        utterance.preUtteranceDelay = 0.1
        utterance.postUtteranceDelay = 0.3  // Pause at end
        
        completionHandler = completion
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    /// Format text for natural reading with strategic pauses
    private func formatForNaturalReading(_ text: String) -> String {
        var result = text
        
        // Add slight pauses after periods (full stops) - uses ... for pause effect
        result = result.replacingOccurrences(of: ". ", with: "... ")
        result = result.replacingOccurrences(of: ".\n", with: "... ")
        
        // Add pauses after colons and semicolons
        result = result.replacingOccurrences(of: ": ", with: ".. ")
        result = result.replacingOccurrences(of: "; ", with: ".. ")
        
        // Add micro pause after commas (already natural in TTS, but reinforce)
        result = result.replacingOccurrences(of: ", ", with: ",  ")
        
        // Add pause before quoted text
        result = result.replacingOccurrences(of: " \"", with: "... \"")
        
        // Add pause after question marks and exclamation points
        result = result.replacingOccurrences(of: "? ", with: "?... ")
        result = result.replacingOccurrences(of: "! ", with: "!... ")
        
        // Clean up any excessive spacing
        while result.contains("    ") {
            result = result.replacingOccurrences(of: "    ", with: "  ")
        }
        
        return result
    }
    
    /// Quick speak for alerts/navigation - immediate interrupt with minimum latency
    func speakNow(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = currentRate
        utterance.pitchMultiplier = currentPitch
        utterance.voice = defaultVoice
        utterance.preUtteranceDelay = 0  // Zero latency
        utterance.postUtteranceDelay = 0
        
        isSpeaking = true
        synthesizer.speak(utterance)
    }
    
    /// Stop speaking immediately
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        completionHandler = nil
    }
    
    /// Pause speaking
    func pause() {
        synthesizer.pauseSpeaking(at: .word)
    }
    
    /// Resume speaking
    func resume() {
        synthesizer.continueSpeaking()
    }
    
    // MARK: - Rate Control
    
    /// Set the speech rate (0.0 to 1.0)
    func setRate(_ rate: Float) {
        currentRate = max(0.1, min(1.0, rate))
    }
    
    /// Adjust rate faster or slower
    func adjustRate(faster: Bool) {
        if faster {
            currentRate = min(1.0, currentRate + 0.1)
        } else {
            currentRate = max(0.1, currentRate - 0.1)
        }
    }
    
    /// Set the pitch (0.5 to 2.0)
    func setPitch(_ pitch: Float) {
        currentPitch = max(0.5, min(2.0, pitch))
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.completionHandler?()
            self?.completionHandler = nil
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
    }
}
