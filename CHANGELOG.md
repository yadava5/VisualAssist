# Changelog

All notable changes to VisualAssist will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Apple Watch companion app
- Indoor mapping and floor plan recognition
- Currency and banknote identification
- Multi-language support for text reading
- Voice commands: `VoiceCommandService` is written but nothing in the app creates it yet
- Spatial audio cues for detected objects: `SpatialAudioManager` is written but never constructed
- A Core ML object detector, so Object Awareness can name more than people, cats and dogs
- Wiring the Settings detection distance into Navigation mode, and the speech rate and haptic intensity sliders into its obstacle alerts
- Full VoiceOver support and Dynamic Type

---

## [0.1.0-beta] - 2026-01-05

### Added
- **Navigation Mode** - Real-time obstacle detection using LiDAR depth sensing
- **Object Awareness Mode** - People, cat and dog detection with Apple's Vision framework, and a spoken scene summary built from those counts
- **Text Reading Mode** - OCR-based text recognition with speech output
- **Haptic Feedback** - Intuitive haptic patterns for proximity warnings
- **Accessibility** - Labels and hints on the main views, and live status spoken independent of VoiceOver. Full VoiceOver support and Dynamic Type are planned, not in this build
- **Settings Panel** - Speech rate and haptic intensity sliders. They do not yet reach Navigation mode's obstacle alerts, and the detection distance setting is stored but not read

### Technical
- iOS 17.0+ support
- LiDAR-equipped iPhone requirement (12 Pro and newer)
- ARKit integration for depth processing
- Vision framework for text recognition and for people and animal detection
- Core Haptics for haptic feedback
- AVFoundation for camera and speech services

### Documentation
- Comprehensive README with setup instructions
- DocC documentation catalog
- Contributing guidelines
- Security policy
- Code of conduct

---

## Version History

| Version | Date | Status |
|---------|------|--------|
| 0.1.0-beta | 2026-01-05 | Current Beta |

---

[Unreleased]: https://github.com/yadava5/VisualAssist/compare/v0.1.0-beta...HEAD
[0.1.0-beta]: https://github.com/yadava5/VisualAssist/releases/tag/v0.1.0-beta
