//
//  ObjectAwarenessModeView.swift
//  VisualAssist
//
//  Object detection and scene description using Core ML
//

import SwiftUI
import Vision

struct ObjectAwarenessModeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var objectDetectionService = ObjectDetectionService()
    @StateObject private var cameraService = CameraService()
    
    @State private var detectedObjects: [DetectedObject] = []
    @State private var sceneDescription = ""
    @State private var isDescribing = false
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(cameraService: cameraService)
                .ignoresSafeArea()
            
            // Detection overlay
            detectionOverlay
            
            // Controls
            VStack {
                topBar
                
                Spacer()
                
                // Scene description
                if !sceneDescription.isEmpty {
                    sceneDescriptionCard
                }
                
                // Detected objects list
                if !detectedObjects.isEmpty {
                    objectsList
                }
                
                controlButtons
            }
            .padding()
        }
        .onAppear {
            startDetection()
            appState.hapticService.play(.modeSwitch)
        }
        .onDisappear {
            stopDetection()
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Button(action: { appState.switchMode(to: .home) }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
            }
            .accessibilityLabel("Back to home")
            
            Spacer()
            
            // Object count
            HStack(spacing: 8) {
                Image(systemName: "cube.fill")
                Text("\(detectedObjects.count) objects")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
            .accessibilityLabel("\(detectedObjects.count) objects detected")
        }
    }
    
    // MARK: - Detection Overlay
    
    private var detectionOverlay: some View {
        GeometryReader { geometry in
            ForEach(detectedObjects) { object in
                let rect = object.boundingBox.applying(
                    CGAffineTransform(scaleX: geometry.size.width, y: geometry.size.height)
                        .translatedBy(x: 0, y: 1)
                        .scaledBy(x: 1, y: -1)
                )
                
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .strokeBorder(colorForCategory(object.category), lineWidth: 3)
                    
                    Text(object.label)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(4)
                        .background(colorForCategory(object.category))
                }
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
            }
        }
    }
    
    // MARK: - Scene Description Card
    
    private var sceneDescriptionCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "text.bubble.fill")
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(sceneDescription)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.3))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Scene description: \(sceneDescription)")
    }
    
    // MARK: - Objects List
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(detectedObjects) { object in
                    ObjectCard(object: object)
                }
            }
        }
        .frame(height: 100)
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Describe scene
            AccessibleButton(
                icon: "text.bubble.fill",
                label: "Describe",
                color: .purple,
                size: .large
            ) {
                describeScene()
            }
            
            // Count people
            AccessibleButton(
                icon: "person.2.fill",
                label: "Count People",
                color: .blue
            ) {
                countPeople()
            }
            
            // Identify colors
            AccessibleButton(
                icon: "paintpalette.fill",
                label: "Colors",
                color: .pink
            ) {
                identifyColors()
            }
        }
    }
    
    // MARK: - Actions
    
    private func startDetection() {
        cameraService.startSession()
        cameraService.onFrameCaptured = { image in
            Task {
                let objects = await objectDetectionService.detectObjects(in: image)
                await MainActor.run {
                    detectedObjects = objects
                }
            }
        }
    }
    
    private func stopDetection() {
        cameraService.stopSession()
        appState.speechService.stop()
    }
    
    private func describeScene() {
        guard !isDescribing else { return }
        isDescribing = true
        
        let description = objectDetectionService.generateSceneDescription(from: detectedObjects)
        sceneDescription = description
        
        appState.speechService.speak(description) {
            isDescribing = false
        }
        appState.hapticService.play(.success)
    }
    
    private func countPeople() {
        let peopleCount = detectedObjects.filter { $0.label == "person" }.count
        
        let message: String
        if peopleCount == 0 {
            message = "No people detected"
        } else if peopleCount == 1 {
            message = "1 person detected"
        } else {
            message = "\(peopleCount) people detected"
        }
        
        appState.speechService.speak(message)
        appState.hapticService.play(.tap)
    }
    
    private func identifyColors() {
        Task {
            if let image = cameraService.captureCurrentFrame() {
                let dominantColor = await objectDetectionService.identifyDominantColor(in: image)
                appState.speechService.speak("The dominant color is \(dominantColor)")
                appState.hapticService.play(.tap)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func colorForCategory(_ category: ObjectCategory) -> Color {
        switch category {
        case .person: return .blue
        case .vehicle: return .red
        case .furniture: return .orange
        case .electronics: return .purple
        case .food: return .green
        case .animal: return .yellow
        case .other: return .gray
        }
    }
}

// MARK: - Object Card

struct ObjectCard: View {
    let object: DetectedObject
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: object.category.icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(object.label)
                .font(.caption.bold())
                .foregroundColor(.white)
            
            Text("\(Int(object.confidence * 100))%")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 80, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(object.label), \(Int(object.confidence * 100)) percent confidence")
    }
}

#Preview {
    ObjectAwarenessModeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
