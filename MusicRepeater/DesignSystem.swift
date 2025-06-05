import SwiftUI
import Foundation

// MARK: - Design System for MusicRepeater App
// A comprehensive, self-contained design system that consolidates all UI patterns,
// tokens, and components used throughout the MusicRepeater application.

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
struct AppShadow {
    /// Light shadow for subtle elevation
    static let light = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    /// Medium shadow for cards
    static let medium = Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
    /// Heavy shadow for modals and important elements
    static let heavy = Shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    
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

// MARK: - Reusable Components

// MARK: Primary Button - Used in ContentView for main actions
struct AppPrimaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    let isEnabled: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    init(_ title: String, subtitle: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(AppFont.headline)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFont.caption)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(isEnabled ? Color.designPrimary : Color.designTextTertiary)
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(AppAnimation.quick, value: isEnabled)
    }
}

// MARK: Secondary Button - Used for "Add" actions
struct AppSecondaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, subtitle: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(AppFont.headline)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFont.caption)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(isEnabled ? Color.designSecondary : Color.designTextTertiary)
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(AppAnimation.quick, value: isEnabled)
    }
}

// MARK: Selection Button - Used in ContentView for track selection
struct AppSelectionButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(AppFont.iconMedium)
                    .foregroundColor(Color.designPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.appCardBackground)
            )
        }
    }
}

// MARK: Card View - Used for containing sections and content
struct AppCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = AppSpacing.medium, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            )
    }
}

// MARK: Warning Banner - Used in ContentView for same song warning
struct AppWarningBanner: View {
    let message: String
    let icon: String
    
    init(_ message: String, icon: String = "exclamationmark.triangle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.designWarning)
                .font(AppFont.iconMedium)
            
            Text(message)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designWarning)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(AppSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(Color.designWarning.opacity(0.1))
        )
    }
}

// MARK: Progress Ring - Used in ProcessingView
struct AppProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 12, size: CGFloat = 200) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.designPrimary.opacity(0.3), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.designPrimary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(AppAnimation.standard, value: animatedProgress)
            
            // Glow effect
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.designPrimary.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth + 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 3)
                .animation(AppAnimation.standard, value: animatedProgress)
        }
        .frame(width: size, height: size)
        .onChange(of: progress) { newProgress in
            withAnimation(AppAnimation.standard) {
                animatedProgress = newProgress
            }
        }
        .onAppear {
            animatedProgress = progress
        }
    }
}

// MARK: Control Button - Used in ProcessingView for play/pause/stop
struct AppControlButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    init(icon: String, color: Color = Color.designPrimary, size: CGFloat = 60, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
        }
        .scaleEffect(1.0)
        .animation(AppAnimation.quick, value: icon)
    }
}

// MARK: Section Header - Used throughout the app for section titles
struct AppSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
        }
    }
}

// MARK: Info Row - Used in SettingsView and ProcessingView
struct AppInfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(_ label: String, value: String, valueColor: Color = Color.designTextPrimary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: Feature Row - Used in SettingsView
struct AppFeatureRow: View {
    let text: String
    let bulletColor: Color
    
    init(_ text: String, bulletColor: Color = Color.designPrimary) {
        self.text = text
        self.bulletColor = bulletColor
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Text("•")
                .foregroundColor(bulletColor)
                .fontWeight(.bold)
                .font(AppFont.subheadline)
            
            Text(text)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
        }
    }
}

// MARK: Permission Screen - Used in ContentView for permission requests
struct AppPermissionScreen: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void
    let statusMessage: String?
    let isButtonDestructive: Bool
    
    init(
        icon: String,
        title: String,
        description: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void,
        statusMessage: String? = nil,
        isButtonDestructive: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.statusMessage = statusMessage
        self.isButtonDestructive = isButtonDestructive
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color.designPrimary)
            
            // Title and Description
            VStack(spacing: AppSpacing.medium) {
                Text(title)
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
                
                Text(description)
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            // Button
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(AppFont.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                            .fill(isButtonDestructive ? Color.designError : Color.designPrimary)
                    )
            }
            .padding(.horizontal, AppSpacing.xxl)
            
            // Status Message
            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .font(AppFont.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.large)
            }
            
            Spacer()
        }
    }
}

