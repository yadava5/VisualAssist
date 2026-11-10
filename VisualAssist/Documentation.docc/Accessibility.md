# Accessibility

What this build implements for blind and low-vision users, and what is still planned.

@Metadata {
    @PageColor(purple)
}

## Overview

Visual Assist is built for visually impaired users, so this page lists only what is traceable to
code. The Accessibility section of the README is the current statement and carries a source
location for every row below.

## What Is Implemented

- **Labels, hints, values and combined elements** on interactive and status views: 53
  `.accessibility*` modifiers across `VisualAssist/Views/`, heaviest in `SettingsView`, `HomeView`,
  `NavigationModeView` and `ObjectAwarenessModeView`.
- **Buttons carry `.isButton` and a spoken label** in `AccessibleButton`, `PrimaryActionButton` and
  `ModeCard`.
- **Decorative art is hidden from VoiceOver**: the `HomeView` header symbol is
  `.accessibilityHidden(true)`.
- **Live status is spoken independent of VoiceOver.** `SpeechService` drives every mode, and
  `AppState.switchMode` calls `speakNow` on every mode change.
- **Launch announcement.** `VisualAssistApp.setupAccessibility()` posts an `.announcement`
  notification.
- **Touch targets above Apple's 44 pt minimum.** `ButtonSize.dimension` is 64, 76 or 88 pt. Nothing
  in the codebase enforces 44 pt; these three values are simply above it.
- **Haptic feedback.** Seven Core Haptics patterns in `HapticService`, including a warning pattern
  for obstacles inside 1.0 m and a critical one inside 0.5 m. On hardware without haptics, every
  pattern falls back to a UIKit feedback generator.

## Planned, Not in This Build

- **Full VoiceOver support.** Labels are present but uneven. `TextReadingModeView` carries one
  `.accessibility*` modifier, and its Slower and Faster speed controls and its debug toggle have no
  label, hint or trait. No VoiceOver audit by a screen reader user has been performed.
- **Dynamic Type.** Semantic text styles scale by default, but nothing uses `dynamicTypeSize` or
  `ScaledMetric`, some fonts are fixed size, and the primary controls sit in fixed frames, so large
  accessibility text sizes will clip. Not verified at any size.
- **Reduce Motion.** The only check is inside `AccessibilityHelper`, which has no call sites. The app's
  animations run unconditionally.
- **High Contrast.** No view reads the system contrast settings, and the translucent materials are
  never reduced.
- **Spatial audio.** `SpatialAudioManager` exists but is never constructed, so no directional audio
  is produced.

No WCAG conformance is claimed.

## See Also

- <doc:GettingStarted>
