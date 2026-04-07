# Common Component Patterns

Ready-to-use SwiftUI patterns following <YOUR_APP> design system and Apple HIG.

---

## Cards

### Basic Card
```swift
struct BasicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(<YOUR_DS>.Spacing.md)
            .background(<YOUR_DS>.Colors.listRowBackground)
            .cornerRadius(<YOUR_DS>.CornerRadius.md)
            .shadow(
                color: <YOUR_DS>.Shadow.small.color,
                radius: <YOUR_DS>.Shadow.small.radius,
                y: <YOUR_DS>.Shadow.small.y
            )
    }
}
```

### Tappable Card
```swift
struct TappableCard<Content: View>: View {
    let action: () -> Void
    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
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
```

### Feature Card (with gradient)
```swift
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(gradient)
                .cornerRadius(<YOUR_DS>.CornerRadius.md)

            Text(title)
                .font(<YOUR_DS>.Typography.headline)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)

            Text(description)
                .font(<YOUR_DS>.Typography.body)
                .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.7))
                .lineLimit(2)
        }
        .padding(<YOUR_DS>.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(<YOUR_DS>.Colors.listRowBackground)
        .cornerRadius(<YOUR_DS>.CornerRadius.lg)
    }
}
```

---

## List Rows

### Standard Row
```swift
struct StandardRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    let showChevron: Bool

    var body: some View {
        HStack(spacing: <YOUR_DS>.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(<YOUR_DS>.Colors.primary)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.xs) {
                Text(title)
                    .font(<YOUR_DS>.Typography.body)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain)

                if let subtitle {
                    Text(subtitle)
                        .font(<YOUR_DS>.Typography.caption)
                        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
                }
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.3))
            }
        }
        .padding(.vertical, <YOUR_DS>.Spacing.sm)
    }
}
```

### Toggle Row
```swift
struct ToggleRow: View {
    let title: String
    let subtitle: String?
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: <YOUR_DS>.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(<YOUR_DS>.Colors.primary)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.xs) {
                Text(title)
                    .font(<YOUR_DS>.Typography.body)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain)

                if let subtitle {
                    Text(subtitle)
                        .font(<YOUR_DS>.Typography.caption)
                        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(<YOUR_DS>.Colors.primary)
        }
        .padding(.vertical, <YOUR_DS>.Spacing.sm)
    }
}
```

---

## Buttons

### Primary Button
```swift
struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: <YOUR_DS>.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(<YOUR_DS>.Typography.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, <YOUR_DS>.Spacing.md)
            .background(<YOUR_DS>.Colors.primary)
            .cornerRadius(<YOUR_DS>.CornerRadius.lg)
        }
        .disabled(isLoading)
    }
}
```

### Secondary Button
```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(<YOUR_DS>.Typography.headline)
                .foregroundColor(<YOUR_DS>.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, <YOUR_DS>.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: <YOUR_DS>.CornerRadius.lg)
                        .stroke(<YOUR_DS>.Colors.primary, lineWidth: 2)
                )
        }
    }
}
```

### Icon Button
```swift
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45))
                .foregroundColor(<YOUR_DS>.Colors.primary)
                .frame(width: size, height: size)
                .background(<YOUR_DS>.Colors.primary.opacity(0.1))
                .cornerRadius(size / 2)
        }
    }
}
```

---

## Headers

### Section Header
```swift
struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?
    let actionTitle: String?

    init(_ title: String, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        self.title = title
        self.action = action
        self.actionTitle = actionTitle
    }

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(<YOUR_DS>.Typography.subheadline)
                .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
                .tracking(0.5)

            Spacer()

            if let action, let actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(<YOUR_DS>.Typography.subheadline)
                        .foregroundColor(<YOUR_DS>.Colors.primary)
                }
            }
        }
        .padding(.horizontal, <YOUR_DS>.Spacing.md)
        .padding(.vertical, <YOUR_DS>.Spacing.sm)
    }
}
```

