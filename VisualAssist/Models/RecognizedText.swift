//
//  RecognizedText.swift
//  VisualAssist
//
//  Model for recognized text from OCR
//

import Foundation
import CoreGraphics

/// Represents recognized text from OCR
struct RecognizedText: Identifiable {
    let id = UUID()
    
    /// The recognized text string
    let text: String
    
    /// Bounding box in normalized coordinates (0-1)
    let boundingBox: CGRect
    
    /// Confidence score (0-1)
    let confidence: Float
    
    /// Language detected (if available)
    let language: String?
    
    /// Timestamp when recognized
    let timestamp: Date
    
    /// Whether this is a title/heading (larger text)
    var isHeading: Bool {
        // Simple heuristic: larger bounding boxes relative to width
        boundingBox.height > 0.05
    }
}

// MARK: - Text Document

/// Represents a full document with multiple text blocks
struct RecognizedDocument {
    let blocks: [RecognizedText]
    let timestamp: Date
    
    /// Get all text as a single string, ordered by position
    var fullText: String {
        // Sort by Y position (top to bottom), then X (left to right)
        let sorted = blocks.sorted { block1, block2 in
            if abs(block1.boundingBox.midY - block2.boundingBox.midY) > 0.05 {
                // Different lines - compare Y (higher values = higher on screen in Vision)
                return block1.boundingBox.midY > block2.boundingBox.midY
            }
            // Same line - compare X
            return block1.boundingBox.minX < block2.boundingBox.minX
        }
        
        return sorted.map { $0.text }.joined(separator: " ")
    }
    
    /// Get headings only
    var headings: [RecognizedText] {
        blocks.filter { $0.isHeading }
    }
    
    /// Get body text (non-headings)
    var bodyText: [RecognizedText] {
        blocks.filter { !$0.isHeading }
    }
    
    /// Average confidence of all blocks
    var averageConfidence: Float {
        guard !blocks.isEmpty else { return 0 }
        return blocks.reduce(0) { $0 + $1.confidence } / Float(blocks.count)
    }
}

// MARK: - Text Type

enum TextType {
    case printed
    case handwritten
    case mixed
    case unknown
}
