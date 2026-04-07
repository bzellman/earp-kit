---
name: brand-guidelines
description: Applies <YOUR_APP>'s official brand colors and typography to any artifact. Use when brand colors, style guidelines, visual formatting, or company design standards apply.
license: Complete terms in LICENSE.txt
---

# <YOUR_APP> Brand Styling

## Overview

Apply <YOUR_APP>'s official brand identity from the design system. Reference: `<YOUR_APP>/DesignSystem/Tokens/design-tokens.json`

**Keywords**: branding, <YOUR_APP>, visual identity, design tokens, brand colors, typography, styling

## Brand Colors

### Primary Palette
- **Deep Sea Blue** `#2B5973` - Main brand color
- **Primary Green** `#4D8C8F` - Secondary brand color
- **Soft Teal** `#8FC7BF` - Tertiary
- **Soft Green** `#A6D9B3` - Quaternary
- **Light Sea Blue** `#ABEAEA` - Light accent

### Accent Colors
- **Accent Light** `#70DF9B` - Success/positive actions
- **Accent Dark** `#00008B` - Dark Navy (buttons, emphasis)
- **Accent Funk** `#EEF8FC` - Light background accent

### Background & Text
- **Background Main** `#C7D1CC` - General view background
- **Background Dark** `#F2E8DB` - Sand Beige (dark mode)
- **Font Main** `#2B3C44` - Primary text
- **Font Light** `#F3E9DB` - Text on dark backgrounds
- **List Row** `#F8F8F8` - Light list backgrounds

## Typography

### Font Families
- **Headlines**: Inter (system-ui fallback)
- **Body Text**: Roboto (system-ui fallback)

### Type Scale
| Style | Size | Font | Weight |
|-------|------|------|--------|
| Large Title | 28pt | Inter | Regular |
| Title | 24pt | Inter | Regular |
| Title 2 | 20pt | Inter | Regular |
| Title 3 | 18pt | Inter | Regular |
| Headline | 16pt | Inter | Semibold |
| Subheadline | 14pt | Inter | Regular |
| Body | 15pt | Roboto | Regular |
| Callout | 14pt | Roboto | Regular |
| Footnote | 12pt | Roboto | Regular |
| Caption | 11pt | Roboto | Regular |
| Caption 2 | 10pt | Roboto | Regular |

## Spacing & Layout

### Spacing Scale
- **xs**: 4pt | **sm**: 8pt | **md**: 16pt
- **lg**: 24pt | **xl**: 32pt | **xxl**: 48pt

### Corner Radius
- **sm**: 4pt | **md**: 8pt (default buttons)
- **lg**: 12pt (cards) | **xl**: 18pt | **full**: circular

## Component Styles

### Buttons
**Primary**: Dark Navy `#00008B` bg, Light `#F3E9DB` text, 8pt radius, 50pt height, 18pt bold
**Secondary**: Funk `#EEF8FC` bg, Main `#2B3C44` text, 8pt radius, 44pt height, 16pt semibold
**Filter**: Dark Navy bg, white text, 12pt radius

### Cards
White `#FFFFFF` background, 18pt corner radius, 8pt padding

## Brand Voice

**Positioning:** *"<YOUR_APP> speaks with warmth, reverence, and clarity."*

**Tagline:** *"Where every story is honored — and every storyteller feels valued."*

### Core Attributes
- **Warmly Reflective** — Gentle, human, emotionally intelligent. Speak like a trusted family member or close friend.
- **Empathetically Clear** — Simple, direct language with emotional intelligence. Never cold or robotic.
- **Invitingly Personal** — Celebrate individuality. Stories are personal — tone invites rather than instructs.
- **Thoughtfully Curious** — Nudge users to explore memories without being pushy. Curious, not clinical.

### Voice Compass

**<YOUR_APP> Should Sound:**
- Emotional: Warm, sincere
- Intelligent: Thoughtful, intuitive
- Friendly: Supportive, conversational
- Purposeful: Quietly confident

**<YOUR_APP> Should Not Sound:**
- Emotional: Sentimental or overly poetic
- Intelligent: Academic or complex
- Friendly: Casual or flippant
- Purposeful: Pushy or salesy

## Technical Details

### Color Application
- Use hex values for precise brand matching
- RGB values available in design-tokens.json for programmatic use
- Always use Font Main `#2B3C44` for primary text
- Use Font Light `#F3E9DB` on dark backgrounds

### Font Application
- Headlines (16pt+): Inter font family
- Body text: Roboto font family
- Falls back to system-ui if custom fonts unavailable
