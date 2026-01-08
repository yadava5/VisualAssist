//
//  DetectionSummaryTests.swift
//  VisualAssistTests
//
//  Unit tests for DetectionSummary
//

import XCTest
@testable import VisualAssist

final class DetectionSummaryTests: XCTestCase {
    
    // MARK: - Empty Summary Tests
    
    func testSummary_Empty() {
        let summary = DetectionSummary(objects: [])
        
        XCTAssertEqual(summary.totalObjects, 0)
        XCTAssertEqual(summary.peopleCount, 0)
        XCTAssertTrue(summary.objectsByCategory.isEmpty)
        XCTAssertNil(summary.mostConfidentObject)
    }
    
    // MARK: - Single Object Tests
    
    func testSummary_SinglePerson() {
        let person = DetectedObject(
            label: "person",
            confidence: 0.95,
            boundingBox: CGRect(x: 0.3, y: 0.2, width: 0.4, height: 0.6),
            category: .person
        )
        
        let summary = DetectionSummary(objects: [person])
        
        XCTAssertEqual(summary.totalObjects, 1)
        XCTAssertEqual(summary.peopleCount, 1)
        XCTAssertEqual(summary.objectsByCategory[.person], 1)
        XCTAssertEqual(summary.mostConfidentObject?.label, "person")
        XCTAssertEqual(summary.mostConfidentObject?.confidence, 0.95)
    }
    
    // MARK: - Multiple Objects Tests
    
    func testSummary_MultipleObjects() {
        let objects = [
            DetectedObject(
                label: "person",
                confidence: 0.95,
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.5),
                category: .person
            ),
            DetectedObject(
                label: "person",
                confidence: 0.88,
                boundingBox: CGRect(x: 0.4, y: 0.2, width: 0.2, height: 0.5),
                category: .person
            ),
            DetectedObject(
                label: "car",
                confidence: 0.92,
                boundingBox: CGRect(x: 0.6, y: 0.3, width: 0.3, height: 0.3),
                category: .vehicle
            ),
            DetectedObject(
                label: "dog",
                confidence: 0.78,
                boundingBox: CGRect(x: 0.2, y: 0.6, width: 0.15, height: 0.15),
                category: .animal
            )
        ]
        
        let summary = DetectionSummary(objects: objects)
        
        XCTAssertEqual(summary.totalObjects, 4)
        XCTAssertEqual(summary.peopleCount, 2)
        XCTAssertEqual(summary.objectsByCategory[.person], 2)
        XCTAssertEqual(summary.objectsByCategory[.vehicle], 1)
        XCTAssertEqual(summary.objectsByCategory[.animal], 1)
        XCTAssertNil(summary.objectsByCategory[.furniture])
    }
    
    // MARK: - Most Confident Object Tests
    
    func testSummary_MostConfidentObject() {
        let objects = [
            DetectedObject(
                label: "chair",
                confidence: 0.65,
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.3),
                category: .furniture
            ),
            DetectedObject(
                label: "laptop",
                confidence: 0.99,
                boundingBox: CGRect(x: 0.4, y: 0.2, width: 0.2, height: 0.15),
                category: .electronics
            ),
            DetectedObject(
                label: "person",
                confidence: 0.85,
                boundingBox: CGRect(x: 0.6, y: 0.1, width: 0.3, height: 0.6),
                category: .person
            )
        ]
        
        let summary = DetectionSummary(objects: objects)
        
        XCTAssertEqual(summary.mostConfidentObject?.label, "laptop")
        XCTAssertEqual(summary.mostConfidentObject?.confidence, 0.99)
    }
    
    // MARK: - Category Distribution Tests
    
    func testSummary_CategoryDistribution() {
        let objects = [
            DetectedObject(label: "chair", confidence: 0.9, boundingBox: .zero, category: .furniture),
            DetectedObject(label: "table", confidence: 0.85, boundingBox: .zero, category: .furniture),
            DetectedObject(label: "couch", confidence: 0.8, boundingBox: .zero, category: .furniture),
            DetectedObject(label: "person", confidence: 0.95, boundingBox: .zero, category: .person)
        ]
        
        let summary = DetectionSummary(objects: objects)
        
        XCTAssertEqual(summary.objectsByCategory.count, 2, "Should have 2 categories")
        XCTAssertEqual(summary.objectsByCategory[.furniture], 3, "Should have 3 furniture items")
        XCTAssertEqual(summary.objectsByCategory[.person], 1, "Should have 1 person")
    }
}
