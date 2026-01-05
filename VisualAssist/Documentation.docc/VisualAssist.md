# ``VisualAssist``

Empowering independence through intelligent visual assistance for the visually impaired.

@Metadata {
    @DisplayName("Visual Assist")
    @TitleHeading("Framework")
    @PageColor(blue)
}

## Overview

Visual Assist is a native iOS application designed to help visually impaired users navigate their environment safely and independently. Built with Apple's latest frameworks, it leverages the power of **LiDAR technology**, **ARKit**, and **on-device machine learning** to provide real-time spatial awareness, text recognition, and object detection.

All processing happens entirely on-device, ensuring complete privacy. No data ever leaves your iPhone.

### Requirements

- iPhone 12 Pro or later (LiDAR sensor required)
- iOS 17.0 or later

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Accessibility>

### Operating Modes

- ``NavigationMode``
- ``TextReadingMode``
- ``ObjectAwarenessMode``

### Services

- ``LiDARService``
- ``CameraService``
- ``SpeechService``
- ``HapticService``
- ``TextRecognitionService``
- ``ObjectDetectionService``
- ``VoiceCommandService``

### State Management

- ``AppState``
- ``UserSettings``

### Data Models

- ``DetectedObstacle``
- ``DetectedObject``
- ``RecognizedText``

### Utilities

- ``AccessibilityHelper``
- ``DepthProcessor``
- ``SpatialAudioManager``
