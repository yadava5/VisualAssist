# Getting Started with Visual Assist

Learn how to set up and use Visual Assist for the first time.

@Metadata {
    @PageColor(green)
}

## Overview

Visual Assist has three operating modes for helping visually impaired users navigate their
environment. The README is the current statement of what this build does.

1. **Navigation Mode.** Real-time obstacle detection using LiDAR.
2. **Text Reading Mode.** Point-and-read text recognition with spoken output.
3. **Object Awareness Mode.** Detects people, cats and dogs with Apple's Vision framework and
   builds a spoken scene summary from those counts. No Core ML model is loaded in this build.

## First Launch

When you first launch Visual Assist:

1. **Wait for Ready.** The app announces "Visual Assist ready. Swipe to explore modes."
2. **Select a Mode.** Tap any mode card.
3. **Grant Camera Access.** The app asks for the camera the first time you enter a mode. It is the
   only permission requested at runtime.

## Haptic Feedback

Visual Assist uses distinct haptic patterns to communicate:

| Pattern | Meaning |
|---------|---------|
| One light tap | Pause, resume, speed change or count people |
| One strong tap | Mode changed |
| Two taps | Freeze captured, scene described or live reading started |
| Three pulses | Obstacle inside 1.0 m |
| Continuous vibration for 0.5 s | Obstacle inside 0.5 m |

## Planned, Not in This Build

- **Voice commands.** `VoiceCommandService` defines the commands and a speech recognition pipeline,
  but nothing in the app creates it, so the Voice Commands toggle has no effect and the microphone
  and speech recognition permissions are never requested.
- **Spatial audio.** `SpatialAudioManager` exists but is never constructed, so no directional audio
  is produced.

## Tips for Best Results

- **Hold steady.** Keep the phone at chest height, camera facing forward.
- **Move slowly.** Allow the sensors time to scan the environment.
- **Listen for direction.** Obstacle alerts say whether the obstacle is ahead, on your left or on
  your right.

## See Also

- <doc:Accessibility>
