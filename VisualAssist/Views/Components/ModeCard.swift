//
//  ModeCard.swift
//  VisualAssist
//
//  Card component for mode selection - iOS 26 Liquid Glass Design
//

import SwiftUI

struct ModeCard: View {
    let mode: AppMode
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovering = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 16) {
                // iOS 26 style icon with symbol effects
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.4), color.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                    
                    // Glass circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 26, weight: .medium))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, color)
                        .symbolEffect(.bounce, value: isPressed)
                }
                
                // Title
                Text(mode.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background {
                // iOS 26 Liquid Glass effect
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        color.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: color.opacity(0.2), radius: isPressed ? 5 : 15, y: isPressed ? 2 : 8)
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(mode.rawValue)
        .accessibilityHint(mode.description + ". Double tap to select.")
        .accessibilityAddTraits(.isButton)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }) {}
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
        ModeCard(mode: .navigation, color: .blue) {}
        ModeCard(mode: .textReading, color: .green) {}
        ModeCard(mode: .objectAwareness, color: .purple) {}
    }
    .padding()
    .background(Color.black)
}
