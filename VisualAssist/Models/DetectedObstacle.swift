//
//  DetectedObstacle.swift
//  VisualAssist
//
//  Model for detected obstacles from LiDAR
//

import Foundation
import simd

/// Represents an obstacle detected by LiDAR
struct DetectedObstacle: Identifiable {
    let id = UUID()
    
    /// Distance to the obstacle in meters
    let distance: Float
    
    /// Direction of the obstacle
    let direction: ObstacleDirection
    
    /// 3D position relative to the camera
    let position: SIMD3<Float>?
    
    /// Size estimate of the obstacle
    let estimatedSize: ObstacleSize
    
    /// Timestamp when detected
    let timestamp: Date
    
    /// Alert level based on distance
    var alertLevel: ObstacleAlertLevel {
        if distance < 0.5 { return .critical }
        if distance < 1.0 { return .warning }
        if distance < 2.0 { return .caution }
        return .safe
    }
    
    /// Human-readable description
    var description: String {
        let distanceStr: String
        if distance < 1 {
            distanceStr = "\(Int(distance * 100)) centimeters"
        } else {
            distanceStr = String(format: "%.1f meters", distance)
        }
        
        return "\(estimatedSize.rawValue) obstacle \(direction.description) at \(distanceStr)"
    }
}

// MARK: - Obstacle Direction

enum ObstacleDirection: String {
    case left = "left"
    case centerLeft = "center-left"
    case center = "center"
    case centerRight = "center-right"
    case right = "right"
    case above = "above"
    case below = "below"
    
    var description: String {
        switch self {
        case .left: return "on your left"
        case .centerLeft: return "slightly to your left"
        case .center: return "directly ahead"
        case .centerRight: return "slightly to your right"
        case .right: return "on your right"
        case .above: return "above you"
        case .below: return "below (possible step or drop)"
        }
    }
}

// MARK: - Obstacle Size

enum ObstacleSize: String {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case unknown = "Unknown"
    
    init(from area: Float) {
        if area < 0.1 { self = .small }
        else if area < 0.5 { self = .medium }
        else { self = .large }
    }
}

// MARK: - Alert Level

enum ObstacleAlertLevel: Int, Comparable {
    case safe = 0
    case caution = 1
    case warning = 2
    case critical = 3
    
    static func < (lhs: ObstacleAlertLevel, rhs: ObstacleAlertLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var hapticPattern: HapticPattern {
        switch self {
        case .safe: return .tap
        case .caution: return .tap
        case .warning: return .warning
        case .critical: return .critical
        }
    }
}
