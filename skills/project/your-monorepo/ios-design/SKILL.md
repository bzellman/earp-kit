---
name: ios-design
description: Design and implement SwiftUI interfaces for <YOUR_APP> iOS app with design system compliance, Apple HIG principles, and visual references. Triggers when creating UI components, screens, or discussing iOS design. Gathers design library preferences, screenshot references, and requirements before implementation.
---

# iOS Design Skill for <YOUR_APP>

Create production-grade SwiftUI interfaces that leverage the <YOUR_APP> design system while following Apple Human Interface Guidelines. This skill guides you through a structured design process before generating code.

## Activation Triggers

This skill activates when you:
- Request a new SwiftUI view or screen
- Ask to design or redesign a UI component
- Need help with iOS layout or visual design
- Want to implement a feature with UI considerations
- Mention "design", "UI", "SwiftUI", "screen", "view", or "component" in iOS context

---

## Design Conversation Flow

When this skill activates, Claude will guide you through these steps:

### Step 1: Design Library Selection

**Claude asks:** "Which design libraries should I reference for this design?"

**Available Options:**
1. **<YOUR_APP> Design System** (recommended) - Your established tokens, colors, typography
2. **Apple Human Interface Guidelines** - Platform conventions and accessibility
3. **Custom Reference Files** - Specific SwiftUI files from your codebase
4. **Add New References** - Provide comma-separated file paths or URLs

You can select multiple options (e.g., "1, 2" for <YOUR_APP> DS + Apple HIG).

### Step 2: Visual References (Optional)

**Claude asks:** "Do you have any screenshot references or inspiration images?"

If yes:
- Drag and drop images into the conversation
- For each image, describe:
  - What you like about it
  - Specific elements to incorporate
  - How it relates to your design goal

### Step 3: Clarifying Questions

Based on your request, Claude may ask about:
- **Component scope**: Single component, screen, or flow?
- **State handling**: What states need visual treatment? (loading, empty, error, success)
- **Interactivity**: Animations, gestures, transitions needed?
- **Accessibility**: VoiceOver labels, Dynamic Type support level?
- **Device targets**: iPhone only, iPad support, specific orientations?

### Step 4: Plan Mode Design

After gathering context, Claude enters **Plan Mode** to:
1. Outline the component architecture
2. Map design tokens to use (colors, typography, spacing)
3. Define the view hierarchy
4. Identify reusable components from existing codebase
5. Plan animations and interactions

**Output:** A design plan document with SwiftUI view structure for your approval.

### Step 5: Implementation

Upon plan approval, Claude generates:
- Production-ready SwiftUI code
- Preview providers for different states
- Integration guidance with existing views

---

## Design Libraries Reference

### <YOUR_APP> Design System

**Location:** @<YOUR_APP>/<YOUR_APP>/Shared/UI/DesignSystem/<YOUR_APP>DesignSystem.swift

**Usage Pattern:**
```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack(spacing: <YOUR_DS>.Spacing.md) {
            Text("Title")
                .font(<YOUR_DS>.Typography.headline)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)

            Text("Body text")
                .font(<YOUR_DS>.Typography.body)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)
        }
        .padding(<YOUR_DS>.Spacing.lg)
        .background(<YOUR_DS>.Colors.backgroundMain)
        .cornerRadius(<YOUR_DS>.CornerRadius.md)
    }
}
```

**Available Tokens:**

| Category | Access | Examples |
|----------|--------|----------|
| Colors | `<YOUR_DS>.Colors.*` | `.primary`, `.fontMain`, `.backgroundMain`, `.accent` |
| Typography | `<YOUR_DS>.Typography.*` | `.headline`, `.body`, `.caption`, `.title` |
| Spacing | `<YOUR_DS>.Spacing.*` | `.xs` (4), `.sm` (8), `.md` (16), `.lg` (24), `.xl` (32) |
| Corner Radius | `<YOUR_DS>.CornerRadius.*` | `.sm` (8), `.md` (12), `.lg` (16) |
| Shadows | `<YOUR_DS>.Shadow.*` | `.small`, `.medium`, `.large` |
| Gradients | `<YOUR_DS>.Gradients.*` | `.purpleToBlue`, `.avatar`, `.glassMorphism` |
| Button Styles | `<YOUR_DS>.ButtonStyles.*` | `.primary()`, `.filter()`, `.selectable()` |

### Apple Human Interface Guidelines

**Key Principles to Follow:**

