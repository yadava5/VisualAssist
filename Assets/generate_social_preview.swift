#!/usr/bin/env swift

import Cocoa
import CoreGraphics

// GitHub Social Preview Image Generator
// Creates a 1280x640 social preview image - Modern dark aesthetic with subtle gradients

func createSocialPreview() -> NSImage {
    let width: CGFloat = 1280
    let height: CGFloat = 640
    let image = NSImage(size: NSSize(width: width, height: height))
    
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    // === DARK GRADIENT BACKGROUND ===
    let bgGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.08, green: 0.06, blue: 0.10, alpha: 1.0),  // Deep purple-black
            CGColor(red: 0.04, green: 0.04, blue: 0.06, alpha: 1.0),  // Near black
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: width, y: 0), options: [])
    
    // === SUBTLE AMBIENT GLOW (top-left) ===
    let glowGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.08),  // Soft purple
            CGColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glowGradient, startCenter: CGPoint(x: 200, y: height - 100), startRadius: 0, endCenter: CGPoint(x: 200, y: height - 100), endRadius: 400, options: [])
    
    // === SUBTLE AMBIENT GLOW (bottom-right) ===
    let glowGradient2 = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 0.06),  // Warm peach
            CGColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 0.0),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glowGradient2, startCenter: CGPoint(x: width - 200, y: 150), startRadius: 0, endCenter: CGPoint(x: width - 200, y: 150), endRadius: 350, options: [])
    
    // === NOISE TEXTURE (very subtle) ===
    for _ in 0..<800 {
        let x = CGFloat.random(in: 0..<width)
        let y = CGFloat.random(in: 0..<height)
        let alpha = CGFloat.random(in: 0.01...0.03)
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.fillEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
    }
    
    // === LIQUID GLASS CIRCLE ===
    let glassX: CGFloat = width * 0.25
    let glassY: CGFloat = height * 0.5
    let glassRadius: CGFloat = 160
    
    // Outer glow rings
    for i in 0..<4 {
        let r = glassRadius + CGFloat(i) * 20
        let alpha = 0.06 - CGFloat(i) * 0.012
        context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: alpha))
        context.setLineWidth(1)
        context.strokeEllipse(in: CGRect(x: glassX - r, y: glassY - r, width: r * 2, height: r * 2))
    }
    
    // Glass fill
    context.saveGState()
    context.addEllipse(in: CGRect(x: glassX - glassRadius, y: glassY - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    context.clip()
    
    let glassGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.10),
            CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.02),
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawRadialGradient(glassGradient, startCenter: CGPoint(x: glassX - 30, y: glassY + 50), startRadius: 0, endCenter: CGPoint(x: glassX, y: glassY), endRadius: glassRadius, options: [])
    context.restoreGState()
    
    // Glass border
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.20))
    context.setLineWidth(1.5)
    context.strokeEllipse(in: CGRect(x: glassX - glassRadius, y: glassY - glassRadius, width: glassRadius * 2, height: glassRadius * 2))
    
    // Highlight arc
    context.saveGState()
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.12))
    context.setLineWidth(2)
    context.addArc(center: CGPoint(x: glassX, y: glassY), radius: glassRadius - 12, startAngle: CGFloat.pi * 0.65, endAngle: CGFloat.pi * 0.85, clockwise: false)
    context.strokePath()
    context.restoreGState()
    
    // === VA TYPOGRAPHY ===
    let vaFont = NSFont.systemFont(ofSize: 120, weight: .semibold)
    let vaAttrs: [NSAttributedString.Key: Any] = [
        .font: vaFont,
        .foregroundColor: NSColor(white: 1.0, alpha: 0.92)
    ]
    let vaString = NSAttributedString(string: "VA", attributes: vaAttrs)
    let vaSize = vaString.size()
    vaString.draw(at: CGPoint(x: glassX - vaSize.width/2, y: glassY - vaSize.height/2 + 8))
    
    // === TEXT CONTENT ===
    let textX: CGFloat = width * 0.48
    let centerY: CGFloat = height * 0.5
    
    // App name
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 72, weight: .bold),
        .foregroundColor: NSColor.white
    ]
    let titleString = NSAttributedString(string: "VisualAssist", attributes: titleAttrs)
    titleString.draw(at: CGPoint(x: textX, y: centerY + 40))
    
    // Tagline
    let taglineAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .regular),
        .foregroundColor: NSColor(white: 1.0, alpha: 0.55)
    ]
    let taglineString = NSAttributedString(string: "LiDAR-Powered Visual Assistance for iOS", attributes: taglineAttrs)
    taglineString.draw(at: CGPoint(x: textX, y: centerY - 10))
    
    // Features with subtle gradient accent
    let featureY = centerY - 60
    let features = ["Navigation", "Object Detection", "Text Reading"]
    var currentX = textX
    
    for (index, feature) in features.enumerated() {
        let featureAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: NSColor(white: 1.0, alpha: 0.4)
        ]
        let featureString = NSAttributedString(string: feature, attributes: featureAttrs)
        featureString.draw(at: CGPoint(x: currentX, y: featureY))
        currentX += featureString.size().width
        
        if index < features.count - 1 {
            // Dot separator
            context.setFillColor(CGColor(red: 0.8, green: 0.6, blue: 0.9, alpha: 0.4))
            context.fillEllipse(in: CGRect(x: currentX + 12, y: featureY + 6, width: 4, height: 4))
            currentX += 28
        }
    }
    
    // === BETA BADGE (subtle, separate line) ===
    let badgeX = textX
    let badgeY = centerY - 105
    
    // Badge background with gradient border
    let badgeWidth: CGFloat = 52
    let badgeHeight: CGFloat = 22
    let badgeRect = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
    let badgePath = CGPath(roundedRect: badgeRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
    
    context.setFillColor(CGColor(red: 0.8, green: 0.6, blue: 0.9, alpha: 0.12))
    context.addPath(badgePath)
    context.fillPath()
    
    context.setStrokeColor(CGColor(red: 0.8, green: 0.6, blue: 0.9, alpha: 0.35))
    context.setLineWidth(1)
    context.addPath(badgePath)
    context.strokePath()
    
    let betaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
        .foregroundColor: NSColor(red: 0.85, green: 0.7, blue: 0.95, alpha: 0.85)
    ]
    let betaString = NSAttributedString(string: "BETA", attributes: betaAttrs)
    betaString.draw(at: CGPoint(x: badgeX + 10, y: badgeY + 4))
    
    // === DECORATIVE ELEMENTS ===
    // Floating dots
    let dots: [(x: CGFloat, y: CGFloat, size: CGFloat, alpha: CGFloat)] = [
        (0.92, 0.75, 5, 0.25),
        (0.88, 0.60, 3, 0.15),
        (0.94, 0.45, 4, 0.20),
        (0.15, 0.85, 4, 0.18),
        (0.10, 0.70, 3, 0.12),
    ]
    
    for dot in dots {
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: dot.alpha))
        context.fillEllipse(in: CGRect(x: width * dot.x, y: height * dot.y, width: dot.size, height: dot.size))
    }
    
    // Subtle line accents
    context.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.04))
    context.setLineWidth(1)
    context.move(to: CGPoint(x: width * 0.45, y: 0))
    context.addLine(to: CGPoint(x: width * 0.45, y: height))
    context.strokePath()
    
    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String) {
    let targetWidth = 1280
    let targetHeight = 640
    
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: targetWidth,
        pixelsHigh: targetHeight,
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
    
    bitmapRep.size = NSSize(width: targetWidth, height: targetHeight)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    
    image.draw(in: NSRect(x: 0, y: 0, width: targetWidth, height: targetHeight),
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

print("🎨 Generating Modern Dark Social Preview...")
let preview = createSocialPreview()
saveImage(preview, to: "Assets/social-preview.png")
print("✅ Social preview generated!")
