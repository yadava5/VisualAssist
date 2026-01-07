#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// iOS 26 Liquid Glass Style App Icon - Accessibility Person with Cane
// Creates a sophisticated layered icon representing visual assistance

func createAccessibilityIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let center = CGPoint(x: size / 2, y: size / 2)
    
    // === BACKGROUND: Rich gradient ===
    let backgroundColors = [
        CGColor(red: 0.0, green: 0.35, blue: 0.85, alpha: 1.0),   // Bright blue
        CGColor(red: 0.0, green: 0.25, blue: 0.65, alpha: 1.0),   // Medium blue
        CGColor(red: 0.05, green: 0.15, blue: 0.45, alpha: 1.0),  // Deep blue
    ]
    
    let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: backgroundColors as CFArray,
        locations: [0.0, 0.5, 1.0]
    )!
    
    context.drawLinearGradient(
        bgGradient,
        start: CGPoint(x: 0, y: size),
        end: CGPoint(x: size, y: 0),
        options: []
    )
    
    // === SCANNING WAVES (representing LiDAR) ===
    for i in 0..<4 {
        let waveRadius = size * (0.55 + CGFloat(i) * 0.12)
        let alpha = 0.25 - (CGFloat(i) * 0.05)
        
        context.setStrokeColor(CGColor(red: 0.5, green: 0.8, blue: 1.0, alpha: alpha))
        context.setLineWidth(size * 0.012)
        
        // Draw arc on right side (scanning direction)
        let arcCenter = CGPoint(x: size * 0.4, y: size * 0.5)
        context.addArc(center: arcCenter, radius: waveRadius, startAngle: -CGFloat.pi * 0.4, endAngle: CGFloat.pi * 0.4, clockwise: false)
        context.strokePath()
    }
    
    // === GLASS CIRCLE BACKDROP ===
    let circleRadius = size * 0.38
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.02), blur: size * 0.08, color: CGColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.5))
    
    let circleGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.08),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.addEllipse(in: CGRect(
        x: center.x - circleRadius,
        y: center.y - circleRadius,
        width: circleRadius * 2,
        height: circleRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        circleGradient,
        startCenter: CGPoint(x: center.x - circleRadius * 0.3, y: center.y + circleRadius * 0.3),
        startRadius: 0,
        endCenter: center,
        endRadius: circleRadius,
        options: []
    )
    context.restoreGState()
    
    // Glass circle border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4))
    context.setLineWidth(size * 0.008)
    context.strokeEllipse(in: CGRect(
        x: center.x - circleRadius,
        y: center.y - circleRadius,
        width: circleRadius * 2,
        height: circleRadius * 2
    ))
    
    // === PERSON WITH CANE FIGURE ===
    let figureScale = size * 0.0028
    let figureOffsetX = center.x - size * 0.05
    let figureOffsetY = center.y
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: size * 0.01, height: -size * 0.015), blur: size * 0.03, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))
    
    // Head
    let headRadius = 28 * figureScale
    let headCenter = CGPoint(x: figureOffsetX, y: figureOffsetY + 95 * figureScale)
    
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.fillEllipse(in: CGRect(
        x: headCenter.x - headRadius,
        y: headCenter.y - headRadius,
        width: headRadius * 2,
        height: headRadius * 2
    ))
    
    // Body
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    context.setLineWidth(12 * figureScale)
    context.setLineCap(.round)
    
    // Torso
    context.move(to: CGPoint(x: figureOffsetX, y: figureOffsetY + 65 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX, y: figureOffsetY - 10 * figureScale))
    context.strokePath()
    
    // Left arm (extended forward holding cane)
    context.move(to: CGPoint(x: figureOffsetX, y: figureOffsetY + 45 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX + 35 * figureScale, y: figureOffsetY + 20 * figureScale))
    context.strokePath()
    
    // Right arm (back)
    context.move(to: CGPoint(x: figureOffsetX, y: figureOffsetY + 45 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX - 30 * figureScale, y: figureOffsetY + 15 * figureScale))
    context.strokePath()
    
    // Left leg (forward)
    context.move(to: CGPoint(x: figureOffsetX, y: figureOffsetY - 10 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX + 25 * figureScale, y: figureOffsetY - 75 * figureScale))
    context.strokePath()
    
    // Right leg (back)
    context.move(to: CGPoint(x: figureOffsetX, y: figureOffsetY - 10 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX - 20 * figureScale, y: figureOffsetY - 70 * figureScale))
    context.strokePath()
    
    // Cane
    context.setLineWidth(8 * figureScale)
    context.move(to: CGPoint(x: figureOffsetX + 35 * figureScale, y: figureOffsetY + 20 * figureScale))
    context.addLine(to: CGPoint(x: figureOffsetX + 55 * figureScale, y: figureOffsetY - 85 * figureScale))
    context.strokePath()
    
    // Cane tip (small circle)
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    let tipRadius = 5 * figureScale
    context.fillEllipse(in: CGRect(
        x: figureOffsetX + 55 * figureScale - tipRadius,
        y: figureOffsetY - 85 * figureScale - tipRadius,
        width: tipRadius * 2,
        height: tipRadius * 2
    ))
    
    context.restoreGState()
    
    // === GLASS HIGHLIGHT ON TOP ===
    context.saveGState()
    
    let highlightPath = CGMutablePath()
    highlightPath.addEllipse(in: CGRect(
        x: size * 0.15,
        y: size * 0.55,
        width: size * 0.7,
        height: size * 0.4
    ))
    context.addPath(highlightPath)
    context.clip()
    
    let highlightGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.drawLinearGradient(
        highlightGradient,
        start: CGPoint(x: center.x, y: size),
        end: CGPoint(x: center.x, y: size * 0.6),
        options: []
    )
    context.restoreGState()
    
    // === SMALL DOT ACCENTS (representing detected points) ===
    let dotPositions = [
        (x: 0.75, y: 0.65, alpha: 0.8),
        (x: 0.8, y: 0.5, alpha: 0.6),
        (x: 0.78, y: 0.35, alpha: 0.5),
        (x: 0.72, y: 0.25, alpha: 0.4),
    ]
    
    for dot in dotPositions {
        let dotRadius = size * 0.012
        let dotCenter = CGPoint(x: size * CGFloat(dot.x), y: size * CGFloat(dot.y))
        
        context.setFillColor(CGColor(red: 0.6, green: 0.9, blue: 1.0, alpha: CGFloat(dot.alpha)))
        context.fillEllipse(in: CGRect(
            x: dotCenter.x - dotRadius,
            y: dotCenter.y - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        ))
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
