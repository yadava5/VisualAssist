//
//  CommonObjectLabelTests.swift
//  VisualAssistTests
//
//  Unit tests for CommonObjectLabel enum
//

import XCTest
@testable import VisualAssist

final class CommonObjectLabelTests: XCTestCase {
    
    // MARK: - Raw Value Tests
    
    func testRawValues_SimpleLabels() {
        XCTAssertEqual(CommonObjectLabel.person.rawValue, "person")
        XCTAssertEqual(CommonObjectLabel.car.rawValue, "car")
        XCTAssertEqual(CommonObjectLabel.chair.rawValue, "chair")
        XCTAssertEqual(CommonObjectLabel.laptop.rawValue, "laptop")
    }
    
    func testRawValues_CompoundLabels() {
        XCTAssertEqual(CommonObjectLabel.trafficLight.rawValue, "traffic light")
        XCTAssertEqual(CommonObjectLabel.fireHydrant.rawValue, "fire hydrant")
        XCTAssertEqual(CommonObjectLabel.stopSign.rawValue, "stop sign")
        XCTAssertEqual(CommonObjectLabel.sportsBall.rawValue, "sports ball")
        XCTAssertEqual(CommonObjectLabel.hotDog.rawValue, "hot dog")
        XCTAssertEqual(CommonObjectLabel.cellPhone.rawValue, "cell phone")
        XCTAssertEqual(CommonObjectLabel.teddyBear.rawValue, "teddy bear")
    }
    
    // MARK: - Category Tests
    
    func testCategory_Person() {
        XCTAssertEqual(CommonObjectLabel.person.category, .person)
    }
    
    func testCategory_Vehicles() {
        XCTAssertEqual(CommonObjectLabel.car.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.bicycle.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.motorcycle.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.bus.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.truck.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.airplane.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.train.category, .vehicle)
        XCTAssertEqual(CommonObjectLabel.boat.category, .vehicle)
    }
    
    func testCategory_Furniture() {
        XCTAssertEqual(CommonObjectLabel.chair.category, .furniture)
        XCTAssertEqual(CommonObjectLabel.couch.category, .furniture)
        XCTAssertEqual(CommonObjectLabel.bed.category, .furniture)
        XCTAssertEqual(CommonObjectLabel.diningTable.category, .furniture)
        XCTAssertEqual(CommonObjectLabel.toilet.category, .furniture)
        XCTAssertEqual(CommonObjectLabel.bench.category, .furniture)
    }
    
    func testCategory_Electronics() {
        XCTAssertEqual(CommonObjectLabel.tv.category, .electronics)
        XCTAssertEqual(CommonObjectLabel.laptop.category, .electronics)
        XCTAssertEqual(CommonObjectLabel.cellPhone.category, .electronics)
        XCTAssertEqual(CommonObjectLabel.keyboard.category, .electronics)
        XCTAssertEqual(CommonObjectLabel.microwave.category, .electronics)
        XCTAssertEqual(CommonObjectLabel.refrigerator.category, .electronics)
    }
    
    func testCategory_Food() {
        XCTAssertEqual(CommonObjectLabel.banana.category, .food)
        XCTAssertEqual(CommonObjectLabel.apple.category, .food)
        XCTAssertEqual(CommonObjectLabel.pizza.category, .food)
        XCTAssertEqual(CommonObjectLabel.sandwich.category, .food)
        XCTAssertEqual(CommonObjectLabel.cake.category, .food)
        XCTAssertEqual(CommonObjectLabel.hotDog.category, .food)
    }
    
    func testCategory_Animals() {
        XCTAssertEqual(CommonObjectLabel.dog.category, .animal)
        XCTAssertEqual(CommonObjectLabel.cat.category, .animal)
        XCTAssertEqual(CommonObjectLabel.bird.category, .animal)
        XCTAssertEqual(CommonObjectLabel.horse.category, .animal)
        XCTAssertEqual(CommonObjectLabel.elephant.category, .animal)
        XCTAssertEqual(CommonObjectLabel.giraffe.category, .animal)
    }
    
    func testCategory_Other() {
        XCTAssertEqual(CommonObjectLabel.backpack.category, .other)
        XCTAssertEqual(CommonObjectLabel.umbrella.category, .other)
        XCTAssertEqual(CommonObjectLabel.book.category, .other)
        XCTAssertEqual(CommonObjectLabel.scissors.category, .other)
        XCTAssertEqual(CommonObjectLabel.vase.category, .other)
    }
    
    // MARK: - CaseIterable Tests
    
    func testAllCases_Count() {
        // COCO dataset has 80 classes, we have a subset
        XCTAssertGreaterThan(CommonObjectLabel.allCases.count, 50, "Should have a substantial number of labels")
    }
    
    func testAllCases_UniqueRawValues() {
        let rawValues = CommonObjectLabel.allCases.map { $0.rawValue }
        let uniqueValues = Set(rawValues)
        XCTAssertEqual(rawValues.count, uniqueValues.count, "All raw values should be unique")
    }
}
