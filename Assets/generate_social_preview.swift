#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// GitHub Social Preview Image Generator
// Creates a 1280x640 social preview image for the repository

func createSocialPreview() -> NSImage {
    let width: CGFloat = 1280
    let height: CGFloat = 640
    let image = NSImage(size: NSSize(width: width, height: height))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // === BACKGROUND GRADIENT ===
    let backgroundColors = [
        CGColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 1.0),
        CGColor(red: 0.0, green: 0.1, blue: 0.3, alpha: 1.0),
        CGColor(red: 0.02, green: 0.05, blue: 0.15, alpha: 1.0),
    ]
    
    let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: backgroundColors as CFArray,
        locations: [0.0, 0.5, 1.0]
    )!
    
    context.drawLinearGradient(
        bgGradient,
        start: CGPoint(x: 0, y: height),
        end: CGPoint(x: width, y: 0),
        options: []
    )
    
    // === SCANNING WAVES ===
    for i in 0..<6 {
        let waveRadius = CGFloat(200 + i * 80)
        let alpha = 0.15 - (CGFloat(i) * 0.02)
        
        context.setStrokeColor(CGColor(red: 0.3, green: 0.7, blue: 1.0, alpha: alpha))
        context.setLineWidth(2)
        
        let arcCenter = CGPoint(x: width * 0.15, y: height * 0.5)
        context.addArc(center: arcCenter, radius: waveRadius, startAngle: -CGFloat.pi * 0.4, endAngle: CGFloat.pi * 0.4, clockwise: false)
        context.strokePath()
    }
    
    // === ICON AREA (left side) ===
    let iconSize: CGFloat = 200
    let iconX = width * 0.18
    let iconY = height * 0.5
    
    // Glass circle
    let circleGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.05),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.saveGState()
    context.addEllipse(in: CGRect(x: iconX - iconSize/2, y: iconY - iconSize/2, width: iconSize, height: iconSize))
    context.clip()
    context.drawRadialGradient(circleGradient, startCenter: CGPoint(x: iconX, y: iconY + 50), startRadius: 0, endCenter: CGPoint(x: iconX, y: iconY), endRadius: iconSize/2, options: [])
    context.restoreGState()
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3))
    context.setLineWidth(2)
    context.strokeEllipse(in: CGRect(x: iconX - iconSize/2, y: iconY - iconSize/2, width: iconSize, height: iconSize))
    
    // Walking figure
    let scale: CGFloat = 0.7
    let figX = iconX
    let figY = iconY
    
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.setLineWidth(8 * scale)
    context.setLineCap(.round)
    
    // Head
    context.fillEllipse(in: CGRect(x: figX - 18*scale, y: figY + 55*scale, width: 36*scale, height: 36*scale))
    
    // Body
    context.move(to: CGPoint(x: figX, y: figY + 50*scale))
    context.addLine(to: CGPoint(x: figX, y: figY - 20*scale))
    context.strokePath()
    
    // Arms
    context.move(to: CGPoint(x: figX, y: figY + 30*scale))
    context.addLine(to: CGPoint(x: figX + 30*scale, y: figY + 10*scale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY + 30*scale))
    context.addLine(to: CGPoint(x: figX - 25*scale, y: figY + 5*scale))
    context.strokePath()
    
    // Legs
    context.move(to: CGPoint(x: figX, y: figY - 20*scale))
    context.addLine(to: CGPoint(x: figX + 20*scale, y: figY - 70*scale))
    context.strokePath()
    
    context.move(to: CGPoint(x: figX, y: figY - 20*scale))
    context.addLine(to: CGPoint(x: figX - 18*scale, y: figY - 65*scale))
    context.strokePath()
    
    // Cane
    context.setLineWidth(5 * scale)
    context.move(to: CGPoint(x: figX + 30*scale, y: figY + 10*scale))
    context.addLine(to: CGPoint(x: figX + 50*scale, y: figY - 80*scale))
    context.strokePath()
    
    // === TEXT AREA (right side) ===
    let textX = width * 0.45
    
    // App name
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 72, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    let title = "VisualAssist"
    let titleString = NSAttributedString(string: title, attributes: titleAttrs)
    titleString.draw(at: CGPoint(x: textX, y: height * 0.58))
    
    // Tagline
    let taglineAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 28, weight: .medium),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.8)
    ]
    let tagline = "LiDAR-Powered Visual Assistance for iOS"
    let taglineString = NSAttributedString(string: tagline, attributes: taglineAttrs)
    taglineString.draw(at: CGPoint(x: textX, y: height * 0.48))
    
    // Features
    let featureAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 20, weight: .regular),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.6)
    ]
    let features = "Navigation • Object Detection • Text Reading • Voice Control"
    let featuresString = NSAttributedString(string: features, attributes: featureAttrs)
    featuresString.draw(at: CGPoint(x: textX, y: height * 0.35))
    
    // Beta badge
    context.setFillColor(CGColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0))
    let badgeRect = CGRect(x: textX + 380, y: height * 0.58 + 15, width: 80, height: 32)
    let badgePath = CGPath(roundedRect: badgeRect, cornerWidth: 6, cornerHeight: 6, transform: nil)
    context.addPath(badgePath)
    context.fillPath()
    
    let betaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 16, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    let betaString = NSAttributedString(string: "BETA", attributes: betaAttrs)
    betaString.draw(at: CGPoint(x: textX + 400, y: height * 0.58 + 20))
    
    // === DETECTION DOTS ===
    let dotPositions: [(x: CGFloat, y: CGFloat, alpha: CGFloat)] = [
        (0.35, 0.7, 0.6),
        (0.40, 0.55, 0.5),
        (0.38, 0.4, 0.4),
        (0.33, 0.25, 0.3),
    ]
    
    for dot in dotPositions {
        context.setFillColor(CGColor(red: 0.4, green: 0.8, blue: 1.0, alpha: dot.alpha))
        context.fillEllipse(in: CGRect(x: width * dot.x - 4, y: height * dot.y - 4, width: 8, height: 8))
    }
    
    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
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

print("🎨 Generating Social Preview...")
let preview = createSocialPreview()
saveImage(preview, to: "Assets/social-preview.png")
print("✅ Social preview generated!")
