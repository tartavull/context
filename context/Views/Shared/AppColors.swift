import SwiftUI

// MARK: - App Color Palette
/// Centralized color system for consistent theming across the app
struct AppColors {
    
    // MARK: - Gray Scale System
    /// Primary gray scale from darkest to lightest
    struct Gray {
        static let darkest = Color(hex: "#1a1a1a")     // Template edit modal background
        static let darker = Color(hex: "#2a2a2a")      // Model drawer default, edit buttons
        static let dark = Color(hex: "#3a3a3a")        // File drawer, template drawer default, borders
        static let medium = Color(hex: "#4a4a4a")      // Hover states, selected states
        static let light = Color(hex: "#606060")       // Tree node accent
        static let lighter = Color(hex: "#707070")     // Tree edges, medium elements
        static let lightest = Color(hex: "#a0a0a0")    // Tree node borders, descriptions
    }
    
    // MARK: - Semantic Colors
    /// Colors with specific semantic meaning
    struct Semantic {
        // Status colors
        static let success = Color(hex: "#10B981")     // Green - completed status
        static let info = Color(hex: "#3B82F6")        // Blue - active status  
        static let warning = Color.yellow              // Yellow - pending status
        static let error = Color(hex: "#EF4444")       // Red - failed status, close buttons
        static let neutral = Color(hex: "#6B7280")     // Gray - default status
        
        // Text colors
        static let textPrimary = Color.white           // Primary text
        static let textSecondary = Color.gray          // Secondary text, descriptions
        static let textTertiary = Gray.lightest        // Tertiary text
    }
    
    // MARK: - Component Colors
    /// Colors for specific UI components
    struct Component {
        // Backgrounds - using FileDrawer's preferred gray as standard
        static let surfacePrimary = Gray.dark          // Primary surface (drawers, cards) - #3a3a3a
        static let surfaceSecondary = Gray.darker      // Secondary surface (buttons, inputs) - #2a2a2a
        static let surfaceHover = Gray.medium          // Hover states - #4a4a4a
        static let surfaceSelected = Gray.medium       // Selected states - #4a4a4a
        
        // Borders
        static let borderPrimary = Gray.dark           // Primary borders
        static let borderSecondary = Gray.darker       // Secondary borders
        static let borderSelected = Gray.lightest      // Selected borders
        
        // Interactive elements
        static let buttonPrimary = Gray.dark
        static let buttonSecondary = Gray.darker
        static let buttonHover = Gray.medium
        
        // Modal and overlay
        static let modalBackground = Gray.darkest
        static let overlayBackground = Gray.dark
    }
    
    // MARK: - Tree System Colors
    /// Colors specific to the tree visualization
    struct Tree {
        static let nodeBackground = Gray.darker        // Node background
        static let nodeBorderDefault = Gray.light      // Default node border
        static let nodeBorderSelected = Gray.lightest  // Selected node border
        static let edgeActive = Gray.lightest          // Active edge
        static let edgeInactive = Gray.lighter         // Inactive edge
        static let canvasBackground = Color(red: 27/255, green: 27/255, blue: 27/255)
        static let canvasBorder = Color(hex: "#3d3d3d")
    }
}

// MARK: - Color Extension
extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Convenience Extensions
extension View {
    /// Apply standard surface styling with consistent colors
    func standardSurface(cornerRadius: CGFloat = 8) -> some View {
        self
            .background(AppColors.Component.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
    }
    
    /// Apply hover state styling
    func hoverSurface(isHovered: Bool, cornerRadius: CGFloat = 8) -> some View {
        self
            .background(isHovered ? AppColors.Component.surfaceHover : AppColors.Component.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
    }
    
    /// Apply selected state styling
    func selectedSurface(isSelected: Bool, cornerRadius: CGFloat = 8) -> some View {
        self
            .background(isSelected ? AppColors.Component.surfaceSelected : AppColors.Component.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isSelected ? AppColors.Component.borderSelected : AppColors.Component.borderPrimary, lineWidth: 1)
            )
    }
}