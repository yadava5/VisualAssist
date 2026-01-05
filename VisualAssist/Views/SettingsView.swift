//
//  SettingsView.swift
//  VisualAssist
//
//  User preferences and app settings
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("speechRate") private var speechRate: Double = 0.5
    @AppStorage("hapticIntensity") private var hapticIntensity: Double = 1.0
    @AppStorage("autoAnnounce") private var autoAnnounce: Bool = true
    @AppStorage("continuousScanning") private var continuousScanning: Bool = true
    @AppStorage("alertDistance") private var alertDistance: Double = 1.5
    
    var body: some View {
        NavigationStack {
            List {
                // Speech Settings
                speechSection
                
                // Haptics Settings
                hapticsSection
                
                // Navigation Settings
                navigationSection
                
                // Accessibility
                accessibilitySection
                
                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { appState.switchMode(to: .home) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .accessibilityLabel("Back to home")
                }
            }
        }
    }
    
    // MARK: - Speech Section
    
    private var speechSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Speech Rate")
                    Spacer()
                    Text(speechRateLabel)
                        .foregroundColor(.gray)
                }
                
                Slider(value: $speechRate, in: 0.2...1.0, step: 0.1) { editing in
                    if !editing {
                        appState.speechService.setRate(Float(speechRate))
                        appState.speechService.speak("This is my new speaking rate")
                    }
                }
                .accessibilityLabel("Speech rate")
                .accessibilityValue(speechRateLabel)
            }
            .padding(.vertical, 8)
            
            Button(action: testSpeech) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                    Text("Test Speech")
                }
            }
            .accessibilityHint("Double tap to hear a sample of current speech settings")
        } header: {
            Label("Speech", systemImage: "waveform")
        }
    }
    
    // MARK: - Haptics Section
    
    private var hapticsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Haptic Intensity")
                    Spacer()
                    Text(hapticIntensityLabel)
                        .foregroundColor(.gray)
                }
                
                Slider(value: $hapticIntensity, in: 0...1.0, step: 0.25) { editing in
                    if !editing {
                        appState.hapticService.setIntensity(Float(hapticIntensity))
                        appState.hapticService.play(.tap)
                    }
                }
                .accessibilityLabel("Haptic intensity")
                .accessibilityValue(hapticIntensityLabel)
            }
            .padding(.vertical, 8)
            
            Button(action: testHaptics) {
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.orange)
                    Text("Test Haptics")
                }
            }
            .accessibilityHint("Double tap to feel haptic feedback")
        } header: {
            Label("Haptics", systemImage: "hand.tap.fill")
        }
    }
    
    // MARK: - Navigation Section
    
    private var navigationSection: some View {
        Section {
            Toggle(isOn: $continuousScanning) {
                HStack {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundColor(.green)
                    Text("Continuous Scanning")
                }
            }
            .accessibilityHint("When enabled, LiDAR scans continuously in navigation mode")
            
            Toggle(isOn: $autoAnnounce) {
                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.blue)
                    Text("Auto-Announce Obstacles")
                }
            }
            .accessibilityHint("When enabled, obstacles are announced automatically")
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Alert Distance")
                    Spacer()
                    Text(String(format: "%.1f m", alertDistance))
                        .foregroundColor(.gray)
                }
                
                Slider(value: $alertDistance, in: 0.5...3.0, step: 0.5)
                    .accessibilityLabel("Alert distance")
                    .accessibilityValue(String(format: "%.1f meters", alertDistance))
            }
            .padding(.vertical, 8)
        } header: {
            Label("Navigation", systemImage: "location.fill")
        }
    }
    
    // MARK: - Accessibility Section
    
    private var accessibilitySection: some View {
        Section {
            Toggle(isOn: $appState.voiceCommandsEnabled) {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.purple)
                    Text("Voice Commands")
                }
            }
            .accessibilityHint("Enable or disable voice command recognition")
            
            Button(action: openSystemAccessibility) {
                HStack {
                    Image(systemName: "accessibility")
                        .foregroundColor(.blue)
                    Text("System Accessibility Settings")
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .foregroundColor(.gray)
                }
            }
            .accessibilityHint("Opens iOS accessibility settings")
        } header: {
            Label("Accessibility", systemImage: "accessibility")
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.gray)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Version 1.0.0")
            
            HStack {
                Text("LiDAR Status")
                Spacer()
                Text(appState.isLiDARAvailable ? "Available" : "Not Available")
                    .foregroundColor(appState.isLiDARAvailable ? .green : .orange)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("LiDAR \(appState.isLiDARAvailable ? "available" : "not available")")
            
            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text("Documentation")
                    Spacer()
                    Image(systemName: "arrow.up.forward")
                        .foregroundColor(.gray)
                }
            }
        } header: {
            Label("About", systemImage: "info.circle")
        }
    }
    
    // MARK: - Helpers
    
    private var speechRateLabel: String {
        if speechRate < 0.4 { return "Slow" }
        if speechRate < 0.6 { return "Normal" }
        if speechRate < 0.8 { return "Fast" }
        return "Very Fast"
    }
    
    private var hapticIntensityLabel: String {
        if hapticIntensity == 0 { return "Off" }
        if hapticIntensity < 0.5 { return "Light" }
        if hapticIntensity < 0.75 { return "Medium" }
        return "Strong"
    }
    
    private func testSpeech() {
        appState.speechService.speak("This is a test of the speech system. The current rate is \(speechRateLabel).")
    }
    
    private func testHaptics() {
        appState.hapticService.play(.warning)
    }
    
    private func openSystemAccessibility() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
