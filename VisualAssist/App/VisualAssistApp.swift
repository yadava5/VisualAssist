//
//  VisualAssistApp.swift
//  VisualAssist
//
//  Visual assistance app for iPhone Pro with LiDAR
//

import SwiftUI

@main
struct VisualAssistApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupAccessibility()
                }
        }
    }
    
    private func setupAccessibility() {
        // Ensure the app is fully accessible from launch
        UIAccessibility.post(notification: .announcement, argument: "Visual Assist ready. Swipe to explore modes.")
    }
}