1. **Clarity** - Text is legible, icons precise, adornments subtle
2. **Deference** - UI helps understanding, never competes with content
3. **Depth** - Visual layers and motion convey hierarchy

**Platform Patterns:**
- Navigation: NavigationStack with toolbar items
- Lists: Inset grouped style for settings, plain for content
- Buttons: Prominent for primary actions, bordered for secondary
- Feedback: SF Symbols for icons, haptics for confirmation

**Accessibility Requirements:**
- Support Dynamic Type (use `.font()` not hardcoded sizes)
- Minimum 44pt touch targets
- Sufficient color contrast (4.5:1 for text)
- VoiceOver labels for non-text elements

### Existing Component Library

**Location:** @<YOUR_APP>/<YOUR_APP>/Shared/UI/ViewComponents/

**Reusable Components:**
- `UnifiedMemoryRowView` - List row with image, title, metadata
- `PhotoCarouselViewer` - Horizontal image gallery
- `UserProfilePicture` - Avatar with gradient fallback
- `CustomProgressView` - Branded loading indicator
- `<YOUR_APP>AlertView` - Standardized alert presentation
- `CardSectionModifier` - Card-style section wrapper
- `FABContentContainer` - Floating action button container

---

## Design Principles for <YOUR_APP>

### Visual Identity
- **Color Palette**: Deep sea blues, soft teals, natural greens
- **Typography**: Inter for headlines, Roboto for body text
- **Imagery**: Rounded corners, subtle shadows, gradient accents
- **Motion**: Smooth spring animations, meaningful transitions

### Component Guidelines

**Cards:**
```swift
.background(<YOUR_DS>.Colors.listRowBackground)
.cornerRadius(<YOUR_DS>.CornerRadius.md)
.shadow(
    color: <YOUR_DS>.Shadow.small.color,
    radius: <YOUR_DS>.Shadow.small.radius,
    y: <YOUR_DS>.Shadow.small.y
)
```

**Primary Buttons:**
```swift
Button("Action") { }
    .font(<YOUR_DS>.Typography.headline)
    .foregroundColor(<YOUR_DS>.Colors.fontLight)
    .padding(.horizontal, <YOUR_DS>.Spacing.lg)
    .padding(.vertical, <YOUR_DS>.Spacing.sm)
    .background(<YOUR_DS>.Colors.primary)
    .cornerRadius(<YOUR_DS>.CornerRadius.lg)
```

**Section Headers:**
```swift
Text("Section Title")
    .font(<YOUR_DS>.Typography.subheadline)
    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
    .textCase(.uppercase)
```

---

## Example Workflow

**User:** "I need a profile settings screen"

**Claude (Step 1):** "Which design libraries should I reference?
1. <YOUR_APP> Design System
2. Apple Human Interface Guidelines
3. Custom Reference Files
4. Add New References (comma-separated paths)"

**User:** "1, 2"

**Claude (Step 2):** "Do you have any screenshot references or inspiration?"

**User:** *drops screenshot* "I like the grouped sections in this Settings app screenshot"

**Claude (Step 3):** "A few questions:
- Should this include avatar editing capability?
- What settings sections do you need? (Account, Notifications, Privacy, etc.)
- Any specific animations for toggling settings?"

**User:** "Yes to avatar, need Account and Notifications sections, simple toggle animations"

**Claude (Step 4):** *Enters Plan Mode, creates design document*

**Claude (Step 5):** *Generates SwiftUI implementation upon approval*

---

## File References

When generating designs, Claude will reference:
- @<YOUR_APP>/<YOUR_APP>/Shared/UI/DesignSystem/<YOUR_APP>DesignSystem.swift
- @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>Colors.swift
- @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>Spacing.swift
- @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>TypographyGenerated.swift
- @<YOUR_APP>/<YOUR_APP>/Shared/UI/ViewComponents/ExtensionsAndCustomizations.swift

---

## Quality Checklist

Before delivering any design, verify:

- [ ] Uses `<YOUR_DS>.*` tokens (no hardcoded colors/sizes)
- [ ] Follows Apple HIG navigation patterns
- [ ] Includes PreviewProvider with multiple states
- [ ] Supports Dynamic Type
- [ ] Has appropriate touch target sizes (44pt minimum)
- [ ] Uses existing ViewComponents where applicable
- [ ] Includes loading, empty, and error states
- [ ] Animations use `.spring()` or `.easeInOut`
