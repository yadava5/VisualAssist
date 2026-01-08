//
//  DetectedObstacleTests.swift
//  VisualAssistTests
//
//  Unit tests for DetectedObstacle model
//

import XCTest
@testable import VisualAssist

final class DetectedObstacleTests: XCTestCase {
    
    // MARK: - Alert Level Tests
    
    func testAlertLevel_CriticalDistance() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 0.3,
            direction: .center,
            position: nil,
            estimatedSize: .medium,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(obstacle.alertLevel, .critical, "Distance < 0.5m should be critical")
    }
    
    func testAlertLevel_WarningDistance() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 0.7,
            direction: .center,
            position: nil,
            estimatedSize: .medium,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(obstacle.alertLevel, .warning, "Distance 0.5m-1.0m should be warning")
    }
    
    func testAlertLevel_CautionDistance() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 1.5,
            direction: .center,
            position: nil,
            estimatedSize: .medium,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(obstacle.alertLevel, .caution, "Distance 1.0m-2.0m should be caution")
    }
    
    func testAlertLevel_SafeDistance() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 3.0,
            direction: .center,
            position: nil,
            estimatedSize: .large,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(obstacle.alertLevel, .safe, "Distance > 2.0m should be safe")
    }
    
    // MARK: - Description Tests
    
    func testDescription_MetersFormat() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 2.5,
            direction: .left,
            position: nil,
            estimatedSize: .large,
            timestamp: Date()
        )
        
        // When
        let description = obstacle.description
        
        // Then
        XCTAssertTrue(description.contains("2.5 meters"), "Should format distance in meters")
        XCTAssertTrue(description.contains("Large"), "Should include size")
        XCTAssertTrue(description.contains("on your left"), "Should include direction")
    }
    
    func testDescription_CentimetersFormat() {
        // Given
        let obstacle = DetectedObstacle(
            distance: 0.65,
            direction: .center,
            position: nil,
            estimatedSize: .small,
            timestamp: Date()
        )
        
        // When
        let description = obstacle.description
        
        // Then
        XCTAssertTrue(description.contains("65 centimeters"), "Distance < 1m should be in centimeters")
    }
    
    // MARK: - Direction Tests
    
    func testObstacleDirection_Descriptions() {
        XCTAssertEqual(ObstacleDirection.left.description, "on your left")
        XCTAssertEqual(ObstacleDirection.center.description, "directly ahead")
        XCTAssertEqual(ObstacleDirection.right.description, "on your right")
        XCTAssertEqual(ObstacleDirection.centerLeft.description, "slightly to your left")
        XCTAssertEqual(ObstacleDirection.centerRight.description, "slightly to your right")
        XCTAssertEqual(ObstacleDirection.above.description, "above you")
        XCTAssertEqual(ObstacleDirection.below.description, "below (possible step or drop)")
    }
    
    // MARK: - Size Tests
    
    func testObstacleSize_FromArea() {
        XCTAssertEqual(ObstacleSize(from: 0.05), .small, "Area < 0.1 should be small")
        XCTAssertEqual(ObstacleSize(from: 0.3), .medium, "Area 0.1-0.5 should be medium")
        XCTAssertEqual(ObstacleSize(from: 0.8), .large, "Area >= 0.5 should be large")
    }
    
    // MARK: - Alert Level Comparison Tests
    
    func testAlertLevel_Comparable() {
        XCTAssertTrue(ObstacleAlertLevel.safe < ObstacleAlertLevel.caution)
        XCTAssertTrue(ObstacleAlertLevel.caution < ObstacleAlertLevel.warning)
        XCTAssertTrue(ObstacleAlertLevel.warning < ObstacleAlertLevel.critical)
    }
}
