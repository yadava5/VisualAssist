//
//  HomeView.swift
//  VisualAssist
//
//  Home screen with mode selection - iOS 26 Liquid Glass Design
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerSection
                    
                    // LiDAR Status
                    lidarStatusBanner
                    
                    // Mode Cards
                    modeCardsSection
                    
                    // Quick Settings
                    quickSettingsSection
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { appState.switchMode(to: .settings) }) {
                        Image(systemName: "gearshape.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Double tap to open settings")
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // iOS 26 style symbol with variable color
            Image(systemName: "eye.circle.fill")
                .font(.system(size: 80))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    .white,
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse.byLayer, options: .repeating)
                .accessibilityHidden(true)
            
            Text("Visual Assist")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Text("Your visual assistance companion")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Visual Assist. Your visual assistance companion.")
    }
    
    // MARK: - LiDAR Status Banner
    
    private var lidarStatusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: appState.isLiDARAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.title3)
                .symbolEffect(.bounce, value: appState.isLiDARAvailable)
            
            Text(appState.isLiDARAvailable ? "LiDAR Ready" : "LiDAR Not Available")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
            
            Spacer()
            
            if appState.isLiDARAvailable {
                Image(systemName: "wave.3.right")
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background {
            // iOS 26 Liquid Glass effect
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: appState.isLiDARAvailable ? .green.opacity(0.2) : .yellow.opacity(0.2), radius: 10, y: 5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(appState.isLiDARAvailable ? "LiDAR sensor is ready for obstacle detection" : "LiDAR not available on this device. Some features may be limited.")
    }
    
    // MARK: - Mode Cards Section
    
    private var modeCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Mode")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ModeCard(
                    mode: .navigation,
                    color: .blue
                ) {
                    appState.switchMode(to: .navigation)
                }
                
                ModeCard(
                    mode: .textReading,
                    color: .green
                ) {
                    appState.switchMode(to: .textReading)
                }
                
                ModeCard(
                    mode: .objectAwareness,
                    color: .purple
                ) {
                    appState.switchMode(to: .objectAwareness)
                }
            }
        }
    }
    
    // MARK: - Quick Settings Section
    
    private var quickSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Settings")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Toggle(isOn: $appState.voiceCommandsEnabled) {
                HStack {
                    Image(systemName: "mic.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .orange)
                        .font(.title2)
                    Text("Voice Commands")
                        .foregroundColor(.white)
                }
            }
            .tint(.orange)
            .padding()
            .background {
                // iOS 26 Liquid Glass effect
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    }
            }
            .accessibilityLabel("Voice Commands")
            .accessibilityValue(appState.voiceCommandsEnabled ? "Enabled" : "Disabled")
            .accessibilityHint("Double tap to toggle voice commands")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
