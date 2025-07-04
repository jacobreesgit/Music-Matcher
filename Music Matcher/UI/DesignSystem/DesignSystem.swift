import SwiftUI
import Foundation

// MARK: - Design System for Music Matcher App
// Core design tokens and system definitions used throughout the application.

// MARK: - Color Palette
extension Color {
    // MARK: Primary Colors
    /// Main brand color used for primary actions and accents
    static let designPrimary = Color("AppPrimary") // Blue theme color
    static let designPrimaryDark = Color("AppPrimaryDark") // Darker blue for pressed states
    
    // MARK: Secondary Colors
    /// Secondary action color, typically green for positive actions
    static let designSecondary = Color("AppSecondary") // Green for "Add" actions
    static let designSecondaryDark = Color("AppSecondaryDark") // Darker green for pressed states
    
    // MARK: Semantic Colors
    /// Success state color
    static let designSuccess = Color("AppSuccess") // Green for success messages
    /// Warning state color
    static let designWarning = Color("AppWarning") // Orange for warnings
    /// Error state color
    static let designError = Color("AppError") // Red for errors and stop actions
    /// Info state color
    static let designInfo = Color("AppInfo") // Light blue for informational content
    
    // MARK: Neutral Colors
    /// Primary text color that adapts to light/dark mode
    static let designTextPrimary = Color("AppTextPrimary")
    /// Secondary text color for subtitles and captions
    static let designTextSecondary = Color("AppTextSecondary")
    /// Tertiary text color for disabled states
    static let designTextTertiary = Color("AppTextTertiary")
    
    /// Primary background color
    static let designBackground = Color("AppBackground")
    /// Secondary background for cards and elevated surfaces
    static let designBackgroundSecondary = Color("AppBackgroundSecondary")
    /// Tertiary background for input fields and inactive areas
    static let designBackgroundTertiary = Color("AppBackgroundTertiary")
    
    // MARK: Component-Specific Colors
    /// Card background with subtle transparency
    static let appCardBackground = Color.gray.opacity(0.2)
    /// Overlay background for sheets and modals
    static let appOverlayBackground = Color.black.opacity(0.3)
    
    // MARK: Fallback Colors (for when assets aren't available)
    static let fallbackPrimary = Color.blue
    static let fallbackSecondary = Color.green
    static let fallbackWarning = Color.orange
    static let fallbackError = Color.red
}

// MARK: - Typography System
struct AppFont {
    // MARK: Display Text
    /// Large title for main headers (36pt, bold)
    static let largeTitle = Font.largeTitle.weight(.bold)
    /// Title for section headers (28pt, bold)
    static let title = Font.title.weight(.bold)
    /// Title 2 for subsection headers (22pt, medium)
    static let title2 = Font.title2.weight(.medium)
    /// Title 3 for card headers (20pt, medium)
    static let title3 = Font.title3.weight(.medium)
    
    // MARK: Body Text
    /// Headline for emphasis (17pt, semibold)
    static let headline = Font.headline.weight(.semibold)
    /// Body text for main content (17pt, regular)
    static let body = Font.body
    /// Callout for secondary content (16pt, regular)
    static let callout = Font.callout
    /// Subheadline for metadata (15pt, regular)
    static let subheadline = Font.subheadline
    /// Footnote for fine print (13pt, regular)
    static let footnote = Font.footnote
    /// Caption for labels and tiny text (12pt, regular)
    static let caption = Font.caption
    /// Caption 2 for the smallest text (11pt, regular)
    static let caption2 = Font.caption2
    
    // MARK: Custom Sizes
    /// Extra large numbers for counters and progress
    static let counterLarge = Font.system(size: 36, weight: .bold, design: .rounded)
    /// Medium numbers for counts
    static let counterMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
    /// Small numbers for badges
    static let counterSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // MARK: Icon Fonts
    /// Large icons for main actions
    static let iconLarge = Font.system(size: 60)
    /// Medium icons for secondary actions
    static let iconMedium = Font.system(size: 24)
    /// Small icons for inline elements
    static let iconSmall = Font.system(size: 16)
}

// MARK: - Spacing System
enum AppSpacing {
    /// Extra small spacing (4pt) - for tight layouts
    static let xs: CGFloat = 4
    /// Small spacing (8pt) - for compact elements
    static let small: CGFloat = 8
    /// Medium spacing (16pt) - standard spacing
    static let medium: CGFloat = 16
    /// Large spacing (24pt) - section separation
    static let large: CGFloat = 24
    /// Extra large spacing (32pt) - major section separation
    static let xl: CGFloat = 32
    /// Extra extra large spacing (40pt) - screen padding
    static let xxl: CGFloat = 40
    /// Huge spacing (60pt) - major layout gaps
    static let huge: CGFloat = 60
}

// MARK: - Corner Radius System
enum AppCornerRadius {
    /// Extra small radius for very small elements
    static let xs: CGFloat = 4
    /// Small radius for buttons and small elements
    static let small: CGFloat = 8
    /// Medium radius for cards and inputs
    static let medium: CGFloat = 10
    /// Large radius for prominent buttons
    static let large: CGFloat = 15
    /// Extra large radius for special elements
    static let xl: CGFloat = 20
    /// Circle for fully rounded elements
    static let circle: CGFloat = 50
}

// MARK: - Shadow System
enum AppShadow {
    case light
    case medium
    case heavy
    
    var shadow: Shadow {
        switch self {
        case .light:
            return Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        case .medium:
            return Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        case .heavy:
            return Shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Animation System
enum AppAnimation {
    /// Quick animation for immediate feedback
    static let quick = Animation.easeInOut(duration: 0.2)
    /// Standard animation for most interactions
    static let standard = Animation.easeInOut(duration: 0.3)
    /// Slow animation for major state changes
    static let slow = Animation.easeInOut(duration: 0.5)
    /// Spring animation for bouncy effects
    static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
}

// MARK: - View Extensions
extension View {
    /// Applies app card styling with optional elevation
    func appCardStyle(elevated: Bool = false) -> some View {
        self.modifier(AppCardStyle(elevated: elevated))
    }
    
    /// Applies app shadow styling
    func appShadow(_ shadowType: AppShadow) -> some View {
        self.modifier(AppShadowModifier(shadowType: shadowType))
    }
    
    /// Applies standard app padding
    func appPadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, AppSpacing.medium)
    }
    
    /// Conditional view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Dark Mode Support
extension Color {
    /// Dynamically adapts color based on current color scheme
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Accessibility Support
extension View {
    /// Adds accessibility support with dynamic type sizing
    func accessibleFont(_ font: Font) -> some View {
        self
            .font(font)
            .dynamicTypeSize(.small ... .accessibility2)
    }
    
    /// Adds accessibility label and hint
    func accessibleElement(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
    }
}
