# Pattern: Design-OS Product Design Commands

## Overview

A 10-command suite for AI-driven product design, from vision to export. Each command handles one stage of the product design lifecycle.

Attribution: this pattern is adapted from Design OS by Brian Casel / Builder Methods. See `docs/upstream-attribution.md`.

## The Command Pipeline

```
product-vision -> product-roadmap -> data-model -> design-tokens
     -> design-shell -> design-screen -> shape-section
     -> sample-data -> screenshot-design -> export-product
```

### Stage 1: Strategy
- **`/design-os:product-vision`** - Define the product vision, target users, and value proposition
- **`/design-os:product-roadmap`** - Break vision into phases with prioritized features

### Stage 2: Foundation
- **`/design-os:data-model`** - Define the data model that backs the product
- **`/design-os:design-tokens`** - Establish design tokens (colors, spacing, typography, shadows)

### Stage 3: Structure
- **`/design-os:design-shell`** - Create the app shell (navigation, layout, chrome)
- **`/design-os:design-screen`** - Design individual screens within the shell

### Stage 4: Detail
- **`/design-os:shape-section`** - Design individual sections/components within screens
- **`/design-os:sample-data`** - Generate realistic sample data for all designed screens

### Stage 5: Output
- **`/design-os:screenshot-design`** - Capture design screenshots for review
- **`/design-os:export-product`** - Export the complete product design

## Why This Pattern Works

Product design is inherently sequential - you can't design screens without a shell, and you can't design a shell without tokens. This command pipeline enforces that sequence while letting you skip or repeat stages as needed.

Each command is self-contained but context-aware. Running `/design-screen` after `/design-shell` automatically uses the shell's navigation and layout as constraints.

## When to Use

- New product/feature ideation
- Rapid prototyping with AI-generated UI
- Design system establishment for a new project
- Product planning workshops

## See Also

- `commands/design-os/` - All 10 command files
- `skills/project/<YOUR_MOBILE_APP>/frontend-design/` - Related frontend design skill
