# Color System Documentation

## Overview

This document outlines the centralized color system for the Context app, designed to ensure consistency, maintainability, and easy theming across all UI components.

## Architecture

### 1. Centralized Color Palette (`AppColors.swift`)

The color system is organized into four main categories:

```swift
AppColors.Gray.*        // Gray scale system
AppColors.Semantic.*    // Semantic colors (status, meaning)
AppColors.Component.*   // UI component colors
AppColors.Tree.*        // Tree visualization colors
```

### 2. Color Hierarchy

#### Gray Scale System
- **Darkest** (`#1a1a1a`) - Deep backgrounds, modals
- **Darker** (`#2a2a2a`) - Secondary surfaces, buttons
- **Dark** (`#3a3a3a`) - Primary surfaces, borders
- **Medium** (`#4a4a4a`) - Hover/selected states
- **Light** (`#606060`) - Accent elements
- **Lighter** (`#707070`) - Medium contrast elements
- **Lightest** (`#a0a0a0`) - High contrast, borders

#### Semantic Colors
- **Success** (`#10B981`) - Completed states, positive actions
- **Info** (`#3B82F6`) - Active states, information
- **Warning** (`yellow`) - Pending states, caution
- **Error** (`#EF4444`) - Failed states, destructive actions
- **Neutral** (`#6B7280`) - Default states

## Best Practices

### 1. ✅ Do's

```swift
// Use semantic color names
.background(AppColors.Component.surfacePrimary)
.foregroundColor(AppColors.Semantic.textPrimary)

// Use convenience extensions
.standardSurface()
.hoverSurface(isHovered: isHovered)
.selectedSurface(isSelected: isSelected)

// Use semantic colors for status
.foregroundColor(AppColors.Semantic.success)
```

### 2. ❌ Don'ts

```swift
// Don't use hardcoded hex values
.background(Color(hex: "#3a3a3a"))

// Don't use arbitrary colors
.background(Color.black)

// Don't repeat styling patterns
.background(Color(hex: "#3a3a3a"))
.clipShape(RoundedRectangle(cornerRadius: 8))
.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#4a4a4a")))
```

## Usage Patterns

### 1. Standard Surface Pattern

```swift
// Before
.background(Color(hex: "#3a3a3a"))
.clipShape(RoundedRectangle(cornerRadius: 8))
.overlay(
    RoundedRectangle(cornerRadius: 8)
        .stroke(Color(hex: "#4a4a4a"), lineWidth: 1)
)

// After
.standardSurface()
```

### 2. Interactive States

```swift
// Before
.background(
    isHovered ? Color(hex: "#4a4a4a") : Color(hex: "#3a3a3a")
)

// After
.hoverSurface(isHovered: isHovered)
```

### 3. Status Indicators

```swift
// Before
switch status {
case .completed: return Color(hex: "#10B981")
case .active: return Color(hex: "#3B82F6")
case .failed: return Color(hex: "#EF4444")
}

// After
switch status {
case .completed: return AppColors.Semantic.success
case .active: return AppColors.Semantic.info
case .failed: return AppColors.Semantic.error
}
```

## Migration Strategy

### Phase 1: Core Components
1. Replace all `Color(hex: "#3a3a3a")` with `AppColors.Component.surfacePrimary`
2. Replace all `Color(hex: "#2a2a2a")` with `AppColors.Component.surfaceSecondary`
3. Replace all `Color(hex: "#4a4a4a")` with `AppColors.Component.surfaceHover`

### Phase 2: Semantic Colors
1. Replace status colors with semantic equivalents
2. Replace text colors with semantic text colors
3. Update error/success states

### Phase 3: Convenience Extensions
1. Replace repeated styling patterns with convenience extensions
2. Standardize surface styling across components
3. Implement consistent hover/selected states

## Color Mapping Reference

### Current → New Mapping

| Current Hex | New Reference | Usage |
|-------------|---------------|-------|
| `#1a1a1a` | `AppColors.Gray.darkest` | Modal backgrounds |
| `#2a2a2a` | `AppColors.Component.surfaceSecondary` | Secondary surfaces |
| `#3a3a3a` | `AppColors.Component.surfacePrimary` | Primary surfaces |
| `#4a4a4a` | `AppColors.Component.surfaceHover` | Hover states |
| `#606060` | `AppColors.Gray.light` | Tree accents |
| `#707070` | `AppColors.Gray.lighter` | Tree edges |
| `#a0a0a0` | `AppColors.Gray.lightest` | High contrast |

### Component-Specific Usage

#### Drawers (Templates, Models, Files)
- **Background**: `AppColors.Component.surfacePrimary`
- **Hover**: `AppColors.Component.surfaceHover`
- **Border**: `AppColors.Component.borderPrimary`

#### Buttons
- **Primary**: `AppColors.Component.buttonPrimary`
- **Secondary**: `AppColors.Component.buttonSecondary`
- **Hover**: `AppColors.Component.buttonHover`

#### Text
- **Primary**: `AppColors.Semantic.textPrimary`
- **Secondary**: `AppColors.Semantic.textSecondary`
- **Tertiary**: `AppColors.Semantic.textTertiary`

## Example Implementations

### 1. Drawer Component

```swift
struct MyDrawer: View {
    @State private var hoveredItem: String?
    
    var body: some View {
        VStack {
            ForEach(items) { item in
                Button(action: { /* action */ }) {
                    HStack {
                        Text(item.title)
                            .foregroundColor(AppColors.Semantic.textPrimary)
                        Spacer()
                        Text(item.subtitle)
                            .foregroundColor(AppColors.Semantic.textSecondary)
                    }
                    .padding()
                    .hoverSurface(isHovered: hoveredItem == item.id)
                }
                .onHover { isHovered in
                    hoveredItem = isHovered ? item.id : nil
                }
            }
        }
        .standardSurface(cornerRadius: 16)
    }
}
```

### 2. Status Badge

```swift
struct StatusBadge: View {
    let status: TaskStatus
    
    var body: some View {
        Text(status.title)
            .font(.caption)
            .foregroundColor(AppColors.Semantic.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    
    private var statusColor: Color {
        switch status {
        case .completed: return AppColors.Semantic.success
        case .active: return AppColors.Semantic.info
        case .failed: return AppColors.Semantic.error
        case .pending: return AppColors.Semantic.warning
        }
    }
}
```

## Benefits

1. **Consistency**: All components use the same color palette
2. **Maintainability**: Change colors in one place to update entire app
3. **Accessibility**: Semantic colors make it easier to maintain contrast ratios
4. **Theming**: Easy to implement dark/light mode or custom themes
5. **Developer Experience**: Clear naming makes color purpose obvious
6. **Design System**: Enforces consistent design patterns

## Future Enhancements

1. **Theme Support**: Add support for multiple themes (dark/light)
2. **Accessibility**: Add high contrast mode support
3. **Dynamic Colors**: Support for system-adaptive colors
4. **Color Tokens**: Export colors for design tools (Figma, Sketch)
5. **Validation**: Add compile-time validation for color usage

## Conclusion

The centralized color system provides a foundation for consistent, maintainable UI design. By following these patterns and gradually migrating existing code, we can ensure a cohesive visual experience across the entire application.

For questions or suggestions, please refer to the implementation in `AppColors.swift` or create an issue for discussion. 