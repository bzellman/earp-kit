# iOS Design Skill - Usage Examples

Real-world examples of using the iOS Design Skill for <YOUR_APP>.

---

## Example 1: Simple Component Request

### User Prompt
> "Create a user profile card component"

### Skill Conversation

**Claude:** Which design libraries should I reference for this design?
1. <YOUR_APP> Design System (recommended)
2. Apple Human Interface Guidelines
3. Custom Reference Files
4. Add New References

**User:** 1

**Claude:** Do you have any screenshot references or inspiration?

**User:** No, just use the <YOUR_APP> style

**Claude:** A few questions:
- Should the card be tappable (navigates to profile)?
- What info to display? (Name, avatar, subtitle, stats?)
- Any specific size constraints?

**User:** Yes tappable, show name/avatar/bio, flexible width

### Generated Output

```swift
//
//  UserProfileCard.swift
//  <YOUR_APP>
//

import SwiftUI

struct UserProfileCard: View {
    let name: String
    let bio: String
    let avatarURL: URL?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: <YOUR_DS>.Spacing.md) {
                // Avatar
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(<YOUR_DS>.Gradients.avatar)
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())

                // Info
                VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.xs) {
                    Text(name)
                        .font(<YOUR_DS>.Typography.headline)
                        .foregroundColor(<YOUR_DS>.Colors.fontMain)

                    Text(bio)
                        .font(<YOUR_DS>.Typography.body)
                        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.3))
            }
            .padding(<YOUR_DS>.Spacing.md)
            .background(<YOUR_DS>.Colors.listRowBackground)
            .cornerRadius(<YOUR_DS>.CornerRadius.md)
            .shadow(
                color: <YOUR_DS>.Shadow.small.color,
                radius: <YOUR_DS>.Shadow.small.radius,
                y: <YOUR_DS>.Shadow.small.y
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: <YOUR_DS>.Spacing.md) {
        UserProfileCard(
            name: "Sarah Johnson",
            bio: "Memory keeper, photo enthusiast",
            avatarURL: nil,
            onTap: {}
        )

        UserProfileCard(
            name: "Alex Chen",
            bio: "Documenting life's moments one memory at a time. Living in San Francisco.",
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            onTap: {}
        )
    }
    .padding()
    .background(<YOUR_DS>.Colors.backgroundMain)
}
```

---

## Example 2: Screen with Visual Reference

### User Prompt
> "I need an onboarding welcome screen"

### Skill Conversation

**Claude:** Which design libraries should I reference?
1. <YOUR_APP> Design System
2. Apple Human Interface Guidelines
3. Custom Reference Files
4. Add New References

**User:** 1, 2

**Claude:** Do you have any screenshot references or inspiration?

