//
//  DetectedObject.swift
//  VisualAssist
//
//  Note: Main DetectedObject struct is defined in ObjectDetectionService.swift
//  This file contains additional helper types and extensions
//

import Foundation
import CoreGraphics

// MARK: - Common Object Labels (COCO Dataset)

/// Common object labels from the COCO dataset used in many detection models
enum CommonObjectLabel: String, CaseIterable {
    // People
    case person
    
    // Vehicles
    case bicycle, car, motorcycle, airplane, bus, train, truck, boat
    
    // Outdoor
    case trafficLight = "traffic light"
    case fireHydrant = "fire hydrant"
    case stopSign = "stop sign"
    case parkingMeter = "parking meter"
    case bench
    
    // Animals
    case bird, cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe
    
    // Accessories
    case backpack, umbrella, handbag, tie, suitcase
    
    // Sports
    case frisbee, skis, snowboard, sportsBall = "sports ball"
    case kite, baseballBat = "baseball bat", baseballGlove = "baseball glove"
    case skateboard, surfboard, tennisRacket = "tennis racket"
    
    // Kitchen
    case bottle, wineglass = "wine glass", cup, fork, knife, spoon, bowl
    
    // Food
    case banana, apple, sandwich, orange, broccoli, carrot, hotDog = "hot dog"
    case pizza, donut, cake
    
    // Furniture
    case chair, couch, pottedPlant = "potted plant", bed, diningTable = "dining table"
    case toilet
    
    // Electronics
    case tv, laptop, mouse, remote, keyboard, cellPhone = "cell phone"
    
    // Appliances
    case microwave, oven, toaster, sink, refrigerator
    
    // Other
    case book, clock, vase, scissors, teddyBear = "teddy bear", hairDrier = "hair drier"
    case toothbrush
    
    /// Category for this object
    var category: ObjectCategory {
        switch self {
        case .person:
            return .person
        case .bicycle, .car, .motorcycle, .airplane, .bus, .train, .truck, .boat:
            return .vehicle
        case .chair, .couch, .pottedPlant, .bed, .diningTable, .toilet, .bench:
            return .furniture
        case .tv, .laptop, .mouse, .remote, .keyboard, .cellPhone, .microwave, .oven, .toaster, .refrigerator:
            return .electronics
        case .banana, .apple, .sandwich, .orange, .broccoli, .carrot, .hotDog, .pizza, .donut, .cake:
            return .food
        case .bird, .cat, .dog, .horse, .sheep, .cow, .elephant, .bear, .zebra, .giraffe:
            return .animal
        default:
            return .other
        }
    }
}

// MARK: - Object Position

/// Position of an object in the frame
enum ObjectPosition {
    case topLeft, topCenter, topRight
    case middleLeft, center, middleRight
    case bottomLeft, bottomCenter, bottomRight
    
    init(boundingBox: CGRect) {
        let horizontal: String
        let vertical: String
        
        if boundingBox.midX < 0.33 {
            horizontal = "left"
        } else if boundingBox.midX > 0.66 {
            horizontal = "right"
        } else {
            horizontal = "center"
        }
        
        if boundingBox.midY < 0.33 {
            vertical = "bottom" // Vision coordinates: low Y = bottom
        } else if boundingBox.midY > 0.66 {
            vertical = "top"
        } else {
            vertical = "middle"
        }
        
        switch (vertical, horizontal) {
        case ("top", "left"): self = .topLeft
        case ("top", "center"): self = .topCenter
        case ("top", "right"): self = .topRight
        case ("middle", "left"): self = .middleLeft
        case ("middle", "center"): self = .center
        case ("middle", "right"): self = .middleRight
        case ("bottom", "left"): self = .bottomLeft
        case ("bottom", "center"): self = .bottomCenter
        case ("bottom", "right"): self = .bottomRight
        default: self = .center
        }
    }
    
    var description: String {
        switch self {
        case .topLeft: return "top left"
        case .topCenter: return "top"
        case .topRight: return "top right"
        case .middleLeft: return "left"
        case .center: return "center"
        case .middleRight: return "right"
        case .bottomLeft: return "bottom left"
        case .bottomCenter: return "bottom"
        case .bottomRight: return "bottom right"
        }
    }
}

// MARK: - Detection Result Summary

/// Summary of all detected objects in a frame
struct DetectionSummary {
    let totalObjects: Int
    let peopleCount: Int
    let objectsByCategory: [ObjectCategory: Int]
    let mostConfidentObject: (label: String, confidence: Float)?
    
    init(objects: [DetectedObject]) {
        totalObjects = objects.count
        peopleCount = objects.filter { $0.category == .person }.count
        
        var categoryCount: [ObjectCategory: Int] = [:]
        for object in objects {
            categoryCount[object.category, default: 0] += 1
        }
        objectsByCategory = categoryCount
        
        if let best = objects.max(by: { $0.confidence < $1.confidence }) {
            mostConfidentObject = (best.label, best.confidence)
        } else {
            mostConfidentObject = nil
        }
    }
}
