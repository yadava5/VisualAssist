//
//  CameraPreview.swift
//  VisualAssist
//
//  Camera preview component using AVFoundation
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraService: CameraService
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.setupPreviewLayer(with: cameraService)
    }
}

// MARK: - Camera Preview UIView

class CameraPreviewUIView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var currentCameraService: CameraService?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    @MainActor
    func setupPreviewLayer(with cameraService: CameraService) {
        // Only setup once or if service changed
        guard currentCameraService !== cameraService else {
            previewLayer?.frame = bounds
            return
        }
        
        currentCameraService = cameraService
        
        // Remove old layer
        previewLayer?.removeFromSuperlayer()
        
        // Add new preview layer
        let layer = cameraService.previewLayer
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(layer)
        previewLayer = layer
        
        // Start the camera session
        cameraService.startSession()
    }
}

// MARK: - Alternative Preview View

struct CameraPreviewView: View {
    @StateObject var cameraService: CameraService
    
    var body: some View {
        GeometryReader { geometry in
            CameraPreview(cameraService: cameraService)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }
}
