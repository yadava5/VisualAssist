//
//  StatusOverlay.swift
//  VisualAssist
//
//  Status bar overlay - iOS 26 Liquid Glass Design
//

import SwiftUI

struct StatusOverlay: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Current mode indicator
            HStack(spacing: 8) {
                Image(systemName: appState.currentMode.icon)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, isActive: appState.isProcessing)
                
                Text(appState.currentMode.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Status indicators
            HStack(spacing: 14) {
                // LiDAR status
                if appState.isLiDARAvailable {
                    StatusIndicator(
                        icon: "sensor.fill",
                        color: .green,
                        label: "LiDAR",
                        isActive: true
                    )
                }
                
                // Voice commands status
                if appState.voiceCommandsEnabled {
                    StatusIndicator(
                        icon: "waveform.circle.fill",
                        color: .orange,
                        label: "Voice",
                        isActive: true
                    )
                }
                
                // Processing indicator
                if appState.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background {
            // iOS 26 Liquid Glass capsule
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(statusAccessibilityLabel)
    }
    
    private var statusAccessibilityLabel: String {
        var parts: [String] = []
        parts.append("Current mode: \(appState.currentMode.rawValue)")
        if appState.isLiDARAvailable {
            parts.append("LiDAR active")
        }
        if appState.voiceCommandsEnabled {
            parts.append("Voice commands enabled")
        }
        if appState.isProcessing {
            parts.append("Processing")
        }
        return parts.joined(separator: ". ")
    }
}

struct StatusIndicator: View {
    let icon: String
    let color: Color
    let label: String
    var isActive: Bool = false
    
    var body: some View {
        ZStack {
            // Subtle glow for active state
            if isActive {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .blur(radius: 6)
            }
            
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, color)
                .symbolEffect(.pulse, isActive: isActive)
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    VStack {
        Spacer()
        StatusOverlay()
    }
    .padding()
    .background(Color.gray)
    .environmentObject(AppState())
}