### Screen Header (with back button)
```swift
struct ScreenHeader: View {
    let title: String
    let showBack: Bool
    let onBack: (() -> Void)?
    let trailingContent: AnyView?

    var body: some View {
        HStack(spacing: <YOUR_DS>.Spacing.md) {
            if showBack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(<YOUR_DS>.Colors.primary)
                }
                .frame(width: 44, height: 44)
            }

            Text(title)
                .font(<YOUR_DS>.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)

            Spacer()

            trailingContent
        }
        .padding(.horizontal, <YOUR_DS>.Spacing.md)
        .padding(.vertical, <YOUR_DS>.Spacing.sm)
    }
}
```

---

## Empty States

### Basic Empty State
```swift
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: <YOUR_DS>.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.2))

            Text(title)
                .font(<YOUR_DS>.Typography.headline)
                .foregroundColor(<YOUR_DS>.Colors.fontMain)

            Text(message)
                .font(<YOUR_DS>.Typography.body)
                .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, <YOUR_DS>.Spacing.xl)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(<YOUR_DS>.Typography.headline)
                        .foregroundColor(<YOUR_DS>.Colors.primary)
                }
                .padding(.top, <YOUR_DS>.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(<YOUR_DS>.Spacing.xl)
    }
}
```

---

## Loading States

### Full Screen Loader
```swift
struct FullScreenLoader: View {
    let message: String?

    var body: some View {
        VStack(spacing: <YOUR_DS>.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(<YOUR_DS>.Colors.primary)

            if let message {
                Text(message)
                    .font(<YOUR_DS>.Typography.body)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(<YOUR_DS>.Colors.backgroundMain)
    }
}
```

### Skeleton Row
```swift
struct SkeletonRow: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: <YOUR_DS>.Spacing.md) {
            Circle()
                .fill(<YOUR_DS>.Colors.fontMain.opacity(0.1))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: <YOUR_DS>.Spacing.xs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(<YOUR_DS>.Colors.fontMain.opacity(0.1))
                    .frame(width: 120, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(<YOUR_DS>.Colors.fontMain.opacity(0.1))
                    .frame(width: 80, height: 12)
            }

            Spacer()
        }
        .padding(<YOUR_DS>.Spacing.md)
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.8).repeatForever(), value: isAnimating)
        .onAppear { isAnimating = true }
    }
}
```

---

## Modals & Sheets

### Confirmation Sheet
```swift
struct ConfirmationSheet: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: <YOUR_DS>.Spacing.lg) {
            VStack(spacing: <YOUR_DS>.Spacing.sm) {
                Text(title)
                    .font(<YOUR_DS>.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain)

                Text(message)
                    .font(<YOUR_DS>.Typography.body)
                    .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: <YOUR_DS>.Spacing.sm) {
                Button(action: onConfirm) {
                    Text(confirmTitle)
                        .font(<YOUR_DS>.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, <YOUR_DS>.Spacing.md)
                        .background(isDestructive ? <YOUR_DS>.Colors.red : <YOUR_DS>.Colors.primary)
                        .cornerRadius(<YOUR_DS>.CornerRadius.lg)
                }

                Button(action: onCancel) {
                    Text(cancelTitle)
                        .font(<YOUR_DS>.Typography.headline)
                        .foregroundColor(<YOUR_DS>.Colors.fontMain.opacity(0.6))
                }
            }
        }
        .padding(<YOUR_DS>.Spacing.lg)
        .background(<YOUR_DS>.Colors.listRowBackground)
        .cornerRadius(<YOUR_DS>.CornerRadius.xl)
        .padding(<YOUR_DS>.Spacing.md)
    }
}
```

---

## Animations

### Spring Transition
```swift
extension AnyTransition {
    static var appSpring: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        )
    }
}

// Usage
.transition(.appSpring)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
```

### Pulse Animation
```swift
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

extension View {
    func pulse() -> some View {
        modifier(PulseModifier())
    }
}
```
