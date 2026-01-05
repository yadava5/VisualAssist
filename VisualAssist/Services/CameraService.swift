//
//  CameraService.swift
//  VisualAssist
//
//  Camera capture and frame processing service
//

import Foundation
@preconcurrency import AVFoundation
import UIKit

/// Service for camera capture and frame processing
final class CameraService: NSObject, ObservableObject, @unchecked Sendable {
    
    // MARK: - Published Properties
    
    @MainActor @Published private(set) var isSessionRunning = false
    @MainActor @Published private(set) var permissionGranted = false
    @MainActor @Published private(set) var error: CameraError?
    @MainActor @Published private(set) var lastCapturedImage: CGImage?
    
    // MARK: - Properties
    
    private let captureSession = AVCaptureSession()
    private var _previewLayer: AVCaptureVideoPreviewLayer?
    
    @MainActor
    var previewLayer: AVCaptureVideoPreviewLayer {
        if _previewLayer == nil {
            _previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            _previewLayer?.videoGravity = .resizeAspectFill
        }
        return _previewLayer!
    }
    
    private let sessionQueue = DispatchQueue(label: "com.visualassist.camera")
    private var videoOutput: AVCaptureVideoDataOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private var isConfigured = false
    private var currentDevice: AVCaptureDevice?
    
    /// Callback for each captured frame
    @MainActor var onFrameCaptured: ((CGImage) -> Void)?
    
    // Thread-safe frame timing using lock
    private var _lastFrameTime: Date = .distantPast
    private let frameTimeLock = NSLock()
    private let frameProcessingInterval: TimeInterval = 0.1 // Process 10 fps
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Permissions
    
    @MainActor
    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            updatePermission(true)
            if !isConfigured {
                setupCaptureSession()
            } else {
                startSessionInternal()
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.updatePermission(granted)
                    if granted {
                        self?.setupCaptureSession()
                    } else {
                        self?.updateError(.permissionDenied)
                    }
                }
            }
            
        case .denied, .restricted:
            updatePermission(false)
            updateError(.permissionDenied)
            
        @unknown default:
            updatePermission(false)
        }
    }
    
    // Separate methods to avoid publishing during view updates
    @MainActor
    private func updatePermission(_ granted: Bool) {
        Task { @MainActor in
            self.permissionGranted = granted
        }
    }
    
    @MainActor
    private func updateError(_ error: CameraError) {
        Task { @MainActor in
            self.error = error
        }
    }
    
    @MainActor
    private func updateRunning(_ running: Bool) {
        Task { @MainActor in
            self.isSessionRunning = running
        }
    }
    
    // MARK: - Session Setup
    
    @MainActor
    private func setupCaptureSession() {
        let session = self.captureSession
        sessionQueue.async { [weak self] in
            self?.configureSession(session: session)
        }
    }
    
    private func configureSession(session: AVCaptureSession) {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // Remove existing inputs/outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            DispatchQueue.main.async { [weak self] in
                self?.updateError(.cameraNotAvailable)
            }
            session.commitConfiguration()
            return
        }
        
        currentDevice = videoDevice
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Configure autofocus
        configureAutoFocus(device: videoDevice)
        
        // Add video output for frame processing
        let videoOutput = AVCaptureVideoDataOutput()
        let outputQueue = DispatchQueue(label: "com.visualassist.videoOutput")
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            self.videoOutput = videoOutput
        }
        
        // Add photo output for freeze-frame capture
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        session.commitConfiguration()
        
        isConfigured = true
        
        // Start session after configuration
        if !session.isRunning {
            session.startRunning()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.updateRunning(true)
        }
    }
    
    // MARK: - Auto Focus
    
    private func configureAutoFocus(device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            // Enable continuous autofocus
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            // Enable continuous auto exposure
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            // Enable auto white balance
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Could not configure autofocus: \(error)")
        }
    }
    
    /// Tap to focus at a specific point
    @MainActor
    func focusAt(point: CGPoint, in viewSize: CGSize) {
        guard let device = currentDevice else { return }
        
        // Convert UI point to camera coordinates
        let focusPoint = CGPoint(
            x: point.y / viewSize.height,
            y: 1 - (point.x / viewSize.width)
        )
        
        sessionQueue.async {
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .autoExpose
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Could not focus: \(error)")
            }
        }
    }
    
    // MARK: - Session Control
    
    @MainActor
    private func startSessionInternal() {
        guard permissionGranted else { return }
        
        let session = captureSession
        sessionQueue.async { [weak self] in
            if !session.isRunning {
                session.startRunning()
                DispatchQueue.main.async {
                    self?.updateRunning(true)
                }
            }
        }
    }
    
    @MainActor
    func stopSession() {
        let session = captureSession
        sessionQueue.async { [weak self] in
            if session.isRunning {
                session.stopRunning()
                DispatchQueue.main.async {
                    self?.updateRunning(false)
                }
            }
        }
    }
    
    // MARK: - Frame Capture
    
    /// Get the last captured frame
    @MainActor
    func captureCurrentFrame() -> CGImage? {
        return lastCapturedImage
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let now = Date()
        
        // Thread-safe frame time check
        frameTimeLock.lock()
        let shouldProcess = now.timeIntervalSince(_lastFrameTime) >= frameProcessingInterval
        if shouldProcess {
            _lastFrameTime = now
        }
        frameTimeLock.unlock()
        
        guard shouldProcess else { return }
        
        // Convert sample buffer to CGImage
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        // Call the frame handler on main thread - delay slightly to avoid view update issues
        DispatchQueue.main.async { [weak self] in
            self?.lastCapturedImage = cgImage
            self?.onFrameCaptured?(cgImage)
        }
    }
}

// MARK: - Camera Error

enum CameraError: Error, LocalizedError {
    case permissionDenied
    case cameraNotAvailable
    case sessionConfigurationFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Camera permission was denied. Please enable it in Settings."
        case .cameraNotAvailable:
            return "Camera is not available on this device."
        case .sessionConfigurationFailed:
            return "Failed to configure camera session."
        }
    }
}
