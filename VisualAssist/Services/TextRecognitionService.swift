//
//  TextRecognitionService.swift
//  VisualAssist
//
//  Text recognition using Apple's Vision framework
//

import Foundation
import Vision
import UIKit

/// Represents a block of recognized text with its location
struct TextBlock: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect
    let confidence: Float
}

/// Service for optical character recognition
@MainActor
class TextRecognitionService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var textBlocks: [TextBlock] = []
    @Published var isProcessing = false
    @Published var lastRecognizedText = ""
    
    // MARK: - Private Properties
    
    private let textRecognitionQueue = DispatchQueue(label: "com.visualassist.textrecognition")
    
    // MARK: - Text Recognition
    
    /// Recognize text in an image
    /// - Parameter image: The image to process
    /// - Returns: The recognized text as a single string
    func recognizeText(in image: CGImage) async -> String {
        isProcessing = true
        
        return await withCheckedContinuation { [weak self] continuation in
            let textRecognitionQueue = self?.textRecognitionQueue ?? DispatchQueue(label: "com.visualassist.textrecognition.temp")
            
            textRecognitionQueue.async {
                let request = VNRecognizeTextRequest { request, error in
                    guard error == nil,
                          let observations = request.results as? [VNRecognizedTextObservation] else {
                        Task { @MainActor in
                            self?.isProcessing = false
                        }
                        continuation.resume(returning: "")
                        return
                    }
                    
                    var blocks: [TextBlock] = []
                    var fullText = ""
                    
                    // Sort observations by position (top to bottom, left to right)
                    let sortedObservations = observations.sorted { obs1, obs2 in
                        // Higher y means higher on screen (Vision coordinates)
                        if abs(obs1.boundingBox.midY - obs2.boundingBox.midY) > 0.05 {
                            return obs1.boundingBox.midY > obs2.boundingBox.midY
                        }
                        return obs1.boundingBox.minX < obs2.boundingBox.minX
                    }
                    
                    for observation in sortedObservations {
                        guard let candidate = observation.topCandidates(1).first else { continue }
                        
                        let block = TextBlock(
                            text: candidate.string,
                            boundingBox: observation.boundingBox,
                            confidence: candidate.confidence
                        )
                        blocks.append(block)
                        
                        fullText += candidate.string + " "
                    }
                    
                    let finalBlocks = blocks
                    let finalText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    Task { @MainActor in
                        self?.textBlocks = finalBlocks
                        self?.lastRecognizedText = finalText
                        self?.isProcessing = false
                    }
                    
                    continuation.resume(returning: finalText)
                }
                
                // Configure the request
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                request.recognitionLanguages = ["en-US"]
                
                // Automatically detect language if possible
                if #available(iOS 16.0, *) {
                    request.automaticallyDetectsLanguage = true
                }
                
                // Create and perform the request
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    print("Text recognition error: \(error)")
                    Task { @MainActor in
                        self?.isProcessing = false
                    }
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    /// Process a UIImage for text recognition
    func recognizeText(in uiImage: UIImage) async -> String {
        guard let cgImage = uiImage.cgImage else {
            return ""
        }
        return await recognizeText(in: cgImage)
    }
    
    /// Clear all recognition results
    func clearResults() {
        textBlocks = []
        lastRecognizedText = ""
    }
    
    // MARK: - Real-time Recognition
    
    /// Process a frame for real-time text detection (lower accuracy, faster)
    func detectTextFast(in image: CGImage) async -> Bool {
        return await withCheckedContinuation { continuation in
            textRecognitionQueue.async {
                let request = VNRecognizeTextRequest { request, error in
                    let hasText = !(request.results as? [VNRecognizedTextObservation] ?? []).isEmpty
                    continuation.resume(returning: hasText)
                }
                
                request.recognitionLevel = .fast
                
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
