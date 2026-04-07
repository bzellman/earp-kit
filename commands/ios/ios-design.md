---
description: Design SwiftUI interfaces with <YOUR_APP> design system and Apple HIG
---

# iOS Design Command

You are now in **iOS Design Mode**. Follow the conversation flow from the ios-design skill.

## Step 1: Design Library Selection

Ask the user which design libraries to reference:

```
Which design libraries should I reference for this design?

1. **<YOUR_APP> Design System** - Your established tokens (<YOUR_DS>.*)
2. **Apple Human Interface Guidelines** - Platform conventions
3. **Custom Reference Files** - Specific SwiftUI files from the codebase
4. **Add New References** - Provide file paths or URLs (comma-separated)

You can select multiple (e.g., "1, 2")
```

Wait for their response before proceeding.

## Step 2: Visual References

Ask:
```
Do you have any screenshot references or inspiration images?

If yes, drag them into the chat. For each image, tell me:
- What you like about it
- Specific elements to incorporate
- How it relates to your design goal

If no, just say "no" or "skip"
```

Wait for their response.

## Step 3: Clarifying Questions

Based on the user's request ($ARGUMENTS), ask relevant questions about:
- Component scope (single component, screen, or flow?)
- State handling (loading, empty, error, success states needed?)
- Interactivity (animations, gestures, transitions?)
- Accessibility requirements
- Device targets (iPhone, iPad, orientations?)

## Step 4: Plan Mode

After gathering context, enter Plan Mode to:
1. Outline component architecture
2. Map design tokens to use
3. Define view hierarchy
4. Identify reusable components
5. Plan animations/interactions

Write a design plan and use ExitPlanMode for approval.

## Step 5: Implementation

Generate production SwiftUI code that:
- Uses `<YOUR_DS>.*` tokens exclusively
- Includes PreviewProvider with multiple states
- Follows Apple HIG patterns
- Supports Dynamic Type and accessibility

## Reference Files

Load these for context:
- @.claude/skills/ios-design/references/app-design-system.md
- @.claude/skills/ios-design/references/apple-hig.md
- @.claude/skills/ios-design/patterns/common-components.md
- @<YOUR_APP>/<YOUR_APP>/Shared/UI/DesignSystem/<YOUR_APP>DesignSystem.swift

## User Request

$ARGUMENTS
