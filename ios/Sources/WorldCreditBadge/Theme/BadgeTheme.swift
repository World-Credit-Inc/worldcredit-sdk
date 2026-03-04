import SwiftUI

/// Theme configuration for World Credit badges
public struct BadgeTheme {
    public let colorScheme: ColorScheme?
    public let backgroundColor: Color
    public let textColor: Color
    public let secondaryTextColor: Color
    public let borderColor: Color
    public let shadowColor: Color
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    
    public init(
        colorScheme: ColorScheme? = nil,
        backgroundColor: Color,
        textColor: Color,
        secondaryTextColor: Color,
        borderColor: Color,
        shadowColor: Color,
        cornerRadius: CGFloat = 8,
        borderWidth: CGFloat = 1
    ) {
        self.colorScheme = colorScheme
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
    }
}

extension BadgeTheme {
    /// Light theme configuration
    public static let light = BadgeTheme(
        colorScheme: .light,
        backgroundColor: .white,
        textColor: Color(red: 0.1, green: 0.1, blue: 0.1),
        secondaryTextColor: Color(red: 0.4, green: 0.4, blue: 0.4),
        borderColor: Color(red: 0.9, green: 0.9, blue: 0.9),
        shadowColor: Color.black.opacity(0.1),
        cornerRadius: 8,
        borderWidth: 1
    )
    
    /// Dark theme configuration
    public static let dark = BadgeTheme(
        colorScheme: .dark,
        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.1),
        textColor: .white,
        secondaryTextColor: Color(red: 0.7, green: 0.7, blue: 0.7),
        borderColor: Color(red: 0.3, green: 0.3, blue: 0.3),
        shadowColor: Color.black.opacity(0.3),
        cornerRadius: 8,
        borderWidth: 1
    )
    
    /// Automatic theme that adapts to system appearance
    public static let automatic = BadgeTheme(
        colorScheme: nil,
        backgroundColor: Color(UIColor.systemBackground),
        textColor: Color(UIColor.label),
        secondaryTextColor: Color(UIColor.secondaryLabel),
        borderColor: Color(UIColor.separator),
        shadowColor: Color.black.opacity(0.1),
        cornerRadius: 8,
        borderWidth: 1
    )
}

/// Theme-aware styling helpers
public struct BadgeStyle {
    let theme: BadgeTheme
    let tierType: TierType
    
    public init(theme: BadgeTheme, tierType: TierType) {
        self.theme = theme
        self.tierType = tierType
    }
    
    /// Primary tier color with theme consideration
    public var tierColor: Color {
        tierType.color
    }
    
    /// Background color for tier-specific elements
    public var tierBackgroundColor: Color {
        if theme.colorScheme == .dark {
            return tierColor.opacity(0.2)
        } else {
            return tierColor.opacity(0.1)
        }
    }
    
    /// Text color for tier-specific text
    public var tierTextColor: Color {
        if theme.colorScheme == .dark {
            return tierColor
        } else {
            return tierColor.opacity(0.8)
        }
    }
    
    /// Shadow configuration
    public var shadowRadius: CGFloat { 4 }
    public var shadowOffset: CGSize { CGSize(width: 0, height: 2) }
}

/// View modifier for applying badge theme
public struct BadgeThemeModifier: ViewModifier {
    let theme: BadgeTheme
    
    public func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor)
            .foregroundColor(theme.textColor)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.borderColor, lineWidth: theme.borderWidth)
            )
            .shadow(
                color: theme.shadowColor,
                radius: 4,
                x: 0,
                y: 2
            )
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
}

extension View {
    /// Apply badge theme to any view
    public func badgeTheme(_ theme: BadgeTheme) -> some View {
        self.modifier(BadgeThemeModifier(theme: theme))
    }
}