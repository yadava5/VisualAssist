//
//  DepthProcessorTests.swift
//  VisualAssistTests
//
//  Unit tests for DepthProcessor utilities
//

import XCTest
@testable import VisualAssist

final class DepthProcessorTests: XCTestCase {
    
    // MARK: - DepthZone Tests
    
    func testDepthZone_LeftRange() {
        let width = 300
        let range = DepthZone.left.xRange(width: width)
        
        XCTAssertEqual(range.0, 0, "Left zone should start at 0")
        XCTAssertEqual(range.1, 100, "Left zone should end at width/3")
    }
    
    func testDepthZone_CenterRange() {
        let width = 300
        let range = DepthZone.center.xRange(width: width)
        
        XCTAssertEqual(range.0, 100, "Center zone should start at width/3")
        XCTAssertEqual(range.1, 200, "Center zone should end at 2*width/3")
    }
    
    func testDepthZone_RightRange() {
        let width = 300
        let range = DepthZone.right.xRange(width: width)
        
        XCTAssertEqual(range.0, 200, "Right zone should start at 2*width/3")
        XCTAssertEqual(range.1, 300, "Right zone should end at width")
    }
    
    // MARK: - ZoneAnalysis Tests
    
    func testZoneAnalysis_Properties() {
        let analysis = ZoneAnalysis(
            minDistance: 1.5,
            avgDistance: 3.0,
            obstaclePresence: 0.25
        )
        
        XCTAssertEqual(analysis.minDistance, 1.5)
        XCTAssertEqual(analysis.avgDistance, 3.0)
        XCTAssertEqual(analysis.obstaclePresence, 0.25)
    }
    
    // MARK: - DepthAnalysisResult Tests
    
    func testDepthAnalysisResult_Empty() {
        let result = DepthAnalysisResult.empty
        
        XCTAssertEqual(result.nearestDistance, .infinity)
        XCTAssertEqual(result.nearestDirection, .center)
        XCTAssertEqual(result.leftZone.minDistance, .infinity)
        XCTAssertEqual(result.centerZone.minDistance, .infinity)
        XCTAssertEqual(result.rightZone.minDistance, .infinity)
    }
    
    // MARK: - FloorChangeResult Tests
    
    func testFloorChangeResult_StepUp() {
        let result = FloorChangeResult(
            type: .stepUp,
            estimatedHeight: 0.15,
            confidence: 0.8
        )
        
        XCTAssertEqual(result.type, .stepUp)
        XCTAssertEqual(result.description, "Step up detected ahead")
    }
    
    func testFloorChangeResult_StepDown() {
        let result = FloorChangeResult(
            type: .stepDown,
            estimatedHeight: 0.20,
            confidence: 0.75
        )
        
        XCTAssertEqual(result.type, .stepDown)
        XCTAssertEqual(result.description, "Step down or drop detected ahead")
    }
    
    func testFloorChangeResult_Slope() {
        let result = FloorChangeResult(
            type: .slope,
            estimatedHeight: 0.10,
            confidence: 0.6
        )
        
        XCTAssertEqual(result.type, .slope)
        XCTAssertEqual(result.description, "Slope detected ahead")
    }
}
