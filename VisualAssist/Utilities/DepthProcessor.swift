//
//  DepthProcessor.swift
//  VisualAssist
//
//  Utilities for processing LiDAR depth data
//

import Foundation
import ARKit
import simd

/// Utilities for processing depth map data from LiDAR
struct DepthProcessor {
    
    // MARK: - Depth Map Analysis
    
    /// Extract depth values from a depth map at specific regions
    static func analyzeDepthMap(_ depthMap: CVPixelBuffer) -> DepthAnalysisResult {
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return DepthAnalysisResult.empty
        }
        
        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        
        // Analyze different zones
        let leftZone = analyzeZone(floatBuffer, width: width, height: height, zone: .left)
        let centerZone = analyzeZone(floatBuffer, width: width, height: height, zone: .center)
        let rightZone = analyzeZone(floatBuffer, width: width, height: height, zone: .right)
        
        // Find overall nearest
        let allDistances = [leftZone.minDistance, centerZone.minDistance, rightZone.minDistance]
        let nearestDistance = allDistances.min() ?? .infinity
        
        let nearestDirection: ObstacleDirection
        if nearestDistance == leftZone.minDistance {
            nearestDirection = .left
        } else if nearestDistance == rightZone.minDistance {
            nearestDirection = .right
        } else {
            nearestDirection = .center
        }
        
        return DepthAnalysisResult(
            leftZone: leftZone,
            centerZone: centerZone,
            rightZone: rightZone,
            nearestDistance: nearestDistance,
            nearestDirection: nearestDirection
        )
    }
    
    /// Analyze a specific zone of the depth map
    private static func analyzeZone(_ buffer: UnsafeMutablePointer<Float32>,
                                    width: Int,
                                    height: Int,
                                    zone: DepthZone) -> ZoneAnalysis {
        let (startX, endX) = zone.xRange(width: width)
        let startY = height / 4
        let endY = 3 * height / 4
        
        var minDistance: Float = .infinity
        var avgDistance: Float = 0
        var validCount = 0
        var obstaclePixels = 0
        
        // Sample every 4th pixel for performance
        for y in stride(from: startY, to: endY, by: 4) {
            for x in stride(from: startX, to: endX, by: 4) {
                let index = y * width + x
                let depth = buffer[index]
                
                // Valid depth range (0.1m to 10m)
                guard depth > 0.1 && depth < 10 else { continue }
                
                minDistance = min(minDistance, depth)
                avgDistance += depth
                validCount += 1
                
                // Count pixels within warning distance
                if depth < 2.0 {
                    obstaclePixels += 1
                }
            }
        }
        
        if validCount > 0 {
            avgDistance /= Float(validCount)
        } else {
            avgDistance = .infinity
        }
        
        return ZoneAnalysis(
            minDistance: minDistance,
            avgDistance: avgDistance,
            obstaclePresence: Float(obstaclePixels) / Float(max(validCount, 1))
        )
    }
    
    // MARK: - Floor Detection
    
    /// Detect floor level changes (steps, curbs)
    static func detectFloorChanges(_ depthMap: CVPixelBuffer) -> FloorChangeResult? {
        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap) else {
            return nil
        }
        
        let floatBuffer = baseAddress.assumingMemoryBound(to: Float32.self)
        
        // Analyze bottom portion of frame (where floor would be)
        let bottomStart = 3 * height / 4
        let centerX = width / 2
        let sampleWidth = width / 4
        
        var floorDepths: [Float] = []
        
        for y in stride(from: bottomStart, to: height, by: 2) {
            for x in stride(from: centerX - sampleWidth / 2, to: centerX + sampleWidth / 2, by: 4) {
                let index = y * width + x
                let depth = floatBuffer[index]
                if depth > 0.1 && depth < 5 {
                    floorDepths.append(depth)
                }
            }
        }
        
        guard floorDepths.count > 10 else { return nil }
        
        // Look for significant depth discontinuities
        let sorted = floorDepths.sorted()
        let median = sorted[sorted.count / 2]
        
        // Check for step up (closer depth) or step down (further depth)
        let closeCount = floorDepths.filter { $0 < median - 0.15 }.count
        let farCount = floorDepths.filter { $0 > median + 0.15 }.count
        
        if closeCount > floorDepths.count / 4 {
            return FloorChangeResult(type: .stepUp, estimatedHeight: 0.15, confidence: Float(closeCount) / Float(floorDepths.count))
        }
        
        if farCount > floorDepths.count / 4 {
            return FloorChangeResult(type: .stepDown, estimatedHeight: 0.15, confidence: Float(farCount) / Float(floorDepths.count))
        }
        
        return nil
    }
}

// MARK: - Supporting Types

enum DepthZone {
    case left, center, right
    
    func xRange(width: Int) -> (Int, Int) {
        switch self {
        case .left: return (0, width / 3)
        case .center: return (width / 3, 2 * width / 3)
        case .right: return (2 * width / 3, width)
        }
    }
}

struct ZoneAnalysis {
    let minDistance: Float
    let avgDistance: Float
    let obstaclePresence: Float // 0-1, how much of zone has obstacles
}

struct DepthAnalysisResult {
    let leftZone: ZoneAnalysis
    let centerZone: ZoneAnalysis
    let rightZone: ZoneAnalysis
    let nearestDistance: Float
    let nearestDirection: ObstacleDirection
    
    static var empty: DepthAnalysisResult {
        let emptyZone = ZoneAnalysis(minDistance: .infinity, avgDistance: .infinity, obstaclePresence: 0)
        return DepthAnalysisResult(
            leftZone: emptyZone,
            centerZone: emptyZone,
            rightZone: emptyZone,
            nearestDistance: .infinity,
            nearestDirection: .center
        )
    }
}

struct FloorChangeResult {
    enum ChangeType {
        case stepUp, stepDown, slope
    }
    
    let type: ChangeType
    let estimatedHeight: Float
    let confidence: Float
    
    var description: String {
        switch type {
        case .stepUp: return "Step up detected ahead"
        case .stepDown: return "Step down or drop detected ahead"
        case .slope: return "Slope detected ahead"
        }
    }
}
