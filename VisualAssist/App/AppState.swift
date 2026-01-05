//
//  AppState.swift
//  VisualAssist
//
//  Global application state management
//

import SwiftUI
import Combine
import ARKit

/// The current active mode of the application
enum AppMode: String, CaseIterable {
    case home = "Home"
    case navigation = "Navigation"
    case textReading = "Text Reading"
    case objectAwareness = "Object Awareness"
    case settings = "Settings"
    
    /// iOS 26 style SF Symbols with new glyphs
    var icon: String {
        switch self {
        case .home: return "house.circle.fill"
        case .navigation: return "location.viewfinder"
        case .textReading: return "text.viewfinder"
        case .objectAwareness: return "eye.circle.fill"
        case .settings: return "gearshape.circle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .home: return "Choose a mode to get started"
        case .navigation: return "Detect obstacles using LiDAR"
        case .textReading: return "Read text aloud from camera"
        case .objectAwareness: return "Identify objects around you"
        case .settings: return "Adjust app preferences"
        }
    }
}

/// Global application state
@MainActor
class AppState: ObservableObject {
    // MARK: - Published Properties
    
    /// Current active mode
    @Published var currentMode: AppMode = .home
    
    /// Whether LiDAR is available on this device
    @Published var isLiDARAvailable: Bool = false
    
    /// Whether the app is currently processing
    @Published var isProcessing: Bool = false
    
    /// Current status message to announce
    @Published var statusMessage: String = ""
    
    /// Whether voice commands are enabled
    @Published var voiceCommandsEnabled: Bool = true
    
    // MARK: - Services
    
    let speechService = SpeechService()
    let hapticService = HapticService()
    
    // MARK: - Initialization
    
    init() {
        checkLiDARAvailability()
    }
    
    // MARK: - Methods
    
    /// Check if LiDAR is available on this device
    private func checkLiDARAvailability() {
        // LiDAR is available on iPhone 12 Pro and later Pro models
        // We check using ARKit's scene depth capability
        if #available(iOS 14.0, *) {
            isLiDARAvailable = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
        } else {
            isLiDARAvailable = false
        }
    }
    
    /// Switch to a new mode with instant announcement
    func switchMode(to mode: AppMode) {
        currentMode = mode
        // Use speakNow for instant feedback - interrupts any previous speech
        speechService.speakNow("\(mode.rawValue) mode")
        hapticService.play(.modeSwitch)
    }
    
    /// Update status and announce
    func updateStatus(_ message: String, announce: Bool = true) {
        statusMessage = message
        if announce {
            speechService.speak(message)
        }
    }
}
