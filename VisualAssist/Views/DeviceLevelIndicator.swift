//
//  DeviceLevelIndicator.swift
//  VisualAssist
//
//  Simple center crosshair pointer
//

import SwiftUI

/// A simple center crosshair that shows camera center
struct DeviceLevelIndicator: View {
    let showCenterPointer: Bool
    
    init(showCenterPointer: Bool = true) {
        self.showCenterPointer = showCenterPointer
    }
    
    var body: some View {
        if showCenterPointer {
            centerPointer
        }
    }
    
    // MARK: - Center Pointer
    
    private var centerPointer: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                .frame(width: 50, height: 50)
            
            // Crosshair lines
            Group {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 2, height: 15)
                    .offset(y: -18)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 2, height: 15)
                    .offset(y: 18)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 15, height: 2)
                    .offset(x: -18)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 15, height: 2)
                    .offset(x: 18)
            }
            
            // Center dot
            Circle()
                .fill(Color.yellow)
                .frame(width: 6, height: 6)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        DeviceLevelIndicator()
    }
}
