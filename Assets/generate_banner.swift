#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// Create hero banner for README
func createHeroBanner() -> NSImage {
    let width: CGFloat = 1200
    let height: CGFloat = 400
    let image = NSImage(size: NSSize(width: width, height: height))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // Dark gradient background
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [
        NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1).cgColor,
        NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1).cgColor
    ] as CFArray
    
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) else {
        image.unlockFocus()
        return image
    }
    
    context.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: height),
                               end: CGPoint(x: width, y: 0),
                               options: [])
    
    // Add decorative circles (representing LiDAR waves)
    context.setStrokeColor(NSColor(red: 0, green: 0.478, blue: 1, alpha: 0.2).cgColor)
    context.setLineWidth(2)
    
    for i in 1...5 {
        let radius = CGFloat(i) * 80
        context.strokeEllipse(in: CGRect(x: 100 - radius, y: height/2 - radius, width: radius * 2, height: radius * 2))
    }
    
    // Feature boxes
    let boxWidth: CGFloat = 280
    let boxHeight: CGFloat = 120
    let boxY: CGFloat = (height - boxHeight) / 2
    let spacing: CGFloat = 40
    let startX: CGFloat = (width - (boxWidth * 3 + spacing * 2)) / 2
    
    let features = [
        ("🧭", "Navigation", "#007AFF"),
        ("📖", "Text Reading", "#34C759"),
        ("👁️", "Object Awareness", "#5856D6")
    ]
    
    for (index, feature) in features.enumerated() {
        let x = startX + CGFloat(index) * (boxWidth + spacing)
        
        // Box background
        let boxRect = NSRect(x: x, y: boxY, width: boxWidth, height: boxHeight)
        let boxPath = NSBezierPath(roundedRect: boxRect, xRadius: 16, yRadius: 16)
        
        NSColor(white: 1, alpha: 0.1).setFill()
        boxPath.fill()
        
        NSColor(white: 1, alpha: 0.2).setStroke()
        boxPath.stroke()
        
        // Feature text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let emojiAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 36),
            .paragraphStyle: paragraphStyle
        ]
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraphStyle
        ]
        
        let emoji = feature.0 as NSString
        emoji.draw(in: NSRect(x: x, y: boxY + 55, width: boxWidth, height: 50), withAttributes: emojiAttrs)
        
        let title = feature.1 as NSString
        title.draw(in: NSRect(x: x, y: boxY + 20, width: boxWidth, height: 30), withAttributes: titleAttrs)
    }
    
    // Title
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 14, weight: .medium),
        .foregroundColor: NSColor(white: 1, alpha: 0.6)
    ]
    
    let subtitle = "LiDAR-Powered Visual Assistance for iOS" as NSString
    subtitle.draw(at: NSPoint(x: 20, y: 20), withAttributes: titleAttrs)
    
    image.unlockFocus()
    return image
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

let basePath = FileManager.default.currentDirectoryPath
let banner = createHeroBanner()
savePNG(image: banner, to: "\(basePath)/Hero-Banner.png")

print("✅ Hero banner generated!")
