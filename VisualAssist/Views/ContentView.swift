//
//  ContentView.swift
//  VisualAssist
//
//  Main container view that switches between modes
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Mode-specific view
            Group {
                switch appState.currentMode {
                case .home:
                    HomeView()
                case .navigation:
                    NavigationModeView()
                case .textReading:
                    TextReadingModeView()
                case .objectAwareness:
                    ObjectAwarenessModeView()
                case .settings:
                    SettingsView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: appState.currentMode)
            
            // Status overlay (always visible)
            VStack {
                Spacer()
                StatusOverlay()
                    .padding(.bottom, 20)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
