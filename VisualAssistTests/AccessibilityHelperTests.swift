//
//  AccessibilityHelperTests.swift
//  VisualAssistTests
//
//  Unit tests for AccessibilityHelper utilities
//

import XCTest
@testable import VisualAssist

final class AccessibilityHelperTests: XCTestCase {
    
    // MARK: - Number Formatting Tests
    
    func testFormatNumberForSpeech_WholeNumber() {
        let result = AccessibilityHelper.formatNumberForSpeech(5.0)
        XCTAssertEqual(result, "5")
    }
    
    func testFormatNumberForSpeech_Decimal() {
        let result = AccessibilityHelper.formatNumberForSpeech(2.5)
        XCTAssertEqual(result, "2 point 5")
    }
    
    func testFormatNumberForSpeech_SmallDecimal() {
        let result = AccessibilityHelper.formatNumberForSpeech(0.8)
        XCTAssertEqual(result, "0 point 8")
    }
    
    // MARK: - Distance Formatting Tests
    
    func testFormatDistanceForSpeech_Infinity() {
        let result = AccessibilityHelper.formatDistanceForSpeech(.infinity)
        XCTAssertEqual(result, "clear")
    }
    
    func testFormatDistanceForSpeech_Centimeters() {
        let result = AccessibilityHelper.formatDistanceForSpeech(0.75)
        XCTAssertEqual(result, "75 centimeters")
    }
    
    func testFormatDistanceForSpeech_Meters() {
        let result = AccessibilityHelper.formatDistanceForSpeech(2.5)
        XCTAssertEqual(result, "2 point 5 meters")
    }
    
    func testFormatDistanceForSpeech_OnePointFiveMeters() {
        let result = AccessibilityHelper.formatDistanceForSpeech(1.5)
        XCTAssertEqual(result, "1 point 5 meters")
    }
    
    func testFormatDistanceForSpeech_ExactlyOneMeter() {
        let result = AccessibilityHelper.formatDistanceForSpeech(1.0)
        XCTAssertEqual(result, "1 meters")
    }
    
    // MARK: - Obstacle Label Tests
    
    func testObstacleLabel_CenterClose() {
        let result = AccessibilityHelper.obstacleLabel(
            direction: .center,
            distance: 0.5
        )
        XCTAssertEqual(result, "Obstacle directly ahead at 50 centimeters")
    }
    
    func testObstacleLabel_LeftFar() {
        let result = AccessibilityHelper.obstacleLabel(
            direction: .left,
            distance: 3.0
        )
        XCTAssertEqual(result, "Obstacle on your left at 3 meters")
    }
    
    // MARK: - Objects Label Tests
    
    func testObjectsLabel_NoObjects() {
        let result = AccessibilityHelper.objectsLabel(objects: [])
        XCTAssertEqual(result, "No objects detected")
    }
    
    func testObjectsLabel_SingleObject() {
        let object = DetectedObject(
            label: "chair",
            confidence: 0.9,
            boundingBox: CGRect(x: 0.3, y: 0.3, width: 0.4, height: 0.4),
            category: .furniture
        )
        
        let result = AccessibilityHelper.objectsLabel(objects: [object])
        XCTAssertEqual(result, "One chair detected")
    }
    
    func testObjectsLabel_MultipleObjects() {
        let objects = [
            DetectedObject(
                label: "person",
                confidence: 0.95,
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.6),
                category: .person
            ),
            DetectedObject(
                label: "person",
                confidence: 0.88,
                boundingBox: CGRect(x: 0.5, y: 0.2, width: 0.3, height: 0.5),
                category: .person
            ),
            DetectedObject(
                label: "chair",
                confidence: 0.75,
                boundingBox: CGRect(x: 0.7, y: 0.4, width: 0.2, height: 0.3),
                category: .furniture
            )
        ]
        
        let result = AccessibilityHelper.objectsLabel(objects: objects)
        
        // Should contain both labels
        XCTAssertTrue(result.contains("2 persons"), "Should pluralize multiple persons")
        XCTAssertTrue(result.contains("one chair"), "Should include single chair")
        XCTAssertTrue(result.hasSuffix("detected"), "Should end with 'detected'")
    }
}
