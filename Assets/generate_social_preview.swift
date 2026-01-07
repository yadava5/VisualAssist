#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// GitHub Social Preview Image Generator
// Creates a 1280x640 social preview image - Clean black & white with liquid glass

func createSocialPreview() -> NSImage {
    let width: CGFloat = 1280
    let height: CGFloat = 640
    let image = NSImage(size: NSSize(width: width, height: height))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // === DARK BACKGROUND ===
    context.setFillColor(CGColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    
    // === SUBTLE GRID PATTERN ===
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.03))
    context.setLineWidth(1)
    for x in stride(from: 0, to: width, by: 40) {
        context.move(to: CGPoint(x: x, y: 0))
        context.addLine(to: CGPoint(x: x, y: height))
        context.strokePath()
    }
    for y in stride(from: 0, to: height, by: 40) {
        context.move(to: CGPoint(x: 0, y: y))
        context.addLine(to: CGPoint(x: width, y: y))
        context.strokePath()
    }
    
    // === LIQUID GLASS CIRCLE (large, centered-left) ===
    let glassX: CGFloat = width * 0.28
    let glassY: CGFloat = height * 0.5
    let glassRadius: CGFloat = 180
    
    // Outer glow
    for i in 0..<5 {
        let r = glassRadius + CGFloat(i) * 15
        let alpha = 0.08 - CGFloat(i) * 0.015
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(x: glassX - r, y: glassY - r, width: r * 2, height: r * 2))
    }
    
    // Glass fill with gradient
    context.saveGState()
    context.addEllipse(in: CGRect(x: glassX - glassRadius, y: glassY - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    context.clip()
    
    let glassGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.03),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glassGradient, startCenter: CGPoint(x: glassX - 40, y: glassY + 60), startRadius: 0, endCenter: CGPoint(x: glassX, y: glassY), endRadius: glassRadius, options: [])
    context.restoreGState()
    
    // Glass border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25))
    context.setLineWidth(2)
    context.strokeEllipse(in: CGRect(x: glassX - glassRadius, y: glassY - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    
    // Top highlight arc
    context.saveGState()
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15))
    context.setLineWidth(3)
    context.addArc(center: CGPoint(x: glassX, y: glassY), radius: glassRadius - 15, startAngle: CGFloat.pi * 0.6, endAngle: CGFloat.pi * 0.9, clockwise: false)
    context.strokePath()
    context.restoreGState()
    
    // === WALKING FIGURE (white, minimal) ===
    let figScale: CGFloat = 1.3
    let figX = glassX
    let figY = glassY
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95))
    context.setLineWidth(10 * figScale)
    context.setLineCap(.round)
    
    // Head
    context.fillEllipse(in: CGRect(x: figX - 22*figScale, y: figY + 65*figScale, width: 44*figScale, height: 44*figScale))
    
    // Body
    context.move(to: CGPoint(x: figX, y: figY + 60*figScale))
    context.addLine(to: CGPoint(x: figX, y: figY - 15*figScale))
    context.strokePath()
    
    // Arms
    context.move(to: CGPoint(x: figX, y: figY + 38*figScale))
    context.addLine(to: CGPoint(x: figX + 38*figScale, y: figY + 15*figScale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY + 38*figScale))
    context.addLine(to: CGPoint(x: figX - 32*figScale, y: figY + 10*figScale))
    context.strokePath()
    
    // Legs
    context.move(to: CGPoint(x: figX, y: figY - 15*figScale))
    context.addLine(to: CGPoint(x: figX + 28*figScale, y: figY - 80*figScale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY - 15*figScale))
    context.addLine(to: CGPoint(x: figX - 22*figScale, y: figY - 75*figScale))
    context.strokePath()
    
    // Cane
    context.setLineWidth(7 * figScale)
    context.move(to: CGPoint(x: figX + 38*figScale, y: figY + 15*figScale))
    context.addLine(to: CGPoint(x: figX + 60*figScale, y: figY - 95*figScale))
    context.strokePath()
    
    // === SCANNING WAVES ===
    for i in 0..<4 {
        let waveRadius: CGFloat = 220 + CGFloat(i) * 50
        let alpha = 0.12 - CGFloat(i) * 0.025
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(1.5)
        context.addArc(center: CGPoint(x: glassX + 30, y: glassY), radius: waveRadius, startAngle: -CGFloat.pi * 0.35, endAngle: CGFloat.pi * 0.35, clockwise: false)
        context.strokePath()
    }
    
    // === TEXT ===
    let textX: CGFloat = width * 0.52
    
    // App name - large, clean
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 82, weight: .semibold),
        .foregroundColor: NSColor.white
    ]
    let title = "VisualAssist"
    let titleString = NSAttributedString(string: title, attributes: titleAttrs)
    titleString.draw(at: CGPoint(x: textX, y: height * 0.52))
    
    // Tagline
    let taglineAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 26, weight: .regular),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.6)
    ]
    let tagline = "LiDAR-Powered Visual Assistance for iOS"
    let taglineString = NSAttributedString(string: tagline, attributes: taglineAttrs)
    taglineString.draw(at: CGPoint(x: textX, y: height * 0.42))
    
    // Features - minimal
    let featureAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 18, weight: .light),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.4)
    ]
    let features = "Navigation  •  Object Detection  •  Text Reading"
    let featuresString = NSAttributedString(string: features, attributes: featureAttrs)
    featuresString.draw(at: CGPoint(x: textX, y: height * 0.32))
    
    // Beta badge - small, below features, not overlapping title
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15))
    let badgeRect = CGRect(x: textX, y: height * 0.22, width: 60, height: 24)
    let badgePath = CGPath(roundedRect: badgeRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
    context.addPath(badgePath)
    context.fillPath()
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
    context.setLineWidth(1)
    context.addPath(badgePath)
    context.strokePath()
    
    let betaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 12, weight: .medium),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.7)
    ]
    let betaString = NSAttributedString(string: "BETA", attributes: betaAttrs)
    betaString.draw(at: CGPoint(x: textX + 14, y: height * 0.225))
    
    // === DETECTION DOTS ===
    let dotPositions: [(x: CGFloat, y: CGFloat, alpha: CGFloat)] = [
        (0.48, 0.72, 0.5),
        (0.52, 0.58, 0.4),
        (0.50, 0.44, 0.3),
        (0.46, 0.30, 0.2),
    ]
    
    for dot in dotPositions {
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: dot.alpha))
        context.fillEllipse(in: CGRect(x: width * dot.x - 3, y: height * dot.y - 3, width: 6, height: 6))
    }
    
    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String, targetSize: Int) {
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: targetSize,
        pixelsHigh: targetSize / 2,
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
    
    bitmapRep.size = NSSize(width: targetSize, height: targetSize / 2)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    
    image.draw(in: NSRect(x: 0, y: 0, width: targetSize, height: targetSize / 2),
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
        print("✓ Saved: \(path)")
    } catch {
        print("✗ Error saving \(path): \(error)")
    }
}

print("🎨 Generating Social Preview (B&W Liquid Glass)...")
let preview = createSocialPreview()
saveImage(preview, to: "Assets/social-preview.png", targetSize: 1280)
print("✅ Social preview generated!")
