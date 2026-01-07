#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// iOS App Icon - Clean Typography with Liquid Glass Effect
// Minimal "VA" monogram in modern style

func createTypographyIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let center = CGPoint(x: size / 2, y: size / 2)
    
    // === DARK BACKGROUND ===
    context.setFillColor(CGColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0))
    context.fill(CGRect(x: 0, y: 0, width: size, height: size))
    
    // === SUBTLE RADIAL GRADIENT (depth) ===
    let depthGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1.0),
            CGColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(depthGradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: size * 0.75, options: [])
    
    // === OUTER GLOW RINGS ===
    for i in 0..<5 {
        let r = size * (0.42 + CGFloat(i) * 0.03)
        let alpha = 0.08 - CGFloat(i) * 0.015
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
    }
    
    // === LIQUID GLASS CIRCLE ===
    let glassRadius = size * 0.40
    
    // Glass fill
    context.saveGState()
    context.addEllipse(in: CGRect(x: center.x - glassRadius, y: center.y - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    context.clip()
    
    let glassGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.02),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glassGradient, 
        startCenter: CGPoint(x: center.x - glassRadius * 0.4, y: center.y + glassRadius * 0.5), 
        startRadius: 0, 
        endCenter: center, 
        endRadius: glassRadius, 
        options: [])
    context.restoreGState()
    
    // Glass border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.25))
    context.setLineWidth(size * 0.005)
    context.strokeEllipse(in: CGRect(x: center.x - glassRadius, y: center.y - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    
    // Top highlight arc
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.18))
    context.setLineWidth(size * 0.012)
    context.addArc(center: center, radius: glassRadius * 0.88, startAngle: CGFloat.pi * 0.55, endAngle: CGFloat.pi * 0.85, clockwise: false)
    context.strokePath()
    
    // Bottom subtle highlight
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.06))
    context.setLineWidth(size * 0.008)
    context.addArc(center: center, radius: glassRadius * 0.88, startAngle: -CGFloat.pi * 0.3, endAngle: -CGFloat.pi * 0.1, clockwise: false)
    context.strokePath()
    
    // === TYPOGRAPHY: "VA" ===
    let fontSize = size * 0.32
    let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
    
    let text = "VA"
    let textAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(white: 1.0, alpha: 0.92)
    ]
    
    let textString = NSAttributedString(string: text, attributes: textAttrs)
    let textSize = textString.size()
    
    // Center the text
    let textX = center.x - textSize.width / 2
    let textY = center.y - textSize.height / 2 - size * 0.02
    
    textString.draw(at: CGPoint(x: textX, y: textY))
    
    // === SMALL ACCENT DOT (subtle branding element) ===
    let dotRadius = size * 0.018
    let dotY = center.y - glassRadius * 0.55
    context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5))
    context.fillEllipse(in: CGRect(x: center.x - dotRadius, y: dotY - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
    
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
print("🎨 Generating VA Typography Icon...")

let icon1024 = createTypographyIcon(size: 1024)
saveImage(icon1024, to: "Assets/AppIcon.png", targetSize: 1024)
saveImage(icon1024, to: "Assets/AppIcon-Preview.png", targetSize: 1024)
saveImage(icon1024, to: "VisualAssist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png", targetSize: 1024)

print("✅ All icons generated with minimal VA typography design!")
