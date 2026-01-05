#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// Create the app icon programmatically at exact pixel size (not points)
func createAppIcon(size: Int) -> NSImage {
    let cgSize = CGFloat(size)
    
    // Create bitmap context at exact pixel size
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
          ) else {
        return NSImage()
    }
    
    // Background gradient
    let colors = [
        NSColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor,      // #007AFF
        NSColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 1).cgColor  // #5856D6
    ] as CFArray
    
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else {
        return NSImage()
    }
    
    // Fill background with gradient
    context.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: cgSize),
                               end: CGPoint(x: cgSize, y: 0),
                               options: [])
    
    // Radiating waves
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.3).cgColor)
    context.setLineWidth(cgSize * 0.003)
    
    for i in 1...3 {
        let radius = cgSize * (0.3 + CGFloat(i) * 0.07)
        let rect = CGRect(x: cgSize/2 - radius, y: cgSize/2 - radius, width: radius * 2, height: radius * 2)
        context.strokeEllipse(in: rect)
    }
    
    // Main eye circle (white)
    let eyeRadius = cgSize * 0.2
    let eyeRect = CGRect(x: cgSize/2 - eyeRadius, y: cgSize/2 - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
    context.setFillColor(NSColor.white.cgColor)
    context.fillEllipse(in: eyeRect)
    
    // Iris (blue)
    let irisRadius = cgSize * 0.12
    let irisRect = CGRect(x: cgSize/2 - irisRadius, y: cgSize/2 - irisRadius, width: irisRadius * 2, height: irisRadius * 2)
    context.setFillColor(NSColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor)
    context.fillEllipse(in: irisRect)
    
    // Pupil (dark)
    let pupilRadius = cgSize * 0.05
    let pupilRect = CGRect(x: cgSize/2 - pupilRadius, y: cgSize/2 - pupilRadius, width: pupilRadius * 2, height: pupilRadius * 2)
    context.setFillColor(NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1).cgColor)
    context.fillEllipse(in: pupilRect)
    
    // Highlight
    let highlightRadius = cgSize * 0.025
    let highlightRect = CGRect(x: cgSize/2 - cgSize * 0.03, y: cgSize/2 + cgSize * 0.03, width: highlightRadius * 2, height: highlightRadius * 2)
    context.setFillColor(NSColor.white.withAlphaComponent(0.8).cgColor)
    context.fillEllipse(in: highlightRect)
    
    // Create NSImage from context
    guard let cgImage = context.makeImage() else {
        return NSImage()
    }
    
    return NSImage(cgImage: cgImage, size: NSSize(width: size, height: size))
}

func savePNG(image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path)")
    } catch {
        print("Failed to save: \(error)")
    }
}

// Generate icons
let basePath = FileManager.default.currentDirectoryPath

// 1024x1024 for App Store
let icon1024 = createAppIcon(size: 1024)
savePNG(image: icon1024, to: "\(basePath)/AppIcon.png")

// 240x240 for README preview
let icon240 = createAppIcon(size: 240)
savePNG(image: icon240, to: "\(basePath)/AppIcon-Preview.png")

// Copy to Assets.xcassets
let xcassetsPath = "\(basePath)/../VisualAssist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
savePNG(image: icon1024, to: xcassetsPath)

print("✅ App icons generated successfully!")
