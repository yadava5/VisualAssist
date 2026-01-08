//
//  ObjectPositionTests.swift
//  VisualAssistTests
//
//  Unit tests for ObjectPosition enum
//

import XCTest
@testable import VisualAssist

final class ObjectPositionTests: XCTestCase {
    
    // MARK: - Position from Bounding Box Tests
    
    func testPosition_TopLeft() {
        // Vision coordinates: high Y = top
        let bbox = CGRect(x: 0.0, y: 0.8, width: 0.2, height: 0.15)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .topLeft)
    }
    
    func testPosition_TopCenter() {
        let bbox = CGRect(x: 0.4, y: 0.85, width: 0.2, height: 0.1)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .topCenter)
    }
    
    func testPosition_TopRight() {
        let bbox = CGRect(x: 0.75, y: 0.75, width: 0.2, height: 0.1)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .topRight)
    }
    
    func testPosition_MiddleLeft() {
        let bbox = CGRect(x: 0.05, y: 0.4, width: 0.2, height: 0.2)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .middleLeft)
    }
    
    func testPosition_Center() {
        let bbox = CGRect(x: 0.35, y: 0.4, width: 0.3, height: 0.2)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .center)
    }
    
    func testPosition_MiddleRight() {
        let bbox = CGRect(x: 0.7, y: 0.4, width: 0.25, height: 0.2)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .middleRight)
    }
    
    func testPosition_BottomLeft() {
        // Vision coordinates: low Y = bottom
        let bbox = CGRect(x: 0.0, y: 0.1, width: 0.2, height: 0.15)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .bottomLeft)
    }
    
    func testPosition_BottomCenter() {
        let bbox = CGRect(x: 0.4, y: 0.1, width: 0.2, height: 0.1)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .bottomCenter)
    }
    
    func testPosition_BottomRight() {
        let bbox = CGRect(x: 0.8, y: 0.05, width: 0.15, height: 0.2)
        let position = ObjectPosition(boundingBox: bbox)
        XCTAssertEqual(position, .bottomRight)
    }
    
    // MARK: - Position Description Tests
    
    func testPositionDescriptions() {
        XCTAssertEqual(ObjectPosition.topLeft.description, "top left")
        XCTAssertEqual(ObjectPosition.topCenter.description, "top")
        XCTAssertEqual(ObjectPosition.topRight.description, "top right")
        XCTAssertEqual(ObjectPosition.middleLeft.description, "left")
        XCTAssertEqual(ObjectPosition.center.description, "center")
        XCTAssertEqual(ObjectPosition.middleRight.description, "right")
        XCTAssertEqual(ObjectPosition.bottomLeft.description, "bottom left")
        XCTAssertEqual(ObjectPosition.bottomCenter.description, "bottom")
        XCTAssertEqual(ObjectPosition.bottomRight.description, "bottom right")
    }
}
