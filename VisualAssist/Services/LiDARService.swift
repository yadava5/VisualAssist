//
//  LiDARService.swift
//  VisualAssist
//
//  LiDAR-based depth sensing and obstacle detection using ARKit
//

import Foundation
import ARKit
import RealityKit
import Combine

/// Service for LiDAR-based obstacle detection
@MainActor
class LiDARService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    /// Whether LiDAR scanning is active
    @Published var isScanning = false
    
    /// Distance to nearest obstacle in meters
    @Published var nearestDistance: Float = .infinity
    
    /// Direction of nearest obstacle
    @Published var nearestDirection: String? = nil
    
    /// Distance in left zone (meters)
    @Published var leftDistance: Float = .infinity
    
    /// Distance in center zone (meters)
    @Published var centerDistance: Float = .infinity
    
    /// Distance in right zone (meters)
    @Published var rightDistance: Float = .infinity
    
    /// List of detected obstacles
    @Published var obstacles: [DetectedObstacle] = []
    
    /// Debug info
    @Published var debugInfo: String = ""
    
    /// Farthest point coordinates (normalized 0-1, for screen display)
    @Published var farthestPointX: CGFloat = 0.5
    @Published var farthestPointY: CGFloat = 0.5
    @Published var farthestDistance: Float = 0
    
    // MARK: - Private Properties
    
    private var arView: ARView?
    private var arSession: ARSession?
    private var configuration: ARWorldTrackingConfiguration?
    
    private let speechService = SpeechService()
    private let hapticService = HapticService()
    
    private var lastAnnouncementTime: Date = .distantPast
    private let announcementCooldown: TimeInterval = 3.0
    
    private var lastHapticTime: Date = .distantPast
    private let hapticCooldown: TimeInterval = 0.5
    
    // Distance thresholds
    private let criticalDistance: Float = 0.5  // meters
    private let warningDistance: Float = 1.0
    private let cautionDistance: Float = 2.0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupConfiguration()
    }
    
    // MARK: - Setup
    
    private func setupConfiguration() {
        configuration = ARWorldTrackingConfiguration()
        
        // Enable scene depth if available (requires LiDAR)
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration?.frameSemantics.insert(.sceneDepth)
        }
        
        // Enable smooth depth for better quality
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            configuration?.frameSemantics.insert(.smoothedSceneDepth)
        }
        
        // Enable scene reconstruction for mesh-based detection
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration?.sceneReconstruction = .mesh
        }
    }
    
    /// Setup the AR view for scanning
    func setupARView(_ arView: ARView) {
        self.arView = arView
        self.arSession = arView.session
        arView.session.delegate = self
        
        // Configure AR view for accessibility
        arView.environment.background = .cameraFeed()
    }
    
    // MARK: - Scanning Control
    
    /// Start LiDAR scanning
    func startScanning() {
        guard let configuration = configuration,
              let arSession = arSession else { return }
        
        arSession.run(configuration)
        isScanning = true
        
        speechService.speak("Navigation mode started. I will announce obstacles as you move.")
        hapticService.play(.modeSwitch)
    }
    
    /// Stop LiDAR scanning
    func stopScanning() {
        arSession?.pause()
        isScanning = false
    }
    
    /// Pause scanning temporarily
    func pauseScanning() {
        arSession?.pause()
        isScanning = false
        speechService.speak("Scanning paused")
        hapticService.play(.tap)
    }
    
    /// Resume scanning
    func resumeScanning() {
        guard let configuration = configuration else { return }
        arSession?.run(configuration)
        isScanning = true
        speechService.speak("Scanning resumed")
        hapticService.play(.tap)
    }
    
    /// Announce current surroundings with distances
    func announceSurroundings() {
        var description = ""
        
        // Describe each zone with exact distances
        if leftDistance < cautionDistance {
            description += "Left: \(formatDistance(leftDistance)). "
        } else {
            description += "Left: clear. "
        }
        
        if centerDistance < cautionDistance {
            description += "Ahead: \(formatDistance(centerDistance)). "
        } else {
            description += "Ahead: clear. "
        }
        
        if rightDistance < cautionDistance {
            description += "Right: \(formatDistance(rightDistance)). "
        } else {
            description += "Right: clear. "
        }
        
        // Add nearest obstacle summary
        if nearestDistance < cautionDistance {
            description += "Nearest obstacle is \(formatDistance(nearestDistance)) \(nearestDirection ?? "ahead")."
        } else {
            description += "Path is clear."
        }
        
        speechService.speak(description)
        hapticService.play(.success)
    }
    
    // MARK: - Depth Processing
    
    private func processDepthFrame(_ frame: ARFrame) {
        // Prefer smoothed depth if available
        guard let depthMap = frame.smoothedSceneDepth?.depthMap ?? frame.sceneDepth?.depthMap else {
            debugInfo = "No depth data"
            return
        }
        
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else { return }
        
        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        
        // IMPORTANT: In portrait mode on iPhone, the depth buffer is rotated!
        // The depth buffer's X axis corresponds to the screen's vertical direction
        // The depth buffer's Y axis corresponds to the screen's horizontal direction
        //
        // For a user holding the phone in portrait:
        // - Buffer X going from 0 to width = Screen BOTTOM to TOP
        // - Buffer Y going from 0 to height = Screen RIGHT to LEFT
        //
        // So for LEFT/RIGHT zones, we need to use the HEIGHT dimension (Y axis)
        // And for vertical center, we use the WIDTH dimension (X axis)
        
        // Define horizontal zones based on buffer's Y axis (which is screen's horizontal)
        // Y=0 is screen RIGHT, Y=height is screen LEFT
        let rightZoneEnd = height / 3        // First third of Y = RIGHT side of screen
        let leftZoneStart = 2 * height / 3   // Last third of Y = LEFT side of screen
        
        // Sample vertical center (middle portion of buffer's X axis)
        let verticalStart = width / 4
        let verticalEnd = 3 * width / 4
        
        var leftMin: Float = .infinity
        var centerMin: Float = .infinity
        var rightMin: Float = .infinity
        
        var validSamples = 0
        
        // Track farthest point
        var maxDepth: Float = 0
        var maxDepthX: Int = width / 2
        var maxDepthY: Int = height / 2
        
        // Process depth data
        // x = buffer column (maps to screen vertical)
        // y = buffer row (maps to screen horizontal - inverted: 0=right, max=left)
        for x in stride(from: verticalStart, to: verticalEnd, by: 4) {
            for y in stride(from: 0, to: height, by: 4) {
                let index = x * height + y
                guard index < width * height else { continue }
                
                // Note: depth buffer might be stored row-major
                let rowMajorIndex = y * width + x
                guard rowMajorIndex < width * height else { continue }
                
                let depth = floatBuffer[rowMajorIndex]
                
                // Ignore invalid depth values
                guard depth > 0 && depth < 10 else { continue }
                
                validSamples += 1
                
                // Track farthest point (most clear space)
                if depth > maxDepth {
                    maxDepth = depth
                    maxDepthX = x
                    maxDepthY = y
                }
                
                // Y axis: 0 = screen right, height = screen left
                if y < rightZoneEnd {
                    rightMin = min(rightMin, depth)
                } else if y >= leftZoneStart {
                    leftMin = min(leftMin, depth)
                } else {
                    centerMin = min(centerMin, depth)
                }
            }
        }
        
        // Update debug info
        debugInfo = "Size: \(width)x\(height), Samples: \(validSamples)"
        
        // Console debug output
        print("[LiDAR] Buffer: \(width)x\(height), Samples: \(validSamples)")
        print("[LiDAR] Left: \(String(format: "%.2f", leftMin))m, Center: \(String(format: "%.2f", centerMin))m, Right: \(String(format: "%.2f", rightMin))m")
        print("[LiDAR] Farthest: \(String(format: "%.2f", maxDepth))m at buffer(\(maxDepthX), \(maxDepthY))")
        
        // Update published values
        leftDistance = leftMin
        centerDistance = centerMin
        rightDistance = rightMin
        
        // Update farthest point - convert buffer coords to screen coords
        // Buffer X (0 to width) = Screen BOTTOM to TOP, so Y screen = 1 - (x/width)
        // Buffer Y (0 to height) = Screen RIGHT to LEFT, so X screen = 1 - (y/height)
        farthestPointX = 1.0 - CGFloat(maxDepthY) / CGFloat(height)
        farthestPointY = 1.0 - CGFloat(maxDepthX) / CGFloat(width)
        farthestDistance = maxDepth
        
        // Find nearest overall
        let allDistances = [(leftMin, "on your left"), (centerMin, "ahead"), (rightMin, "on your right")]
        if let nearest = allDistances.min(by: { $0.0 < $1.0 }) {
            nearestDistance = nearest.0
            nearestDirection = nearest.1
        }
        
        // Check for alerts with distance announcements
        checkForAlerts()
    }
    
    private func checkForAlerts() {
        let now = Date()
        
        // Haptic feedback (more frequent)
        if now.timeIntervalSince(lastHapticTime) > hapticCooldown {
            if nearestDistance < criticalDistance {
                hapticService.play(.critical)
                lastHapticTime = now
            } else if nearestDistance < warningDistance {
                hapticService.play(.warning)
                lastHapticTime = now
            }
        }
        
        // Voice announcements (less frequent to avoid spam)
        guard now.timeIntervalSince(lastAnnouncementTime) > announcementCooldown else { return }
        
        // Critical alert (< 0.5m) - always announce
        if nearestDistance < criticalDistance {
            lastAnnouncementTime = now
            let distanceStr = formatDistance(nearestDistance)
            speechService.speakNow("Stop! Obstacle \(nearestDirection ?? "ahead") at \(distanceStr)")
            return
        }
        
        // Warning alert (< 1m)
        if nearestDistance < warningDistance {
            lastAnnouncementTime = now
            let distanceStr = formatDistance(nearestDistance)
            speechService.speakNow("Caution, \(distanceStr) \(nearestDirection ?? "ahead")")
            return
        }
    }
    
    // MARK: - Helpers
    
    private func formatDistance(_ distance: Float) -> String {
        if distance == .infinity { return "clear" }
        if distance < 1 {
            return "\(Int(distance * 100)) centimeters"
        }
        return String(format: "%.1f meters", distance)
    }
}

// MARK: - ARSessionDelegate

extension LiDARService: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            processDepthFrame(frame)
        }
    }
    
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            isScanning = false
            debugInfo = "Error: \(error.localizedDescription)"
            speechService.speak("LiDAR error. Please restart navigation mode.")
        }
    }
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            isScanning = false
            speechService.speak("Scanning interrupted")
        }
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in
            if let configuration = configuration {
                session.run(configuration)
                isScanning = true
            }
            speechService.speak("Scanning resumed")
        }
    }
}