**User:** *[drops screenshot of Apple's clean onboarding style]*
I like:
- Large centered illustration
- Bold headline
- Short description
- Single prominent CTA

**Claude:** Got it! A few more questions:
- What's the headline text?
- Should there be a "Skip" option?
- Any background animation or static?

**User:** "Welcome to <YOUR_APP>" headline, yes skip option, static background

### Generated Plan (Plan Mode)

```markdown
# Onboarding Welcome Screen Design Plan

## Component Architecture
- `OnboardingWelcomeView` - Main container
- Uses full-screen layout with safe area awareness

## Visual Hierarchy
1. **Illustration Area** (40% of screen)
   - Centered <YOUR_APP> logo or custom illustration
   - Subtle gradient background

2. **Content Area** (35% of screen)
   - Large Title: "Welcome to <YOUR_APP>"
   - Body: Short value proposition

3. **Action Area** (25% of screen)
   - Primary CTA: "Get Started"
   - Secondary: "Skip" text button

## Design Tokens
- Background: <YOUR_DS>.Colors.backgroundMain
- Headline: <YOUR_DS>.Typography.largeTitle
- Body: <YOUR_DS>.Typography.body
- CTA: <YOUR_DS>.Gradients.purpleToBlue with <YOUR_DS>.CornerRadius.lg

## Accessibility
- VoiceOver: Logical reading order
- Dynamic Type: All text scales
- Reduced Motion: No animations to disable
```

### Generated Output (After Approval)

```swift
//
//  OnboardingWelcomeView.swift
//  <YOUR_APP>
//

import SwiftUI

struct OnboardingWelcomeView: View {
    let onGetStarted: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    onSkip()
                }
                .font(<YOUR_DS>.Typography.body)
                .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
            }
            .padding(.horizontal, <YOUR_DS>.Spacing.lg)
            .padding(.top, <YOUR_DS>.Spacing.md)

            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(<YOUR_DS>.Gradients.avatar)
                    .frame(width: 200, height: 200)

                Image(systemName: "memories")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
            }
            .padding(.bottom, <YOUR_DS>.Spacing.xl)

            // Content
            VStack(spacing: <YOUR_DS>.Spacing.md) {
                Text("Welcome to <YOUR_APP>")
                    .font(<YOUR_DS>.Typography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain)
                    .multilineTextAlignment(.center)

                Text("Capture, organize, and relive your most precious memories with the people who matter most.")
                    .font(<YOUR_DS>.Typography.body)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, <YOUR_DS>.Spacing.xl)
            }

            Spacer()

            // CTA
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(<YOUR_DS>.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, <YOUR_DS>.Spacing.md)
                    .background(<YOUR_DS>.Gradients.purpleToBlue)
                    .cornerRadius(<YOUR_DS>.CornerRadius.lg)
            }
            .padding(.horizontal, <YOUR_DS>.Spacing.lg)
            .padding(.bottom, <YOUR_DS>.Spacing.xl)
        }
        .background(<YOUR_DS>.Colors.backgroundMain)
    }
}

#Preview {
    OnboardingWelcomeView(
        onGetStarted: {},
        onSkip: {}
    )
}
```

---

## Example 3: Complex Feature with Multiple States

### User Prompt
> "Design a memory sharing sheet"

### Skill Conversation

**Claude:** Which design libraries should I reference?
1. <YOUR_APP> Design System
2. Apple Human Interface Guidelines
3. Custom Reference Files
4. Add New References

**User:** 1, 2, plus look at `<YOUR_APP>/Features/Sharing/ShareMemoryView.swift` for existing patterns

**Claude:** I'll reference those. Do you have any screenshot references?

**User:** No

**Claude:** Let me ask some clarifying questions:
- What can be shared? (Link, image, full memory?)
- Who can receive shares? (Friends, groups, external?)
- Should this be a sheet or full screen?
- What states: loading, success, error?

**User:** Share memory with friends/groups, half-sheet modal, needs all states

### Generated Plan

```markdown
# Memory Sharing Sheet Design Plan

## States to Design
1. **Default** - Friend/group selection list
2. **Loading** - Sharing in progress
3. **Success** - Confirmation with animation
4. **Error** - Retry option

## Component Architecture
- `ShareMemorySheet` - Main container (presentationDetents)
- `ShareRecipientRow` - Friend/group row item
- `ShareConfirmation` - Success state overlay

## Layout (Half Sheet)
- Drag indicator at top
- Title: "Share Memory"
- Search/filter bar
- Scrollable recipient list
- "Share" button (bottom)

## Interactions
- Multi-select recipients (checkmarks)
- Search filtering
- Pull to dismiss
- Haptic on success
```

---

## Example 4: Using External Reference

### User Prompt
> "Create a meditation timer circle like the Headspace app"

### Skill Conversation

**Claude:** Which design libraries should I reference?
1. <YOUR_APP> Design System
2. Apple Human Interface Guidelines
3. Custom Reference Files
4. Add New References

**User:** 1, 2, 4 - add https://www.headspace.com for reference

**Claude:** I'll note the Headspace reference for visual inspiration. Do you have specific screenshots?

**User:** *[drops screenshot of Headspace timer]*
I like the circular progress, the calming colors, and the centered time display

**Claude:** Great reference! Questions:
- Should this use <YOUR_APP>'s color palette or Headspace-inspired colors?
- Animated progress or static?
- What controls: play/pause, duration selector?

**User:** <YOUR_APP> colors but calm tones, animated, just play/pause

### Design Approach

The skill would:
1. Extract circular progress pattern from reference
2. Map to <YOUR_APP>'s softer colors (primary3, primary4)
3. Apply <YOUR_DS> typography for time display
4. Follow HIG for touch targets on controls

---

## Tips for Best Results

### Do:
- Select appropriate design libraries upfront
- Provide screenshot references when possible
- Be specific about states and interactions
- Mention existing components to match

### Don't:
- Skip the library selection (defaults may miss context)
- Assume Claude knows your preferences
- Request multiple unrelated components at once
- Forget accessibility requirements

### Effective Prompts:
- "Design a [component] that matches our [existing component]"
- "Create a [screen] following Apple's [specific pattern]"
- "Build a [feature] with loading, empty, and error states"
- "Make a [component] inspired by [app/screenshot] but using <YOUR_APP>'s style"
