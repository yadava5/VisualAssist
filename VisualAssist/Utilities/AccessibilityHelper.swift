//
//  AccessibilityHelper.swift
//  VisualAssist
//
//  Accessibility utilities and helpers
//

import Foundation
import UIKit
import SwiftUI

/// Helper utilities for accessibility features
struct AccessibilityHelper {
    
    // MARK: - Announcements
    
    /// Post an accessibility announcement
    static func announce(_ message: String, priority: UIAccessibility.AnnouncementPriority = .high) {
        UIAccessibility.post(
            notification: .announcement,
            argument: NSAttributedString(
                string: message,
                attributes: [.accessibilitySpeechQueueAnnouncement: priority == .high]
            )
        )
    }
    
    /// Announce a screen change
    static func announceScreenChange(_ screenName: String) {
        UIAccessibility.post(notification: .screenChanged, argument: screenName)
    }
    
    /// Announce layout change
    static func announceLayoutChange() {
        UIAccessibility.post(notification: .layoutChanged, argument: nil)
    }
    
    // MARK: - System Checks
    
    /// Check if VoiceOver is running
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    /// Check if Reduce Motion is enabled
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    /// Check if Bold Text is enabled
    static var isBoldTextEnabled: Bool {
        UIAccessibility.isBoldTextEnabled
    }
    
    /// Check if Increase Contrast is enabled
    static var isIncreaseContrastEnabled: Bool {
        UIAccessibility.isDarkerSystemColorsEnabled
    }
    
    // MARK: - Haptic Helpers
    
    /// Play success haptic if not reduced motion
    static func playSuccessHaptic() {
        guard !isReduceMotionEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Play error haptic
    static func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Play selection haptic
    static func playSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Text Helpers
    
    /// Get appropriate font size based on accessibility settings
    static func accessibleFontSize(for style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
    
    /// Format number for speech (e.g., 1.5 -> "one point five")
    static func formatNumberForSpeech(_ number: Float) -> String {
        if number == Float(Int(number)) {
            return String(Int(number))
        }
        
        let formatted = String(format: "%.1f", number)
        return formatted.replacingOccurrences(of: ".", with: " point ")
    }
    
    /// Format distance for speech
    static func formatDistanceForSpeech(_ meters: Float) -> String {
        if meters == .infinity {
            return "clear"
        }
        
        if meters < 1 {
            let cm = Int(meters * 100)
            return "\(cm) centimeters"
        }
        
        let formatted = formatNumberForSpeech(meters)
        return "\(formatted) meters"
    }
    
    // MARK: - Label Generation
    
    /// Generate accessibility label for an obstacle
    static func obstacleLabel(direction: ObstacleDirection, distance: Float) -> String {
        let distanceStr = formatDistanceForSpeech(distance)
        return "Obstacle \(direction.description) at \(distanceStr)"
    }
    
    /// Generate accessibility label for detected objects
    static func objectsLabel(objects: [DetectedObject]) -> String {
        guard !objects.isEmpty else {
            return "No objects detected"
        }
        
        if objects.count == 1 {
            return "One \(objects[0].label) detected"
        }
        
        let grouped = Dictionary(grouping: objects, by: { $0.label })
        var parts: [String] = []
        
        for (label, items) in grouped.sorted(by: { $0.value.count > $1.value.count }) {
            if items.count == 1 {
                parts.append("one \(label)")
            } else {
                parts.append("\(items.count) \(label)s")
            }
        }
        
        return parts.joined(separator: ", ") + " detected"
    }
}

// MARK: - SwiftUI Accessibility Modifiers

extension View {
    /// Add standard accessible button traits
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Double tap to activate")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Add accessible header traits
    func accessibleHeader(_ label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Group children and provide combined label
    func accessibleGroup(label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
    
    /// Make view announce value changes
    func accessibleValue(_ value: String) -> some View {
        self.accessibilityValue(value)
    }
}

// MARK: - Accessibility Priority

extension UIAccessibility {
    enum AnnouncementPriority {
        case low
        case high
        case immediate
    }
}
