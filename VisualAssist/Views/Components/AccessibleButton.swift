//
//  AccessibleButton.swift
//  VisualAssist
//
//  Accessible button component - iOS 26 Liquid Glass Design
//

import SwiftUI

enum ButtonSize {
    case small, medium, large
    
    var dimension: CGFloat {
        switch self {
        case .small: return 64
        case .medium: return 76
        case .large: return 88
        }
    }
    
    var iconSize: Font {
        switch self {
        case .small: return .title3
        case .medium: return .title2
        case .large: return .title
        }
    }
}

struct AccessibleButton: View {
    let icon: String
    let label: String
    let color: Color
    var size: ButtonSize = .medium
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(size.iconSize)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, color)
                    .symbolEffect(.bounce, value: isPressed)
                
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .frame(width: size.dimension, height: size.dimension)
            .background {
                // iOS 26 Liquid Glass effect
                ZStack {
                    // Glow layer
                    Circle()
                        .fill(color.opacity(0.3))
                        .blur(radius: 15)
                    
                    // Glass layer
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.4), color.opacity(0.3), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: color.opacity(0.4), radius: isPressed ? 4 : 12, y: isPressed ? 2 : 6)
                }
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

// Large primary action button with iOS 26 styling
struct PrimaryActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .symbolEffect(.bounce, value: isPressed)
                
                Text(label)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background {
                // iOS 26 Liquid Glass capsule
                ZStack {
                    // Glow
                    Capsule()
                        .fill(color.opacity(0.3))
                        .blur(radius: 20)
                    
                    // Glass
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), color.opacity(0.4), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(color: color.opacity(0.5), radius: isPressed ? 5 : 15, y: isPressed ? 3 : 8)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    VStack(spacing: 20) {
        AccessibleButton(icon: "play.fill", label: "Play", color: .green) {}
        AccessibleButton(icon: "location.fill", label: "Navigate", color: .blue, size: .large) {}
        PrimaryActionButton(icon: "camera.fill", label: "Start Scanning", color: .purple) {}
    }
    .padding()
    .background(Color.black)
}
