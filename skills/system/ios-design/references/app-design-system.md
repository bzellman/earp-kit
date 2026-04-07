# <YOUR_APP> Design System Reference

The authoritative design system for the <YOUR_APP> iOS app. All components should use these tokens.

---

## Quick Start

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack(spacing: <YOUR_DS>.Spacing.md) {
            Text("Headline")
                .font(<YOUR_DS>.Typography.headline)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)

            Text("Body text goes here")
                .font(<YOUR_DS>.Typography.body)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)
        }
        .padding(<YOUR_DS>.Spacing.lg)
        .background(<YOUR_DS>.Colors.backgroundMain)
        .cornerRadius(<YOUR_DS>.CornerRadius.md)
    }
}
```

---

## Colors

### Primary Brand Colors
| Token | Access | Hex | Usage |
|-------|--------|-----|-------|
| Blue | `<YOUR_DS>.Colors.blue` | - | Interactive elements |
| Purple | `<YOUR_DS>.Colors.purple` | - | Accents, gradients |
| Orange | `<YOUR_DS>.Colors.orange` | - | Warnings, highlights |
| Cyan | `<YOUR_DS>.Colors.cyan` | - | Information |
| Green | `<YOUR_DS>.Colors.green` | - | Success, positive |
| Red | `<YOUR_DS>.Colors.red` | - | Errors, destructive |

### Semantic Colors
| Token | Access | Usage |
|-------|--------|-------|
| Font Main | `<YOUR_DS>.Colors.fontMain` | Primary text (#2B3C44) |
| Font Light | `<YOUR_DS>.Colors.fontLight` | Text on dark backgrounds (#F3E9DB) |
| Background Main | `<YOUR_DS>.Colors.backgroundMain` | General backgrounds (#C7D1CC) |
| Background Dark | `<YOUR_DS>.Colors.backgroundDark` | Dark mode backgrounds (#F2E8DB) |

### Accent Colors
| Token | Access | Usage |
|-------|--------|-------|
| Accent | `<YOUR_DS>.Colors.accent` | Primary accent |
| Accent 2 | `<YOUR_DS>.Colors.accent2` | Secondary accent |
| Accent Dark | `<YOUR_DS>.Colors.accentDark` | Dark navy (#00008B) |
| Accent Funk | `<YOUR_DS>.Colors.accentFunk` | Light background (#EEF8FC) |
| Accent Light | `<YOUR_DS>.Colors.accentLight` | Success green (#70DF9B) |

### Primary Palette (Brand Gradient)
| Token | Access | Hex | Description |
|-------|--------|-----|-------------|
| Primary | `<YOUR_DS>.Colors.primary` | #2B5973 | Deep Sea Blue |
| Primary 1 | `<YOUR_DS>.Colors.primary1` | #4D8C8F | Primary Green |
| Primary 2 | `<YOUR_DS>.Colors.primary2` | - | Soft Teal |
| Primary 3 | `<YOUR_DS>.Colors.primary3` | #A6D9B3 | Soft Green |
| Primary 4 | `<YOUR_DS>.Colors.primary4` | #ABEAEA | Light Sea Blue |

### UI Colors
| Token | Access | Usage |
|-------|--------|-------|
| List Row Background | `<YOUR_DS>.Colors.listRowBackground` | Card/row backgrounds (#F8F8F8) |

---

## Typography

### Font Families
- **Headlines** (largeTitle → subheadline): Inter
- **Body Text** (body → caption2): Roboto

### Size Scale
| Style | Access | Size | Font |
|-------|--------|------|------|
| Large Title | `<YOUR_DS>.Typography.largeTitle` | 28pt | Inter |
| Title | `<YOUR_DS>.Typography.title` | 24pt | Inter |
| Title 2 | `<YOUR_DS>.Typography.title2` | 20pt | Inter |
| Title 3 | `<YOUR_DS>.Typography.title3` | 18pt | Inter |
| Headline | `<YOUR_DS>.Typography.headline` | 16pt | Inter (semibold) |
| Subheadline | `<YOUR_DS>.Typography.subheadline` | 14pt | Inter |
| Body | `<YOUR_DS>.Typography.body` | 15pt | Roboto |
| Callout | `<YOUR_DS>.Typography.callout` | 14pt | Roboto |
| Footnote | `<YOUR_DS>.Typography.footnote` | 12pt | Roboto |
| Caption | `<YOUR_DS>.Typography.caption` | 11pt | Roboto |
| Caption 2 | `<YOUR_DS>.Typography.caption2` | 10pt | Roboto |

### Usage Examples
```swift
// Screen title
Text("My Memories")
    .font(<YOUR_DS>.Typography.largeTitle)

// Section header
Text("Recent")
    .font(<YOUR_DS>.Typography.headline)

// Body content
Text("This is the main content text")
    .font(<YOUR_DS>.Typography.body)

// Metadata/timestamp
Text("2 hours ago")
    .font(<YOUR_DS>.Typography.caption)
    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
```

---

## Spacing

| Token | Access | Value | Usage |
|-------|--------|-------|-------|
| XS | `<YOUR_DS>.Spacing.xs` | 4pt | Tight groupings, icon padding |
| SM | `<YOUR_DS>.Spacing.sm` | 8pt | Related items, inline spacing |
| MD | `<YOUR_DS>.Spacing.md` | 16pt | Standard padding, stack spacing |
| LG | `<YOUR_DS>.Spacing.lg` | 24pt | Section padding, larger gaps |
| XL | `<YOUR_DS>.Spacing.xl` | 32pt | Major section breaks |
| XXL | `<YOUR_DS>.Spacing.xxl` | 48pt | Page-level spacing |

### Usage Examples
```swift
// Standard card padding
.padding(<YOUR_DS>.Spacing.md)

