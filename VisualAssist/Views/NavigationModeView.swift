//
//  NavigationModeView.swift
//  VisualAssist
//
//  LiDAR-based obstacle detection and navigation assistance
//

import SwiftUI
import ARKit
import RealityKit

struct NavigationModeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var lidarService = LiDARService()
    @State private var showDebugView = false
    
    var body: some View {
        ZStack {
            // AR View for LiDAR scanning
            ARViewContainer(lidarService: lidarService)
                .ignoresSafeArea()
            
            // Farthest point indicator (shows where most clear space is)
            GeometryReader { geo in
                FarthestPointIndicator(
                    x: lidarService.farthestPointX,
                    y: lidarService.farthestPointY,
                    distance: lidarService.farthestDistance,
                    screenSize: geo.size
                )
            }
            .ignoresSafeArea()
            
            // Center pointer crosshair
            DeviceLevelIndicator(showCenterPointer: true)
            
            // Debug overlay (when enabled)
            if showDebugView {
                DebugOverlay(lidarService: lidarService)
            }
            
            // Overlay with obstacle information
            VStack {
                // Top bar with back button and status
                topBar
                
                Spacer()
                
                // Obstacle indicators
                obstacleIndicators
                
                // Distance display
                distanceDisplay
                
                // Control buttons
                controlButtons
            }
            .padding()
        }
        .onAppear {
            lidarService.startScanning()
            appState.hapticService.play(.modeSwitch)
        }
        .onDisappear {
            lidarService.stopScanning()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: { appState.switchMode(to: .home) }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
            }
            .accessibilityLabel("Back to home")
            .accessibilityHint("Double tap to return to home screen")
            
            Spacer()
            
            // Debug toggle
            Button(action: { showDebugView.toggle() }) {
                Image(systemName: showDebugView ? "ladybug.fill" : "ladybug")
                    .font(.title2)
                    .foregroundColor(showDebugView ? .yellow : .white)
                    .padding(10)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)
            }
            .accessibilityLabel(showDebugView ? "Hide debug view" : "Show debug view")
            
            // Scanning indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(lidarService.isScanning ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                Text(lidarService.isScanning ? "Scanning" : "Paused")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
            .accessibilityLabel(lidarService.isScanning ? "LiDAR scanning active" : "LiDAR scanning paused")
        }
    }
    
    // MARK: - Obstacle Indicators
    
    private var obstacleIndicators: some View {
        HStack(spacing: 20) {
            // Left zone
            ObstacleZoneIndicator(
                zone: .left,
                distance: lidarService.leftDistance,
                alertLevel: alertLevel(for: lidarService.leftDistance)
            )
            
            // Center zone
            ObstacleZoneIndicator(
                zone: .center,
                distance: lidarService.centerDistance,
                alertLevel: alertLevel(for: lidarService.centerDistance)
            )
            
            // Right zone
            ObstacleZoneIndicator(
                zone: .right,
                distance: lidarService.rightDistance,
                alertLevel: alertLevel(for: lidarService.rightDistance)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Distance Display
    
    private var distanceDisplay: some View {
        VStack(spacing: 8) {
            Text("Nearest Obstacle")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(formatDistance(lidarService.nearestDistance))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colorForDistance(lidarService.nearestDistance))
            
            if let direction = lidarService.nearestDirection {
                Text(direction)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nearest obstacle at \(formatDistance(lidarService.nearestDistance))\(lidarService.nearestDirection.map { ", \($0)" } ?? "")")
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            // Pause/Resume button
            AccessibleButton(
                icon: lidarService.isScanning ? "pause.fill" : "play.fill",
                label: lidarService.isScanning ? "Pause" : "Resume",
                color: .orange
            ) {
                if lidarService.isScanning {
                    lidarService.pauseScanning()
                } else {
                    lidarService.resumeScanning()
                }
            }
            
            // Announce surroundings
            AccessibleButton(
                icon: "speaker.wave.3.fill",
                label: "Describe",
                color: .blue
            ) {
                lidarService.announceSurroundings()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func alertLevel(for distance: Float) -> AlertLevel {
        if distance < 0.5 { return .critical }
        if distance < 1.0 { return .warning }
        if distance < 2.0 { return .caution }
        return .safe
    }
    
    private func formatDistance(_ distance: Float) -> String {
        if distance == .infinity { return "Clear" }
        if distance < 1 {
            return String(format: "%.0f cm", distance * 100)
        }
        return String(format: "%.1f m", distance)
    }
    
    private func colorForDistance(_ distance: Float) -> Color {
        if distance < 0.5 { return .red }
        if distance < 1.0 { return .orange }
        if distance < 2.0 { return .yellow }
        return .green
    }
}

// MARK: - Debug Overlay

struct DebugOverlay: View {
    @ObservedObject var lidarService: LiDARService
    
    var body: some View {
        VStack {
            // Debug info panel at top
            VStack(alignment: .leading, spacing: 8) {
                Text("🔧 DEBUG MODE")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Divider()
                    .background(Color.yellow)
                
                // LiDAR Status
                HStack {
                    Text("LiDAR:")
                    Spacer()
                    Text(lidarService.isScanning ? "✅ Active" : "❌ Inactive")
                }
                
                // Distance readings
                Group {
                    HStack {
                        Text("Left:")
                        Spacer()
                        Text(formatDebugDistance(lidarService.leftDistance))
                            .foregroundColor(colorForDistance(lidarService.leftDistance))
                    }
                    
                    HStack {
                        Text("Center:")
                        Spacer()
                        Text(formatDebugDistance(lidarService.centerDistance))
                            .foregroundColor(colorForDistance(lidarService.centerDistance))
                    }
                    
                    HStack {
                        Text("Right:")
                        Spacer()
                        Text(formatDebugDistance(lidarService.rightDistance))
                            .foregroundColor(colorForDistance(lidarService.rightDistance))
                    }
                }
                
                Divider()
                    .background(Color.yellow)
                
                // Nearest obstacle
                HStack {
                    Text("Nearest:")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(formatDebugDistance(lidarService.nearestDistance))
                            .foregroundColor(colorForDistance(lidarService.nearestDistance))
                            .font(.headline)
                        if let direction = lidarService.nearestDirection {
                            Text(direction)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Frame rate indicator
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(lidarService.isScanning ? "Processing frames..." : "Paused")
                        .foregroundColor(lidarService.isScanning ? .green : .orange)
                }
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.yellow, lineWidth: 2)
                    )
            )
            .padding()
            
            Spacer()
            
            // Depth visualization bar
            DepthVisualizationBar(
                leftDistance: lidarService.leftDistance,
                centerDistance: lidarService.centerDistance,
                rightDistance: lidarService.rightDistance
            )
            .padding(.horizontal)
            .padding(.bottom, 200) // Above control buttons
        }
    }
    
    private func formatDebugDistance(_ distance: Float) -> String {
        if distance == .infinity { return "∞ (clear)" }
        return String(format: "%.2f m", distance)
    }
    
    private func colorForDistance(_ distance: Float) -> Color {
        if distance == .infinity { return .green }
        if distance < 0.5 { return .red }
        if distance < 1.0 { return .orange }
        if distance < 2.0 { return .yellow }
        return .green
    }
}

// MARK: - Depth Visualization Bar

struct DepthVisualizationBar: View {
    let leftDistance: Float
    let centerDistance: Float
    let rightDistance: Float
    
    var body: some View {
        VStack(spacing: 4) {
            Text("DEPTH VISUALIZATION")
                .font(.caption2)
                .foregroundColor(.yellow)
            
            HStack(spacing: 4) {
                // Left zone bar
                DepthBar(distance: leftDistance, label: "L")
                
                // Center zone bar
                DepthBar(distance: centerDistance, label: "C")
                
                // Right zone bar
                DepthBar(distance: rightDistance, label: "R")
            }
            .frame(height: 80)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
}

struct DepthBar: View {
    let distance: Float
    let label: String
    
    private var normalizedHeight: CGFloat {
        if distance == .infinity { return 1.0 }
        // Normalize: 0m = full bar, 5m = minimal bar
        let normalized = min(distance / 5.0, 1.0)
        return CGFloat(1.0 - normalized)
    }
    
    private var barColor: Color {
        if distance == .infinity { return .green }
        if distance < 0.5 { return .red }
        if distance < 1.0 { return .orange }
        if distance < 2.0 { return .yellow }
        return .green
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(height: geometry.size.height * normalizedHeight)
                        .animation(.easeInOut(duration: 0.2), value: distance)
                }
            }
            
            Text(label)
                .font(.caption2.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - Alert Level

enum AlertLevel {
    case safe, caution, warning, critical
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .caution: return .yellow
        case .warning: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Obstacle Zone

enum ObstacleZone: String {
    case left = "Left"
    case center = "Center"
    case right = "Right"
}

// MARK: - Obstacle Zone Indicator

struct ObstacleZoneIndicator: View {
    let zone: ObstacleZone
    let distance: Float
    let alertLevel: AlertLevel
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(alertLevel.color)
            
            Text(zone.rawValue)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(formatDistance())
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(alertLevel.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(alertLevel.color.opacity(0.5), lineWidth: 2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(zone.rawValue): \(formatDistance())")
    }
    
    private var iconName: String {
        switch zone {
        case .left: return "arrow.left"
        case .center: return "arrow.up"
        case .right: return "arrow.right"
        }
    }
    
    private func formatDistance() -> String {
        if distance == .infinity { return "Clear" }
        if distance < 1 { return String(format: "%.0fcm", distance * 100) }
        return String(format: "%.1fm", distance)
    }
}

// MARK: - Farthest Point Indicator

/// Shows where LiDAR detects the farthest/clear point
struct FarthestPointIndicator: View {
    let x: CGFloat        // Normalized 0-1
    let y: CGFloat        // Normalized 0-1
    let distance: Float   // Distance in meters
    let screenSize: CGSize
    
    var body: some View {
        // Only show if we have valid distance
        if distance > 0.5 {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 20)
                    .frame(width: 60, height: 60)
                    .blur(radius: 10)
                
                // Main ring
                Circle()
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: 40, height: 40)
                
                // Inner dot
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                
                // Distance label
                Text(String(format: "%.1fm", distance))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
                    .offset(y: 35)
            }
            .position(
                x: x * screenSize.width,
                y: y * screenSize.height
            )
        }
    }
}

// MARK: - AR View Container

struct ARViewContainer: UIViewRepresentable {
    let lidarService: LiDARService
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        lidarService.setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    NavigationModeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
