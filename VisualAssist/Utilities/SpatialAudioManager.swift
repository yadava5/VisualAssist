//
//  SpatialAudioManager.swift
//  VisualAssist
//
//  Spatial audio for directional obstacle alerts
//

import Foundation
import AVFoundation

/// Manager for spatial audio cues indicating obstacle direction
class SpatialAudioManager: ObservableObject {
    
    // MARK: - Properties
    
    @Published var isEnabled = true
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var environmentNode: AVAudioEnvironmentNode?
    
    private var alertSounds: [AlertType: AVAudioPCMBuffer] = [:]
    
    // MARK: - Alert Types
    
    enum AlertType {
        case obstacle
        case warning
        case critical
    }
    
    enum Direction {
        case left
        case center
        case right
        case above
        case below
        
        var position: AVAudio3DPoint {
            switch self {
            case .left: return AVAudio3DPoint(x: -1, y: 0, z: -1)
            case .center: return AVAudio3DPoint(x: 0, y: 0, z: -1)
            case .right: return AVAudio3DPoint(x: 1, y: 0, z: -1)
            case .above: return AVAudio3DPoint(x: 0, y: 1, z: -1)
            case .below: return AVAudio3DPoint(x: 0, y: -1, z: -1)
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupAudioEngine()
        loadSounds()
    }
    
    // MARK: - Setup
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        environmentNode = AVAudioEnvironmentNode()
        
        guard let engine = audioEngine,
              let player = playerNode,
              let environment = environmentNode else { return }
        
        engine.attach(player)
        engine.attach(environment)
        
        // Connect player to environment for spatialization
        engine.connect(player, to: environment, format: nil)
        engine.connect(environment, to: engine.mainMixerNode, format: nil)
        
        // Configure environment
        environment.listenerPosition = AVAudio3DPoint(x: 0, y: 0, z: 0)
        environment.renderingAlgorithm = .HRTFHQ // Head-related transfer function for realistic spatial audio
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadSounds() {
        // In a real implementation, you would load custom sound files
        // For now, we'll generate simple tones
        alertSounds[.obstacle] = generateTone(frequency: 440, duration: 0.1)
        alertSounds[.warning] = generateTone(frequency: 660, duration: 0.15)
        alertSounds[.critical] = generateTone(frequency: 880, duration: 0.2)
    }
    
    /// Generate a simple tone as AVAudioPCMBuffer
    private func generateTone(frequency: Float, duration: Float) -> AVAudioPCMBuffer? {
        let sampleRate: Float = 44100
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData?[0] else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let time = Float(frame) / sampleRate
            let amplitude: Float = 0.5
            let value = amplitude * sin(2.0 * .pi * frequency * time)
            channelData[frame] = value
        }
        
        return buffer
    }
    
    // MARK: - Playback
    
    /// Play a directional alert
    func playAlert(type: AlertType, direction: Direction, distance: Float? = nil) {
        guard isEnabled,
              let player = playerNode,
              let buffer = alertSounds[type] else { return }
        
        // Set position based on direction
        player.position = direction.position
        
        // Adjust volume based on distance if provided
        if let distance = distance {
            let volume = max(0.1, min(1.0, 2.0 / distance))
            player.volume = volume
        }
        
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }
    
    /// Play a panning sweep to indicate direction
    func playDirectionalSweep(from startDirection: Direction, to endDirection: Direction, duration: TimeInterval = 0.5) {
        guard isEnabled, let player = playerNode else { return }
        
        let startPos = startDirection.position
        let endPos = endDirection.position
        let steps = 10
        
        for i in 0...steps {
            let t = Float(i) / Float(steps)
            let x = startPos.x + (endPos.x - startPos.x) * t
            let y = startPos.y + (endPos.y - startPos.y) * t
            let z = startPos.z + (endPos.z - startPos.z) * t
            
            let delay = duration * Double(i) / Double(steps)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.playerNode?.position = AVAudio3DPoint(x: x, y: y, z: z)
            }
        }
        
        if let buffer = alertSounds[.obstacle] {
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            player.play()
        }
    }
    
    // MARK: - Cleanup
    
    func stop() {
        playerNode?.stop()
        audioEngine?.stop()
    }
    
    deinit {
        stop()
    }
}