// Vertical stack with medium spacing
VStack(spacing: <YOUR_DS>.Spacing.md) { ... }

// Horizontal padding, vertical tight
.padding(.horizontal, <YOUR_DS>.Spacing.lg)
.padding(.vertical, <YOUR_DS>.Spacing.sm)
```

---

## Corner Radius

| Token | Access | Value | Usage |
|-------|--------|-------|-------|
| XS | `<YOUR_DS>.CornerRadius.xs` | 4pt | Small chips, tags |
| SM | `<YOUR_DS>.CornerRadius.sm` | 8pt | Buttons, small cards |
| MD | `<YOUR_DS>.CornerRadius.md` | 12pt | Cards, containers |
| LG | `<YOUR_DS>.CornerRadius.lg` | 16pt | Large cards, modals |
| XL | `<YOUR_DS>.CornerRadius.xl` | 20pt | Feature cards |
| XXL | `<YOUR_DS>.CornerRadius.xxl` | 24pt | Full-width cards |

---

## Shadows

| Token | Access | Radius | Y-Offset | Usage |
|-------|--------|--------|----------|-------|
| Small | `<YOUR_DS>.Shadow.small` | 5pt | 2pt | Subtle elevation |
| Medium | `<YOUR_DS>.Shadow.medium` | 15pt | 8pt | Cards, popovers |
| Large | `<YOUR_DS>.Shadow.large` | 20pt | 10pt | Modals, prominent cards |

### Usage Example
```swift
.shadow(
    color: <YOUR_DS>.Shadow.medium.color,
    radius: <YOUR_DS>.Shadow.medium.radius,
    x: <YOUR_DS>.Shadow.medium.x,
    y: <YOUR_DS>.Shadow.medium.y
)
```

---

## Gradients

| Token | Access | Usage |
|-------|--------|-------|
| Purple to Blue | `<YOUR_DS>.Gradients.purpleToBlue` | CTAs, highlights |
| Avatar | `<YOUR_DS>.Gradients.avatar` | Profile pictures |
| Add Button | `<YOUR_DS>.Gradients.addButton` | FAB, add actions |
| Glass Morphism | `<YOUR_DS>.Gradients.glassMorphism` | Overlays |
| Field Type | `<YOUR_DS>.Gradients.forFieldType(_:)` | Memory field colors |

### Usage Example
```swift
RoundedRectangle(cornerRadius: <YOUR_DS>.CornerRadius.lg)
    .fill(<YOUR_DS>.Gradients.purpleToBlue)

// Dynamic gradient based on memory type
.background(<YOUR_DS>.Gradients.forFieldType(entry.fieldType))
```

---

## Button Styles

### Primary Button
```swift
Button("Primary Action") { }
    .buttonStyle(<YOUR_DS>.ButtonStyles.primary())
```

### Filter Button
```swift
Button("Filter") { }
    .modifier(<YOUR_DS>.ButtonStyles.filter(includeBackground: true))
```

### Custom Primary Button Pattern
```swift
Button(action: { }) {
    Text("Submit")
        .font(<YOUR_DS>.Typography.headline)
        .foregroundColor(<YOUR_DS>.Colors.fontLight)
        .padding(.horizontal, <YOUR_DS>.Spacing.lg)
        .padding(.vertical, <YOUR_DS>.Spacing.sm)
        .background(<YOUR_DS>.Colors.primary)
        .cornerRadius(<YOUR_DS>.CornerRadius.lg)
}
```

---

## Common Patterns

### Card Container
```swift
VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.sm) {
    // Card content
}
.padding(<YOUR_DS>.Spacing.md)
.background(<YOUR_DS>.Colors.listRowBackground)
.cornerRadius(<YOUR_DS>.CornerRadius.md)
.shadow(
    color: <YOUR_DS>.Shadow.small.color,
    radius: <YOUR_DS>.Shadow.small.radius,
    y: <YOUR_DS>.Shadow.small.y
)
```

### Section Header
```swift
Text("SECTION TITLE")
    .font(<YOUR_DS>.Typography.subheadline)
    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
    .textCase(.uppercase)
    .tracking(0.5)
```

### List Row
```swift
HStack(spacing: <YOUR_DS>.Spacing.sm) {
    // Leading content (image, icon)
    VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.xs) {
        Text("Title")
            .font(<YOUR_DS>.Typography.headline)
        Text("Subtitle")
            .font(<YOUR_DS>.Typography.caption)
            .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
    }
    Spacer()
    // Trailing content (accessory)
}
.padding(<YOUR_DS>.Spacing.md)
```

### Empty State
```swift
VStack(spacing: <YOUR_DS>.Spacing.md) {
    Image(systemName: "tray")
        .font(.system(size: 48))
        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.3))
    Text("No Items")
        .font(<YOUR_DS>.Typography.headline)
    Text("Items you add will appear here")
        .font(<YOUR_DS>.Typography.body)
        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
        .multilineTextAlignment(.center)
}
.padding(<YOUR_DS>.Spacing.xl)
```

---

## Source Files

- **Main Definition:** @<YOUR_APP>/<YOUR_APP>/Shared/UI/DesignSystem/<YOUR_APP>DesignSystem.swift
- **Colors:** @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>Colors.swift
- **Spacing:** @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>Spacing.swift
- **Typography:** @<YOUR_APP>/<YOUR_APP>/DesignSystem/Generated/<YOUR_APP>TypographyGenerated.swift
- **Extensions:** @<YOUR_APP>/<YOUR_APP>/Shared/UI/ViewComponents/ExtensionsAndCustomizations.swift