// MARK: - View Modifiers

// MARK: Card Style Modifier
struct AppCardStyle: ViewModifier {
    let isElevated: Bool
    
    init(elevated: Bool = false) {
        self.isElevated = elevated
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(isElevated ? .medium : .light)
            )
    }
}

// MARK: Shadow Modifier
struct AppShadowModifier: ViewModifier {
    let shadow: AppShadow.Shadow
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

// MARK: - View Extensions
extension View {
    /// Applies app card styling with optional elevation
    func appCardStyle(elevated: Bool = false) -> some View {
        self.modifier(AppCardStyle(elevated: elevated))
    }
    
    /// Applies app shadow styling
    func appShadow(_ shadow: AppShadow.Shadow) -> some View {
        self.modifier(AppShadowModifier(shadow: shadow))
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

/*
 MARK: - Integration Instructions
 
 1. ADDING TO PROJECT:
    - Copy this entire DesignSystem.swift file into your Xcode project
    - Add it to your MusicRepeater target
    - Ensure it compiles without errors
 
 2. UPDATING ASSETS.XCASSETS:
    Add these color sets to Assets.xcassets with light/dark variants:
    - AppPrimary (Blue: #007AFF / #0A84FF)
    - AppPrimaryDark (Blue: #0051D0 / #0066CC)
    - AppSecondary (Green: #34C759 / #30D158)
    - AppSecondaryDark (Green: #248A3D / #20B946)
    - AppSuccess (Green: #34C759 / #30D158)
    - AppWarning (Orange: #FF9500 / #FF9F0A)
    - AppError (Red: #FF3B30 / #FF453A)
    - AppInfo (Light Blue: #5AC8FA / #64D2FF)
    - AppTextPrimary (Black: #000000 / #FFFFFF)
    - AppTextSecondary (Gray: #6D6D70 / #98989A)
    - AppTextTertiary (Light Gray: #C7C7CC / #48484A)
    - AppBackground (White: #FFFFFF / #000000)
    - AppBackgroundSecondary (Off White: #F2F2F7 / #1C1C1E)
    - AppBackgroundTertiary (Light Gray: #E5E5EA / #2C2C2E)
 
 3. MIGRATING EXISTING VIEWS:
    Replace existing code patterns with design system components:
    
    ContentView.swift:
    - Replace hard-coded buttons with AppPrimaryButton and AppSecondaryButton
    - Replace selection buttons with AppSelectionButton
    - Replace warning section with AppWarningBanner
    - Replace Color.blue with Color.appPrimary
    - Replace Color.green with Color.appSecondary
    - Replace Color.gray.opacity(0.2) with Color.appCardBackground
    
    ProcessingView.swift:
    - Replace AnimatedProgressRing with AppProgressRing
    - Replace control buttons with AppControlButton
    - Replace info rows with AppInfoRow
    
    SettingsView.swift:
    - Replace FeatureRow with AppFeatureRow
    - Replace manual styling with AppCard wrapper
    - Replace hard-coded colors with semantic colors
    
    MainTabView.swift:
    - Replace .accentColor(.blue) with .accentColor(Color.appPrimary)
 
 4. TESTING:
    - Test all components in SwiftUI Previews
    - Verify light/dark mode switching
    - Test with Dynamic Type sizes
    - Verify accessibility with VoiceOver
    - Test on different device sizes
 
 5. FOLDER ORGANIZATION:
    Create this folder structure in Xcode:
    ├── DesignSystem/
    │   ├── DesignSystem.swift (this file)
    └── Views/
        ├── ContentView.swift
        ├── ProcessingView.swift
        ├── SettingsView.swift
        └── MainTabView.swift
 
 Note: This design system uses Color assets that adapt automatically to light/dark mode.
 If assets are not available, the system falls back to hard-coded colors.
 Always test color contrast ratios to ensure accessibility compliance.
 */
