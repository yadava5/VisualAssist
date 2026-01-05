//
//  VoiceCommandService.swift
//  VisualAssist
//
//  Voice command recognition using Speech framework
//

import Foundation
import Speech
import AVFoundation

/// Recognized voice commands
enum VoiceCommand: String, CaseIterable {
    case navigate = "navigate"
    case readText = "read text"
    case whatsAroundMe = "what's around me"
    case stop = "stop"
    case settings = "settings"
    case home = "home"
    case faster = "faster"
    case slower = "slower"
    case describe = "describe"
    case countPeople = "count people"
    case help = "help"
    
    /// Alternative phrases that map to this command
    var alternatives: [String] {
        switch self {
        case .navigate:
            return ["navigate", "navigation", "start navigation", "obstacle detection", "detect obstacles"]
        case .readText:
            return ["read text", "read", "text reading", "ocr", "what does it say"]
        case .whatsAroundMe:
            return ["what's around me", "whats around me", "objects", "object detection", "look around"]
        case .stop:
            return ["stop", "pause", "quiet", "silence", "shut up"]
        case .settings:
            return ["settings", "preferences", "options", "configure"]
        case .home:
            return ["home", "go home", "main menu", "back"]
        case .faster:
            return ["faster", "speed up", "quicker"]
        case .slower:
            return ["slower", "slow down", "reduce speed"]
        case .describe:
            return ["describe", "describe scene", "what do you see"]
        case .countPeople:
            return ["count people", "how many people", "people count"]
        case .help:
            return ["help", "what can you do", "commands", "list commands"]
        }
    }
}

/// Service for voice command recognition
@MainActor
class VoiceCommandService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isListening = false
    @Published var recognizedText = ""
    @Published var lastCommand: VoiceCommand?
    @Published var permissionGranted = false
    @Published var error: VoiceCommandError?
    
    // MARK: - Properties
    
    var onCommandRecognized: ((VoiceCommand) -> Void)?
    
    // MARK: - Private Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let speechService = SpeechService()
    
    // MARK: - Initialization
    
    init() {
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                switch status {
                case .authorized:
                    self?.permissionGranted = true
                case .denied, .restricted, .notDetermined:
                    self?.permissionGranted = false
                    self?.error = .permissionDenied
                @unknown default:
                    self?.permissionGranted = false
                }
            }
        }
    }
    
    // MARK: - Listening Control
    
    /// Start listening for voice commands
    func startListening() {
        guard permissionGranted else {
            error = .permissionDenied
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            error = .recognizerNotAvailable
            return
        }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = .audioSessionError
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            self.error = .requestCreationFailed
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 16.0, *) {
            recognitionRequest.addsPunctuation = false
        }
        
        // Start recognition
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.recognizedText = result.bestTranscription.formattedString
                    self?.processRecognizedText(result.bestTranscription.formattedString)
                }
                
                if error != nil || (result?.isFinal ?? false) {
                    self?.stopListening()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            self.error = .audioEngineError
        }
    }
    
    /// Stop listening for voice commands
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
    }
    
    // MARK: - Command Processing
    
    private func processRecognizedText(_ text: String) {
        let lowercased = text.lowercased()
        
        for command in VoiceCommand.allCases {
            for phrase in command.alternatives {
                if lowercased.contains(phrase) {
                    lastCommand = command
                    onCommandRecognized?(command)
                    
                    // Stop listening after command recognized
                    stopListening()
                    return
                }
            }
        }
    }
    
    /// Get help text listing all commands
    func getHelpText() -> String {
        """
        Available voice commands:
        - "Navigate" - Start obstacle detection
        - "Read text" - Start text reading mode
        - "What's around me" - Describe objects
        - "Stop" - Stop current action
        - "Faster" or "Slower" - Adjust speech speed
        - "Home" - Return to home screen
        - "Settings" - Open settings
        - "Help" - List commands
        """
    }
}

// MARK: - Errors

enum VoiceCommandError: Error, LocalizedError {
    case permissionDenied
    case recognizerNotAvailable
    case audioSessionError
    case audioEngineError
    case requestCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition permission denied"
        case .recognizerNotAvailable:
            return "Speech recognizer is not available"
        case .audioSessionError:
            return "Failed to configure audio session"
        case .audioEngineError:
            return "Failed to start audio engine"
        case .requestCreationFailed:
            return "Failed to create recognition request"
        }
    }
}
