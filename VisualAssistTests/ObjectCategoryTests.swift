//
//  ObjectCategoryTests.swift
//  VisualAssistTests
//
//  Unit tests for ObjectCategory and DetectedObject
//

import XCTest
@testable import VisualAssist

final class ObjectCategoryTests: XCTestCase {
    
    // MARK: - Category from Label Tests
    
    func testCategoryFromLabel_Person() {
        XCTAssertEqual(ObjectCategory.from(label: "person"), .person)
        XCTAssertEqual(ObjectCategory.from(label: "Woman walking"), .person)
        XCTAssertEqual(ObjectCategory.from(label: "child"), .person)
        XCTAssertEqual(ObjectCategory.from(label: "MAN"), .person)
    }
    
    func testCategoryFromLabel_Vehicle() {
        XCTAssertEqual(ObjectCategory.from(label: "car"), .vehicle)
        XCTAssertEqual(ObjectCategory.from(label: "Truck"), .vehicle)
        XCTAssertEqual(ObjectCategory.from(label: "red bicycle"), .vehicle)
        XCTAssertEqual(ObjectCategory.from(label: "motorcycle"), .vehicle)
        XCTAssertEqual(ObjectCategory.from(label: "city bus"), .vehicle)
    }
    
    func testCategoryFromLabel_Furniture() {
        XCTAssertEqual(ObjectCategory.from(label: "chair"), .furniture)
        XCTAssertEqual(ObjectCategory.from(label: "dining table"), .furniture)
        XCTAssertEqual(ObjectCategory.from(label: "sofa"), .furniture)
        XCTAssertEqual(ObjectCategory.from(label: "bed"), .furniture)
    }
    
    func testCategoryFromLabel_Electronics() {
        XCTAssertEqual(ObjectCategory.from(label: "laptop"), .electronics)
        XCTAssertEqual(ObjectCategory.from(label: "cell phone"), .electronics)
        XCTAssertEqual(ObjectCategory.from(label: "tv screen"), .electronics)
        XCTAssertEqual(ObjectCategory.from(label: "keyboard"), .electronics)
    }
    
    func testCategoryFromLabel_Food() {
        XCTAssertEqual(ObjectCategory.from(label: "apple"), .food)
        XCTAssertEqual(ObjectCategory.from(label: "pizza slice"), .food)
        XCTAssertEqual(ObjectCategory.from(label: "banana"), .food)
        XCTAssertEqual(ObjectCategory.from(label: "birthday cake"), .food)
    }
    
    func testCategoryFromLabel_Animal() {
        XCTAssertEqual(ObjectCategory.from(label: "dog"), .animal)
        XCTAssertEqual(ObjectCategory.from(label: "cat"), .animal)
        XCTAssertEqual(ObjectCategory.from(label: "bird"), .animal)
        XCTAssertEqual(ObjectCategory.from(label: "horse"), .animal)
    }
    
    func testCategoryFromLabel_Other() {
        XCTAssertEqual(ObjectCategory.from(label: "umbrella"), .other)
        XCTAssertEqual(ObjectCategory.from(label: "book"), .other)
        XCTAssertEqual(ObjectCategory.from(label: "vase"), .other)
    }
    
    // MARK: - Category Icon Tests
    
    func testCategoryIcons() {
        XCTAssertEqual(ObjectCategory.person.icon, "person.fill")
        XCTAssertEqual(ObjectCategory.vehicle.icon, "car.fill")
        XCTAssertEqual(ObjectCategory.furniture.icon, "chair.fill")
        XCTAssertEqual(ObjectCategory.electronics.icon, "desktopcomputer")
        XCTAssertEqual(ObjectCategory.food.icon, "fork.knife")
        XCTAssertEqual(ObjectCategory.animal.icon, "pawprint.fill")
        XCTAssertEqual(ObjectCategory.other.icon, "cube.fill")
    }
    
    // MARK: - DetectedObject Tests
    
    func testDetectedObject_HasUniqueId() {
        // Given
        let object1 = DetectedObject(
            label: "person",
            confidence: 0.95,
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.5),
            category: .person
        )
        
        let object2 = DetectedObject(
            label: "person",
            confidence: 0.95,
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.5),
            category: .person
        )
        
        // Then
        XCTAssertNotEqual(object1.id, object2.id, "Each DetectedObject should have a unique ID")
    }
}
