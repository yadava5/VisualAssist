//
//  ObjectDetectionService.swift
//  VisualAssist
//
//  Object detection using Vision framework
//

import Foundation
import Vision
import CoreML
import UIKit

/// Category of detected object
enum ObjectCategory: String {
    case person = "Person"
    case vehicle = "Vehicle"
    case furniture = "Furniture"
    case electronics = "Electronics"
    case food = "Food"
    case animal = "Animal"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .person: return "person.fill"
        case .vehicle: return "car.fill"
        case .furniture: return "chair.fill"
        case .electronics: return "desktopcomputer"
        case .food: return "fork.knife"
        case .animal: return "pawprint.fill"
        case .other: return "cube.fill"
        }
    }
    
    static func from(label: String) -> ObjectCategory {
        let lowercased = label.lowercased()
        
        if ["person", "man", "woman", "child", "people"].contains(where: { lowercased.contains($0) }) {
            return .person
        }
        if ["car", "truck", "bus", "motorcycle", "bicycle", "vehicle"].contains(where: { lowercased.contains($0) }) {
            return .vehicle
        }
        if ["chair", "couch", "sofa", "table", "bed", "desk"].contains(where: { lowercased.contains($0) }) {
            return .furniture
        }
        if ["tv", "laptop", "phone", "computer", "keyboard", "mouse"].contains(where: { lowercased.contains($0) }) {
            return .electronics
        }
        if ["apple", "banana", "food", "pizza", "sandwich", "cake"].contains(where: { lowercased.contains($0) }) {
            return .food
        }
        if ["dog", "cat", "bird", "horse", "animal"].contains(where: { lowercased.contains($0) }) {
            return .animal
        }
        
        return .other
    }
}

/// Represents a detected object
struct DetectedObject: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
    let category: ObjectCategory
}

