# Contributing to Visual Assist

Thank you for your interest in Visual Assist! This project is designed to help visually impaired users navigate their environment. Your contributions can make a real difference in people's lives.

---

## 📋 Before You Start

Visual Assist is maintained by a single developer. Before making significant changes, please:

1. **Check existing issues** — Your idea may already be tracked
2. **Open a discussion** — For major features, let's talk first
3. **Read this guide** — Understand our standards and process

---

## 🐛 Reporting Bugs

Found a bug? Help me fix it by providing:

| Information | Details |
|:------------|:--------|
| **Device** | iPhone model (e.g., iPhone 15 Pro) |
| **iOS Version** | e.g., iOS 17.2 |
| **Steps** | How to reproduce the issue |
| **Expected** | What should happen |
| **Actual** | What actually happens |
| **Screenshots** | If applicable |

### Bug Report Template

```markdown
**Device:** iPhone 15 Pro
**iOS:** 17.2

**Steps to reproduce:**
1. Open the app
2. Tap Navigation Mode
3. ...

**Expected:** The app should...
**Actual:** Instead, the app...
```

---

## 💡 Feature Requests

Have an idea? Consider these questions:

- **Who benefits?** How does this help visually impaired users?
- **Accessibility?** How would it work with VoiceOver?
- **Privacy?** Does it keep data on-device?
- **Scope?** Is it feasible for the current architecture?

---

## 🔧 Pull Requests

### Process

1. **Fork** the repository
2. **Branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Develop** following our coding standards
4. **Test** on a physical device if possible
5. **Commit** with clear messages
6. **Push** and open a PR

### Coding Standards

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Clear, descriptive names
- Concise functions with single responsibility
- Comments for complex logic
- SwiftUI best practices

### Accessibility Requirements

**Every UI element must have:**

```swift
// ✅ Good
Button("Start Navigation") { ... }
    .accessibilityLabel("Start Navigation")
    .accessibilityHint("Double tap to begin obstacle detection")
    .accessibilityAddTraits(.isButton)

// ❌ Bad  
Button("Start") { ... }  // Missing context for VoiceOver
```

### Commit Messages

Use conventional commit format:

```
feat: Add currency recognition feature
fix: Correct haptic timing in navigation mode
docs: Update README with voice commands
refactor: Simplify depth processing algorithm
style: Format code with SwiftLint
```

---

## ✅ PR Checklist

Before submitting, ensure:

- [ ] Code compiles without warnings
- [ ] VoiceOver navigation works correctly
- [ ] Haptic feedback is appropriate
- [ ] No memory leaks
- [ ] Accessibility labels are complete
- [ ] Works on iPhone Pro models (for LiDAR features)

---

## 📁 Project Structure

```
VisualAssist/
├── App/           # App lifecycle and state management
├── Views/         # SwiftUI views and components
├── Services/      # Business logic and device APIs
├── Models/        # Data structures and types
├── Utilities/     # Helper functions and extensions
└── Resources/     # Assets and configuration
```

### Adding a New Feature

1. **Service** — Add business logic in `Services/`
2. **Model** — Define data structures in `Models/`
3. **View** — Create UI in `Views/`
4. **State** — Connect via `AppState.swift`
5. **Accessibility** — Ensure full VoiceOver support

---

## 📜 License Note

By contributing, you agree that your contributions will be licensed under the project's **CC BY-NC 4.0** license. This means:

- ✓ Your code can be shared and adapted
- ✗ It cannot be used commercially without the author's permission

---

## 🙏 Thank You

Every contribution helps make Visual Assist better for the visually impaired community. Whether it's fixing a typo, reporting a bug, or adding a feature — your help is appreciated!

---

<p align="center">
  <sub>Maintained by Ayush • © 2026</sub>
</p>
