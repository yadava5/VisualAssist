//
//  RecognizedTextTests.swift
//  VisualAssistTests
//
//  Unit tests for RecognizedText model
//

import XCTest
@testable import VisualAssist

final class RecognizedTextTests: XCTestCase {
    
    // MARK: - RecognizedText Tests
    
    func testIsHeading_LargeText() {
        // Given
        let text = RecognizedText(
            text: "Welcome",
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.08),
            confidence: 0.95,
            language: "en",
            timestamp: Date()
        )
        
        // Then
        XCTAssertTrue(text.isHeading, "Text with height > 0.05 should be a heading")
    }
    
    func testIsHeading_SmallText() {
        // Given
        let text = RecognizedText(
            text: "Small body text",
            boundingBox: CGRect(x: 0.1, y: 0.5, width: 0.8, height: 0.03),
            confidence: 0.90,
            language: "en",
            timestamp: Date()
        )
        
        // Then
        XCTAssertFalse(text.isHeading, "Text with height <= 0.05 should not be a heading")
    }
    
    // MARK: - RecognizedDocument Tests
    
    func testFullText_OrderedByPosition() {
        // Given
        let topText = RecognizedText(
            text: "Title",
            boundingBox: CGRect(x: 0.1, y: 0.8, width: 0.3, height: 0.06),
            confidence: 0.95,
            language: "en",
            timestamp: Date()
        )
        
        let bottomText = RecognizedText(
            text: "Footer",
            boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.3, height: 0.03),
            confidence: 0.90,
            language: "en",
            timestamp: Date()
        )
        
        let document = RecognizedDocument(
            blocks: [bottomText, topText],
            timestamp: Date()
        )
        
        // When
        let fullText = document.fullText
        
        // Then
        XCTAssertTrue(fullText.hasPrefix("Title"), "Top text (higher Y) should come first")
    }
    
    func testAverageConfidence() {
        // Given
        let text1 = RecognizedText(
            text: "Hello",
            boundingBox: CGRect(x: 0, y: 0, width: 0.5, height: 0.1),
            confidence: 0.8,
            language: nil,
            timestamp: Date()
        )
        
        let text2 = RecognizedText(
            text: "World",
            boundingBox: CGRect(x: 0.5, y: 0, width: 0.5, height: 0.1),
            confidence: 1.0,
            language: nil,
            timestamp: Date()
        )
        
        let document = RecognizedDocument(
            blocks: [text1, text2],
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(document.averageConfidence, 0.9, accuracy: 0.01)
    }
    
    func testAverageConfidence_EmptyDocument() {
        // Given
        let document = RecognizedDocument(blocks: [], timestamp: Date())
        
        // Then
        XCTAssertEqual(document.averageConfidence, 0)
    }
    
    func testHeadingsAndBodyText() {
        // Given
        let heading = RecognizedText(
            text: "Chapter 1",
            boundingBox: CGRect(x: 0.1, y: 0.9, width: 0.8, height: 0.08),
            confidence: 0.95,
            language: "en",
            timestamp: Date()
        )
        
        let body = RecognizedText(
            text: "This is the body text.",
            boundingBox: CGRect(x: 0.1, y: 0.5, width: 0.8, height: 0.03),
            confidence: 0.90,
            language: "en",
            timestamp: Date()
        )
        
        let document = RecognizedDocument(
            blocks: [heading, body],
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(document.headings.count, 1)
        XCTAssertEqual(document.bodyText.count, 1)
        XCTAssertEqual(document.headings.first?.text, "Chapter 1")
        XCTAssertEqual(document.bodyText.first?.text, "This is the body text.")
    }
}