/// Service for real-time object detection
class ObjectDetectionService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var detectedObjects: [DetectedObject] = []
    @Published var isProcessing = false
    
    // MARK: - Private Properties
    
    private let processQueue = DispatchQueue(label: "com.visualassist.objectdetection")
    private var classificationRequest: VNCoreMLRequest?
    
    // MARK: - Initialization
    
    init() {
        setupClassificationRequest()
    }
    
    private func setupClassificationRequest() {
        // Using Vision's built-in object recognition
        // In a full implementation, you would load a custom Core ML model here
    }
    
    // MARK: - Object Detection
    
    /// Detect objects in an image
    func detectObjects(in image: CGImage) async -> [DetectedObject] {
        isProcessing = true
        
        return await withCheckedContinuation { continuation in
            processQueue.async { [weak self] in
                var objects: [DetectedObject] = []
                
                // Use Vision's built-in object recognition
                let request = VNRecognizeAnimalsRequest { request, error in
                    if let results = request.results as? [VNRecognizedObjectObservation] {
                        for observation in results {
                            if let label = observation.labels.first {
                                let obj = DetectedObject(
                                    label: label.identifier,
                                    confidence: label.confidence,
                                    boundingBox: observation.boundingBox,
                                    category: ObjectCategory.from(label: label.identifier)
                                )
                                objects.append(obj)
                            }
                        }
                    }
                }
                
                let humanRequest = VNDetectHumanRectanglesRequest { request, error in
                    if let results = request.results as? [VNHumanObservation] {
                        for observation in results {
                            let obj = DetectedObject(
                                label: "person",
                                confidence: observation.confidence,
                                boundingBox: observation.boundingBox,
                                category: .person
                            )
                            objects.append(obj)
                        }
                    }
                }
                
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                
                do {
                    try handler.perform([request, humanRequest])
                } catch {
                    print("Object detection error: \(error)")
                }
                
                let finalObjects = objects
                DispatchQueue.main.async { [weak self] in
                    self?.detectedObjects = finalObjects
                    self?.isProcessing = false
                }
                
                continuation.resume(returning: objects)
            }
        }
    }
    
    // MARK: - Scene Description
    
    /// Generate a natural language description of detected objects
    func generateSceneDescription(from objects: [DetectedObject]) -> String {
        guard !objects.isEmpty else {
            return "No objects detected in the scene."
        }
        
        var description = ""
        
        // Count people
        let peopleCount = objects.filter { $0.category == .person }.count
        if peopleCount > 0 {
            description += peopleCount == 1 ? "One person " : "\(peopleCount) people "
        }
        
        // Group other objects by category
        var categoryCounts: [ObjectCategory: Int] = [:]
        for object in objects where object.category != .person {
            categoryCounts[object.category, default: 0] += 1
        }
        
        // Build description
        var objectDescriptions: [String] = []
        
        for (category, count) in categoryCounts.sorted(by: { $0.value > $1.value }) {
            if count == 1 {
                objectDescriptions.append("a \(category.rawValue.lowercased())")
            } else {
                objectDescriptions.append("\(count) \(category.rawValue.lowercased())s")
            }
        }
        
        if !objectDescriptions.isEmpty {
            if !description.isEmpty {
                description += "and "
            }
            description += objectDescriptions.joined(separator: ", ")
        }
        
        if description.isEmpty {
            return "Scene contains unidentified objects."
        }
        
        // Add spatial context if possible
        description = "Detected: " + description + " in the scene."
        
        return description
    }
    
    // MARK: - Color Identification
    
    /// Identify the dominant color in an image
    func identifyDominantColor(in image: CGImage) async -> String {
        return await withCheckedContinuation { continuation in
            processQueue.async {
                let uiImage = UIImage(cgImage: image)
                
                // Resize for faster processing
                let size = CGSize(width: 50, height: 50)
                UIGraphicsBeginImageContext(size)
                uiImage.draw(in: CGRect(origin: .zero, size: size))
                let resized = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                guard let cgImage = resized?.cgImage,
                      let dataProvider = cgImage.dataProvider,
                      let data = dataProvider.data,
                      let bytes = CFDataGetBytePtr(data) else {
                    continuation.resume(returning: "unknown")
                    return
                }
                
                let bytesPerPixel = cgImage.bitsPerPixel / 8
                let bytesPerRow = cgImage.bytesPerRow
                let width = cgImage.width
                let height = cgImage.height
                
                var totalR = 0, totalG = 0, totalB = 0
                var pixelCount = 0
                
                for y in 0..<height {
                    for x in 0..<width {
                        let offset = y * bytesPerRow + x * bytesPerPixel
                        let r = Int(bytes[offset])
                        let g = Int(bytes[offset + 1])
                        let b = Int(bytes[offset + 2])
                        
                        totalR += r
                        totalG += g
                        totalB += b
                        pixelCount += 1
                    }
                }
                
                guard pixelCount > 0 else {
                    continuation.resume(returning: "unknown")
                    return
                }
                
                let avgR = totalR / pixelCount
                let avgG = totalG / pixelCount
                let avgB = totalB / pixelCount
                
                let colorName = ObjectDetectionService.colorName(r: avgR, g: avgG, b: avgB)
                continuation.resume(returning: colorName)
            }
        }
    }
    
    private static func colorName(r: Int, g: Int, b: Int) -> String {
        // Simple color classification
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let diff = max - min
        
        // Grayscale check
        if diff < 30 {
            if max < 50 { return "black" }
            if max > 200 { return "white" }
            return "gray"
        }
        
        // Color detection
        if r > g && r > b {
            if r > 200 && g < 100 && b < 100 { return "red" }
            if r > 200 && g > 100 { return "orange" }
            return "reddish"
        }
        
        if g > r && g > b {
            if g > 200 && r < 100 { return "green" }
            return "greenish"
        }
        
        if b > r && b > g {
            if b > 200 { return "blue" }
            if r > 100 { return "purple" }
            return "bluish"
        }
        
        if r > 200 && g > 200 && b < 100 { return "yellow" }
        if r < 100 && g > 200 && b > 200 { return "cyan" }
        if r > 200 && g < 100 && b > 200 { return "magenta" }
        
        return "mixed colors"
    }
}
