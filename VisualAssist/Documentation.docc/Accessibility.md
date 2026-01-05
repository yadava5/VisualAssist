# Accessibility

Visual Assist is designed with accessibility as a core principle.

@Metadata {
    @PageColor(purple)
}

## Overview

Every feature in Visual Assist has been designed to work seamlessly with iOS accessibility features. The app is built specifically for visually impaired users and follows Apple's Human Interface Guidelines for accessibility.

## VoiceOver Support

Visual Assist provides full VoiceOver support:

- **All UI elements** have descriptive accessibility labels
- **Actions** include helpful hints explaining what happens when activated
- **Live regions** announce important status changes
- **Custom actions** provide quick access to common functions

### Best Practices Used

```swift
Button("Start Navigation") { ... }
    .accessibilityLabel("Start Navigation")
    .accessibilityHint("Double tap to begin obstacle detection")
    .accessibilityAddTraits(.isButton)
```

## Dynamic Type

All text in Visual Assist responds to the system's Dynamic Type settings:

- **Headlines** scale appropriately for readability
- **Body text** maintains comfortable reading sizes
- **Touch targets** remain accessible at all sizes (minimum 44pt)

## Motion Sensitivity

Visual Assist respects the "Reduce Motion" accessibility setting:

- Animations are simplified or removed
- Transitions are instant rather than animated
- Visual effects are minimized

## High Contrast

When High Contrast mode is enabled:

- Text contrast is increased
- Borders become more visible
- Background transparency is reduced

## Audio & Haptic Feedback

Visual Assist provides rich non-visual feedback:

### Audio
- **Spoken descriptions** of the environment
- **Earcons** for common actions
- **Spatial audio** indicating direction of objects

### Haptic
- **Pattern-based feedback** for different obstacle distances
- **Confirmation taps** for user actions
- **Warning vibrations** for critical obstacles

## See Also

- <doc:GettingStarted>
