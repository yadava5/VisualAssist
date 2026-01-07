#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// iOS App Icon - Clean Black & White with Liquid Glass Effect
// Minimalist accessibility person with cane

func createAccessibilityIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let center = CGPoint(x: size / 2, y: size / 2)
    
    // === DARK BACKGROUND ===
    context.setFillColor(CGColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0))
    context.fill(CGRect(x: 0, y: 0, width: size, height: size))
    
    // === SUBTLE RADIAL GRADIENT (depth) ===
    let depthGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0),
            CGColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(depthGradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: size * 0.7, options: [])
    
    // === LIQUID GLASS CIRCLE ===
    let glassRadius = size * 0.38
    
    // Outer glow rings
    for i in 0..<4 {
        let r = glassRadius + CGFloat(i) * size * 0.025
        let alpha = 0.12 - CGFloat(i) * 0.025
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
    }
    
    // Glass fill
    context.saveGState()
    context.addEllipse(in: CGRect(x: center.x - glassRadius, y: center.y - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    context.clip()
    
    let glassGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.03),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glassGradient, 
        startCenter: CGPoint(x: center.x - glassRadius * 0.3, y: center.y + glassRadius * 0.4), 
        startRadius: 0, 
        endCenter: center, 
        endRadius: glassRadius, 
        options: [])
    context.restoreGState()
    
    // Glass border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
    context.setLineWidth(size * 0.006)
    context.strokeEllipse(in: CGRect(x: center.x - glassRadius, y: center.y - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    
    // Top highlight arc
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2))
    context.setLineWidth(size * 0.008)
    context.addArc(center: center, radius: glassRadius * 0.85, startAngle: CGFloat.pi * 0.55, endAngle: CGFloat.pi * 0.85, clockwise: false)
    context.strokePath()
    
    // === WALKING FIGURE ===
    let figScale = size * 0.0032
    let figX = center.x
    let figY = center.y
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    context.setLineWidth(12 * figScale)
    context.setLineCap(.round)
    
    // Head
    let headRadius = 26 * figScale
    context.fillEllipse(in: CGRect(x: figX - headRadius, y: figY + 70 * figScale, width: headRadius * 2, height: headRadius * 2))
    
    // Body
    context.move(to: CGPoint(x: figX, y: figY + 65 * figScale))
    context.addLine(to: CGPoint(x: figX, y: figY - 5 * figScale))
    context.strokePath()
    
    // Arms
    context.move(to: CGPoint(x: figX, y: figY + 45 * figScale))
    context.addLine(to: CGPoint(x: figX + 35 * figScale, y: figY + 20 * figScale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY + 45 * figScale))
    context.addLine(to: CGPoint(x: figX - 30 * figScale, y: figY + 15 * figScale))
    context.strokePath()
    
    // Legs
    context.move(to: CGPoint(x: figX, y: figY - 5 * figScale))
    context.addLine(to: CGPoint(x: figX + 25 * figScale, y: figY - 70 * figScale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY - 5 * figScale))
    context.addLine(to: CGPoint(x: figX - 20 * figScale, y: figY - 65 * figScale))
    context.strokePath()
    
    // Cane
    context.setLineWidth(8 * figScale)
    context.move(to: CGPoint(x: figX + 35 * figScale, y: figY + 20 * figScale))
    context.addLine(to: CGPoint(x: figX + 55 * figScale, y: figY - 85 * figScale))
    context.strokePath()
    
    // === SCANNING WAVES (subtle) ===
    for i in 0..<3 {
        let waveRadius = size * (0.52 + CGFloat(i) * 0.08)
        let alpha = 0.1 - CGFloat(i) * 0.03
        
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(size * 0.004)
        context.addArc(center: CGPoint(x: center.x + size * 0.05, y: center.y), radius: waveRadius, startAngle: -CGFloat.pi * 0.35, endAngle: CGFloat.pi * 0.35, clockwise: false)
        context.strokePath()
    }
    
    // === DETECTION DOTS ===
    let dotPositions: [(x: CGFloat, y: CGFloat, alpha: CGFloat)] = [
        (0.72, 0.62, 0.5),
        (0.76, 0.50, 0.4),
        (0.74, 0.38, 0.3),
    ]
    
    for dot in dotPositions {
        let dotRadius = size * 0.012
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: dot.alpha))
        context.fillEllipse(in: CGRect(x: size * dot.x - dotRadius, y: size * dot.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
    }
    
    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String, targetSize: Int = 1024) {
    // Create a bitmap representation at exact pixel size
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: targetSize,
        pixelsHigh: targetSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        print("Failed to create bitmap rep")
        return
    }
    
    bitmapRep.size = NSSize(width: targetSize, height: targetSize)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    
    // Draw the image scaled to the target size
    image.draw(in: NSRect(x: 0, y: 0, width: targetSize, height: targetSize),
               from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
               operation: .copy,
               fraction: 1.0)
    
    NSGraphicsContext.restoreGraphicsState()
    
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }
    
    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("✓ Saved: \(path) (\(targetSize)x\(targetSize))")
    } catch {
        print("✗ Error saving \(path): \(error)")
    }
}

// Generate icons
print("🎨 Generating Accessibility Person Icon...")

let icon1024 = createAccessibilityIcon(size: 1024)
saveImage(icon1024, to: "Assets/AppIcon.png", targetSize: 1024)
saveImage(icon1024, to: "Assets/AppIcon-Preview.png", targetSize: 1024)
saveImage(icon1024, to: "VisualAssist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png", targetSize: 1024)

print("✅ All icons generated with accessibility walking figure design!")
