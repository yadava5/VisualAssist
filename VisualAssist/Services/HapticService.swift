//
//  HapticService.swift
//  VisualAssist
//
//  Haptic feedback service using Core Haptics
//

import Foundation
import CoreHaptics
import UIKit

/// Types of haptic feedback patterns
enum HapticPattern {
    case tap              // Single light tap
    case doubleTap        // Two quick taps
    case success          // Positive feedback
    case warning          // Caution alert
    case critical         // Urgent alert - continuous
    case modeSwitch       // Mode change confirmation
    case navigation       // Directional pulse
}

/// Service for haptic feedback
class HapticService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isEnabled = true
    @Published var intensity: Float = 1.0
    
    // MARK: - Private Properties
    
    private var hapticEngine: CHHapticEngine?
    private var supportsHaptics = false
    
    // Fallback generators for older devices
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Initialization
    
    init() {
        checkHapticSupport()
        setupHapticEngine()
        prepareGenerators()
    }
    
    // MARK: - Setup
    
    private func checkHapticSupport() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    private func setupHapticEngine() {
        guard supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.playsHapticsOnly = true
            
            // Handle engine reset
            hapticEngine?.resetHandler = { [weak self] in
                do {
                    try self?.hapticEngine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
            
            // Handle stopped state
            hapticEngine?.stoppedHandler = { [weak self] reason in
                print("Haptic engine stopped: \(reason)")
                self?.restartEngine()
            }
            
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
            supportsHaptics = false
        }
    }
    
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
    }
    
    private func restartEngine() {
        guard supportsHaptics else { return }
        do {
            try hapticEngine?.start()
        } catch {
            print("Failed to restart haptic engine: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Play a haptic pattern
    func play(_ pattern: HapticPattern) {
        guard isEnabled else { return }
        
        if supportsHaptics {
            playAdvancedHaptic(pattern)
        } else {
            playBasicHaptic(pattern)
        }
    }
    
    /// Set haptic intensity (0.0 to 1.0)
    func setIntensity(_ value: Float) {
        intensity = max(0.0, min(1.0, value))
    }
    
    // MARK: - Advanced Haptics (Core Haptics)
    
    private func playAdvancedHaptic(_ pattern: HapticPattern) {
        guard let engine = hapticEngine else {
            playBasicHaptic(pattern)
            return
        }
        
        do {
            let hapticPattern = try createPattern(for: pattern)
            let player = try engine.makePlayer(with: hapticPattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic: \(error)")
            playBasicHaptic(pattern)
        }
    }
    
    private func createPattern(for pattern: HapticPattern) throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        let adjustedIntensity = Float(intensity)
        
        switch pattern {
        case .tap:
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ))
            
        case .doubleTap:
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0
            ))
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.1
            ))
            
        case .success:
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                ],
                relativeTime: 0
            ))
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.15
            ))
            
        case .warning:
            for i in 0..<3 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7 * adjustedIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: Double(i) * 0.15
                ))
            }
            
        case .critical:
            // Strong continuous vibration
            events.append(CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0,
                duration: 0.5
            ))
            
        case .modeSwitch:
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8 * adjustedIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            ))
            
        case .navigation:
            // Rhythmic pattern for navigation cues
            for i in 0..<2 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6 * adjustedIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                    ],
                    relativeTime: Double(i) * 0.2
                ))
            }
        }
        
        return try CHHapticPattern(events: events, parameters: [])
    }
    
    // MARK: - Basic Haptics (UIKit Fallback)
    
    private func playBasicHaptic(_ pattern: HapticPattern) {
        switch pattern {
        case .tap:
            impactLight.impactOccurred()
            
        case .doubleTap:
            impactLight.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactLight.impactOccurred()
            }
            
        case .success:
            notificationGenerator.notificationOccurred(.success)
            
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
            
        case .critical:
            notificationGenerator.notificationOccurred(.error)
            
        case .modeSwitch:
            impactMedium.impactOccurred()
            
        case .navigation:
            impactHeavy.impactOccurred()
        }
    }
}
