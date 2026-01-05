# App Icon Design Guide

> Design guidelines for the Visual Assist app icon

---

## Design Philosophy

The Visual Assist icon embodies our mission: **empowering independence through intelligent visual assistance**. Every element has been carefully chosen to represent accessibility, technology, and trust.

---

## Icon Elements

<table>
<tr>
<td width="50%" valign="top">

### Visual Elements

| Element | Meaning |
|:--------|:--------|
| **Eye Symbol** | Vision, awareness, assistance |
| **Radiating Waves** | LiDAR scanning, spatial awareness |
| **Gradient** | Technology meets accessibility |
| **Rounded Shape** | iOS design language |

</td>
<td width="50%" valign="top">

### Color Palette

| Color | Hex | Usage |
|:------|:----|:------|
| Primary Blue | `#007AFF` | Trust, technology |
| Accessibility Purple | `#5856D6` | Accessibility, depth |
| White | `#FFFFFF` | Icon symbol |

</td>
</tr>
</table>

---

## Specifications

### Required Sizes

| Size | Scale | Usage |
|:-----|:------|:------|
| 1024×1024 | — | App Store |
| 180×180 | @3x | iPhone |
| 120×120 | @2x | iPhone |
| 167×167 | @2x | iPad Pro |
| 152×152 | @2x | iPad |
| 76×76 | @1x | iPad |

### iOS Guidelines

- **Corner radius**: 22.37% (applied automatically by iOS)
- **No transparency**: Solid background required
- **No alpha channel**: PNG without transparency
- **Color space**: sRGB

---

## Generation Methods

### Method 1: Swift Script (Recommended)

Use the included Swift scripts to generate icons:

```bash
# Generate app icon
swift Assets/generate_icon.swift

# Generate banner for README
swift Assets/generate_banner.swift
```

### Method 2: Design Tools

**Figma/Sketch Specifications:**

```
Canvas: 1024×1024px

Background Layer:
├── Fill: Linear Gradient (135°)
│   ├── Start: #007AFF
│   └── End: #5856D6
└── No corner radius (iOS applies automatically)

Symbol Layer:
├── SF Symbol: eye.circle.fill
├── Color: #FFFFFF
├── Size: 614×614px (60%)
└── Position: Centered

Optional Glow:
├── Color: #FFFFFF
├── Opacity: 20%
└── Blur: 60px
```

### Method 3: SF Symbols App

1. Open **SF Symbols** on macOS
2. Search for `eye.circle.fill`
3. Export with custom colors
4. Apply gradient background in Preview/Photoshop

---

## File Locations

```
VisualAssist/
├── Assets/
│   ├── AppIcon.png           # 1024×1024 master
│   ├── generate_icon.swift   # Icon generator script
│   └── generate_banner.swift # Banner generator script
└── VisualAssist/
    └── Resources/
        └── Assets.xcassets/
            └── AppIcon.appiconset/
                └── Contents.json     # Xcode icon catalog
```

---

## Accessibility Considerations

The icon design considers accessibility:

- **High contrast** — White symbol on colored background
- **Simple shape** — Easily recognizable at small sizes
- **Universal symbol** — Eye represents vision assistance
- **Color blind safe** — Blue/purple works for most color vision types

---

<p align="center">
  <sub>© 2026 Ayush. All rights reserved.</sub>
</p>
