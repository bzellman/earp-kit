# Apple Human Interface Guidelines Reference

Quick reference for iOS design decisions. Full guidelines at https://developer.apple.com/design/human-interface-guidelines

## Core Principles

### Clarity
- **Text**: Always legible at every size
- **Icons**: Precise, understandable glyphs
- **Functionality**: Focus on primary tasks

### Deference
- Content takes center stage
- UI supports but never competes
- Reduce visual noise

### Depth
- Layers convey hierarchy
- Motion indicates relationships
- Transitions provide context

---

## Navigation Patterns

### NavigationStack (Hierarchical)
```swift
NavigationStack {
    List { ... }
        .navigationTitle("Title")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") { }
            }
        }
}
```

**When to use:** Drilling into detail, content hierarchy

### TabView (Flat)
```swift
TabView {
    HomeView()
        .tabItem { Label("Home", systemImage: "house") }
    ProfileView()
        .tabItem { Label("Profile", systemImage: "person") }
}
```

**When to use:** Parallel top-level destinations (max 5 tabs)

### Sheet (Modal)
```swift
.sheet(isPresented: $showSettings) {
    SettingsView()
}
```

**When to use:** Self-contained tasks, temporary focus

### Full Screen Cover
```swift
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingView()
}
```

**When to use:** Immersive experiences, blocking flows

---

## Layout Guidelines

### Safe Areas
Always respect safe areas unless content should extend edge-to-edge:
```swift
.ignoresSafeArea(.container, edges: .bottom) // For backgrounds only
```

### Spacing Scale
| Use Case | Points |
|----------|--------|
| Tight grouping | 4-8 |
| Related items | 12-16 |
| Section breaks | 20-32 |
| Major divisions | 40+ |

### Touch Targets
- **Minimum**: 44 x 44 points
- **Recommended**: 48 x 48 points for primary actions
- **Spacing**: 8pt minimum between targets

---

## Typography

### System Styles (Preferred)
```swift
.font(.largeTitle)    // 34pt - Screen titles
.font(.title)         // 28pt - Section titles
.font(.title2)        // 22pt - Subsections
.font(.title3)        // 20pt - Emphasized text
.font(.headline)      // 17pt semibold - Row titles
.font(.body)          // 17pt - Primary content
.font(.callout)       // 16pt - Secondary content
.font(.subheadline)   // 15pt - Metadata
.font(.footnote)      // 13pt - Captions
.font(.caption)       // 12pt - Labels
.font(.caption2)      // 11pt - Fine print
```

### Dynamic Type Support
```swift
// Good - scales with user settings
Text("Hello").font(.body)

// Bad - fixed size, ignores accessibility
Text("Hello").font(.system(size: 17))
```

---

## Color Guidelines

### Semantic Colors
```swift
Color.primary          // Adapts to light/dark mode
Color.secondary        // Dimmed content
Color.accentColor      // App tint, interactive elements
```

### Background Hierarchy
```swift
Color(.systemBackground)           // Primary background
Color(.secondarySystemBackground)  // Cards, grouped content
Color(.tertiarySystemBackground)   // Nested content
```

### Contrast Requirements
| Content Type | Minimum Ratio |
|--------------|---------------|
| Body text | 4.5:1 |
| Large text (18pt+) | 3:1 |
| UI components | 3:1 |
| Decorative | No requirement |

---

## Interactive Elements

### Buttons

**Bordered Prominent** (Primary action):
```swift
Button("Submit") { }
    .buttonStyle(.borderedProminent)
```

**Bordered** (Secondary action):
```swift
Button("Cancel") { }
    .buttonStyle(.bordered)
```

**Plain** (Tertiary/links):
```swift
Button("Learn more") { }
    .buttonStyle(.plain)
```

### Lists

**Inset Grouped** (Settings-style):
```swift
List {
    Section("Account") {
        // rows
    }
}
.listStyle(.insetGrouped)
```

**Plain** (Content lists):
```swift
List(items) { item in
    // rows
}
.listStyle(.plain)
```

### Toggles & Controls
```swift
Toggle("Notifications", isOn: $enabled)
Picker("Theme", selection: $theme) { ... }
Slider(value: $volume, in: 0...1)
Stepper("Quantity: \(qty)", value: $qty)
```

---

## Icons (SF Symbols)

### Symbol Rendering Modes
```swift
Image(systemName: "heart.fill")
    .symbolRenderingMode(.monochrome)   // Single color
    .symbolRenderingMode(.hierarchical) // Layered opacity
    .symbolRenderingMode(.palette)      // Multi-color
    .symbolRenderingMode(.multicolor)   // Fixed colors
```

### Common Symbols
| Action | Symbol |
|--------|--------|
| Add | `plus`, `plus.circle.fill` |
| Delete | `trash`, `trash.fill` |
| Edit | `pencil`, `square.and.pencil` |
| Share | `square.and.arrow.up` |
| Settings | `gearshape`, `gearshape.fill` |
| Search | `magnifyingglass` |
| Close | `xmark`, `xmark.circle.fill` |
| Back | `chevron.left` |
| More | `ellipsis`, `ellipsis.circle` |

---

## Animation Guidelines

### Timing
| Type | Duration |
|------|----------|
| Micro-interactions | 0.1-0.2s |
| UI transitions | 0.25-0.35s |
| Page transitions | 0.3-0.5s |
| Complex animations | 0.5-1.0s |

### Curves
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7))  // Bouncy
.animation(.easeInOut(duration: 0.25))                     // Smooth
.animation(.linear(duration: 0.15))                        // Mechanical
```

### Best Practices
- Motion should have purpose (convey meaning)
- Keep animations short and responsive
- Respect "Reduce Motion" accessibility setting:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

.animation(reduceMotion ? .none : .spring())
```

---

## Accessibility Checklist

- [ ] VoiceOver labels for images and icons
- [ ] Accessibility hints for complex interactions
- [ ] Dynamic Type support (no fixed font sizes)
- [ ] Sufficient color contrast
- [ ] Touch targets 44pt minimum
- [ ] Respect Reduce Motion preference
- [ ] Support Bold Text preference
- [ ] Keyboard navigation for external keyboards

```swift
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")
    .accessibilityHint("Double tap to add to favorites")
```

---

## Dark Mode

### Automatic Adaptation
Use semantic colors that adapt automatically:
```swift
Color.primary           // Black in light, white in dark
Color(.systemBackground) // White in light, black in dark
```

### Manual Overrides
```swift
@Environment(\.colorScheme) var colorScheme

let bgColor = colorScheme == .dark ? Color.black : Color.white
```

### Asset Catalogs
Define color sets with "Any" and "Dark" appearances in Assets.xcassets.

---

## Platform Considerations

### iPhone
- Portrait-first design
- Reachability zones (bottom = easy, top = hard)
- Home indicator avoidance
- Dynamic Island awareness

### iPad
- Support multiple size classes
- Consider Split View and Slide Over
- Pointer/trackpad support
- Keyboard shortcuts

```swift
.navigationSplitViewStyle(.balanced)

#if os(iOS)
// iPad-specific layout
#endif
```
