//
//  UserSettings.swift
//  VisualAssist
//
//  User preferences and settings model
//

import Foundation
import SwiftUI

/// User preferences stored in UserDefaults
class UserSettings: ObservableObject {
    
    // MARK: - Speech Settings
    
    @AppStorage("speechRate") var speechRate: Double = 0.5 {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("speechPitch") var speechPitch: Double = 1.0 {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("speechVoice") var speechVoiceIdentifier: String = "" {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Haptic Settings
    
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("hapticIntensity") var hapticIntensity: Double = 1.0 {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Navigation Settings
    
    @AppStorage("continuousScanning") var continuousScanning: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("autoAnnounceObstacles") var autoAnnounceObstacles: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("alertDistance") var alertDistance: Double = 1.5 {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("criticalDistance") var criticalDistance: Double = 0.5 {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Text Reading Settings
    
    @AppStorage("autoReadText") var autoReadText: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("readingPauseOnPunctuation") var readingPauseOnPunctuation: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Object Detection Settings
    
    @AppStorage("announceObjectPositions") var announceObjectPositions: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("detectionConfidenceThreshold") var detectionConfidenceThreshold: Double = 0.5 {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Voice Command Settings
    
    @AppStorage("voiceCommandsEnabled") var voiceCommandsEnabled: Bool = true {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("voiceCommandWakeWord") var voiceCommandWakeWord: String = "hey assist" {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Accessibility Settings
    
    @AppStorage("highContrastMode") var highContrastMode: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("largerText") var largerText: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("reducedMotion") var reducedMotion: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - App State
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false {
        didSet { objectWillChange.send() }
    }
    
    @AppStorage("lastUsedMode") var lastUsedMode: String = AppMode.home.rawValue {
        didSet { objectWillChange.send() }
    }
    
    // MARK: - Methods
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        speechRate = 0.5
        speechPitch = 1.0
        speechVoiceIdentifier = ""
        
        hapticsEnabled = true
        hapticIntensity = 1.0
        
        continuousScanning = true
        autoAnnounceObstacles = true
        alertDistance = 1.5
        criticalDistance = 0.5
        
        autoReadText = false
        readingPauseOnPunctuation = true
        
        announceObjectPositions = true
        detectionConfidenceThreshold = 0.5
        
        voiceCommandsEnabled = true
        voiceCommandWakeWord = "hey assist"
        
        highContrastMode = false
        largerText = false
        reducedMotion = false
    }
    
    /// Export settings as dictionary
    func exportSettings() -> [String: Any] {
        return [
            "speechRate": speechRate,
            "speechPitch": speechPitch,
            "hapticsEnabled": hapticsEnabled,
            "hapticIntensity": hapticIntensity,
            "continuousScanning": continuousScanning,
            "autoAnnounceObstacles": autoAnnounceObstacles,
            "alertDistance": alertDistance,
            "voiceCommandsEnabled": voiceCommandsEnabled
        ]
    }
}
