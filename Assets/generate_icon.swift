#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// iOS 26 Liquid Glass Style App Icon Generator
// Creates a sophisticated icon with depth, glass effects, and modern aesthetics

func createLiquidGlassIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let center = CGPoint(x: size / 2, y: size / 2)
    
    // === BACKGROUND: Deep gradient with subtle noise ===
    let backgroundColors = [
        CGColor(red: 0.05, green: 0.10, blue: 0.25, alpha: 1.0),  // Deep navy
        CGColor(red: 0.15, green: 0.25, blue: 0.50, alpha: 1.0),  // Rich blue
        CGColor(red: 0.25, green: 0.35, blue: 0.65, alpha: 1.0),  // Lighter blue
    ]
    
    let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: backgroundColors as CFArray,
        locations: [0.0, 0.5, 1.0]
    )!
    
    context.drawRadialGradient(
        bgGradient,
        startCenter: CGPoint(x: size * 0.3, y: size * 0.7),
        startRadius: 0,
        endCenter: center,
        endRadius: size * 0.9,
        options: [.drawsAfterEndLocation]
    )
    
    // === LIQUID GLASS SCANNING RINGS ===
    let ringCount = 5
    for i in 0..<ringCount {
        let progress = CGFloat(i) / CGFloat(ringCount)
        let radius = size * 0.15 + (size * 0.35 * progress)
        let alpha = 0.3 - (progress * 0.2)
        
        context.setStrokeColor(CGColor(red: 0.6, green: 0.8, blue: 1.0, alpha: alpha))
        context.setLineWidth(size * 0.008)
        context.strokeEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
    }
    
    // === OUTER GLASS RING (Liquid Glass Effect) ===
    let outerRingRadius = size * 0.38
    let outerRingWidth = size * 0.06
    
    // Outer ring glow
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: size * -0.02), blur: size * 0.08, color: CGColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.6))
    
    let outerRingPath = CGMutablePath()
    outerRingPath.addEllipse(in: CGRect(
        x: center.x - outerRingRadius,
        y: center.y - outerRingRadius,
        width: outerRingRadius * 2,
        height: outerRingRadius * 2
    ))
    
    // Glass gradient for outer ring
    context.addPath(outerRingPath)
    context.setLineWidth(outerRingWidth)
    
    let ringGradientColors = [
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4),
        CGColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.2),
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3),
    ]
    context.setStrokeColor(CGColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 0.35))
    context.strokePath()
    context.restoreGState()
    
    // Inner highlight on glass ring
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5))
    context.setLineWidth(size * 0.004)
    context.strokeEllipse(in: CGRect(
        x: center.x - outerRingRadius + outerRingWidth/2,
        y: center.y - outerRingRadius + outerRingWidth/2,
        width: (outerRingRadius - outerRingWidth/2) * 2,
        height: (outerRingRadius - outerRingWidth/2) * 2
    ))
    
    // === CENTRAL EYE - Liquid Glass Style ===
    let eyeOuterRadius = size * 0.28
    
    // Eye outer glow
    context.saveGState()
    context.setShadow(offset: .zero, blur: size * 0.1, color: CGColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8))
    
    // White sclera with glass effect
    let scleraGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            CGColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0),
            CGColor(red: 0.88, green: 0.92, blue: 0.98, alpha: 1.0),
        ] as CFArray,
        locations: [0.0, 0.6, 1.0]
    )!
    
    context.saveGState()
    context.addEllipse(in: CGRect(
        x: center.x - eyeOuterRadius,
        y: center.y - eyeOuterRadius,
        width: eyeOuterRadius * 2,
        height: eyeOuterRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        scleraGradient,
        startCenter: CGPoint(x: center.x - eyeOuterRadius * 0.3, y: center.y + eyeOuterRadius * 0.3),
        startRadius: 0,
        endCenter: center,
        endRadius: eyeOuterRadius * 1.2,
        options: []
    )
    context.restoreGState()
    context.restoreGState()
    
    // === IRIS - Vibrant gradient ===
    let irisRadius = size * 0.16
    
    let irisGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.1, green: 0.6, blue: 0.95, alpha: 1.0),   // Bright blue center
            CGColor(red: 0.0, green: 0.45, blue: 0.85, alpha: 1.0), // Medium blue
            CGColor(red: 0.0, green: 0.3, blue: 0.7, alpha: 1.0),   // Deeper blue edge
        ] as CFArray,
        locations: [0.0, 0.5, 1.0]
    )!
    
    context.saveGState()
    context.addEllipse(in: CGRect(
        x: center.x - irisRadius,
        y: center.y - irisRadius,
        width: irisRadius * 2,
        height: irisRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        irisGradient,
        startCenter: CGPoint(x: center.x - irisRadius * 0.2, y: center.y + irisRadius * 0.2),
        startRadius: 0,
        endCenter: center,
        endRadius: irisRadius,
        options: []
    )
    context.restoreGState()
    
    // Iris detail rings
    for i in 1...3 {
        let ringRadius = irisRadius * (0.4 + CGFloat(i) * 0.18)
        context.setStrokeColor(CGColor(red: 0.0, green: 0.35, blue: 0.75, alpha: 0.3))
        context.setLineWidth(size * 0.003)
        context.strokeEllipse(in: CGRect(
            x: center.x - ringRadius,
            y: center.y - ringRadius,
            width: ringRadius * 2,
            height: ringRadius * 2
        ))
    }
    
    // === PUPIL ===
    let pupilRadius = size * 0.065
    
    let pupilGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0),
            CGColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 1.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.saveGState()
    context.addEllipse(in: CGRect(
        x: center.x - pupilRadius,
        y: center.y - pupilRadius,
        width: pupilRadius * 2,
        height: pupilRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        pupilGradient,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: pupilRadius,
        options: []
    )
    context.restoreGState()
    
    // === GLASS REFLECTIONS ===
    // Main highlight (top-left)
    let highlightRadius = size * 0.045
    let highlightCenter = CGPoint(x: center.x - eyeOuterRadius * 0.35, y: center.y + eyeOuterRadius * 0.35)
    
    let highlightGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.95),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.saveGState()
    context.addEllipse(in: CGRect(
        x: highlightCenter.x - highlightRadius,
        y: highlightCenter.y - highlightRadius,
        width: highlightRadius * 2,
        height: highlightRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        highlightGradient,
        startCenter: highlightCenter,
        startRadius: 0,
        endCenter: highlightCenter,
        endRadius: highlightRadius,
        options: []
    )
    context.restoreGState()
    
    // Secondary small highlight
    let smallHighlightRadius = size * 0.02
    let smallHighlightCenter = CGPoint(x: center.x - eyeOuterRadius * 0.15, y: center.y + eyeOuterRadius * 0.5)
    
    context.saveGState()
    context.addEllipse(in: CGRect(
        x: smallHighlightCenter.x - smallHighlightRadius,
        y: smallHighlightCenter.y - smallHighlightRadius,
        width: smallHighlightRadius * 2,
        height: smallHighlightRadius * 2
    ))
    context.clip()
    context.drawRadialGradient(
        highlightGradient,
        startCenter: smallHighlightCenter,
        startRadius: 0,
        endCenter: smallHighlightCenter,
        endRadius: smallHighlightRadius,
        options: []
    )
    context.restoreGState()
    
    // === TOP GLASS SHEEN ===
    context.saveGState()
    let sheenPath = CGMutablePath()
    sheenPath.addEllipse(in: CGRect(
        x: center.x - size * 0.42,
        y: center.y - size * 0.1,
        width: size * 0.84,
        height: size * 0.55
    ))
    context.addPath(sheenPath)
    context.clip()
    
    let sheenGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    
    context.drawLinearGradient(
        sheenGradient,
        start: CGPoint(x: center.x, y: size),
        end: CGPoint(x: center.x, y: size * 0.5),
        options: []
    )
    context.restoreGState()
    
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

// Generate icons
print("🎨 Generating iOS 26 Liquid Glass App Icons...")

let icon1024 = createLiquidGlassIcon(size: 1024)
saveImage(icon1024, to: "Assets/AppIcon.png")
saveImage(icon1024, to: "Assets/AppIcon-Preview.png")
saveImage(icon1024, to: "VisualAssist/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

print("✅ All icons generated with iOS 26 Liquid Glass design!")
