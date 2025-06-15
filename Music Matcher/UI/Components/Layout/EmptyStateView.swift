import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let actionAction: (() -> Void)?
    let style: EmptyStateStyle
    
    enum EmptyStateStyle {
        case fullScreen     // Large center display
        case card          // Card-based display
        case inline        // Compact inline display
        
        var iconSize: CGFloat {
            switch self {
            case .fullScreen: return 80
            case .card: return 60
            case .inline: return 40
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .fullScreen: return AppSpacing.xl
            case .card: return AppSpacing.large
            case .inline: return AppSpacing.medium
            }
        }
        
        var titleFont: Font {
            switch self {
            case .fullScreen: return AppFont.title
            case .card: return AppFont.title3
            case .inline: return AppFont.headline
            }
        }
        
        var messageFont: Font {
            switch self {
            case .fullScreen: return AppFont.body
            case .card: return AppFont.subheadline
            case .inline: return AppFont.caption
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .fullScreen: return AppSpacing.xl
            case .card: return AppSpacing.medium
            case .inline: return AppSpacing.small
            }
        }
    }
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionAction: (() -> Void)? = nil,
        style: EmptyStateStyle = .fullScreen
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.actionAction = actionAction
        self.style = style
    }
    
    var body: some View {
        VStack(spacing: style.spacing) {
            if style == .fullScreen {
                Spacer()
            }
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: style.iconSize))
                .foregroundColor(iconColor)
            
            // Title and Message
            VStack(spacing: AppSpacing.medium) {
                Text(title)
                    .font(style.titleFont)
                    .foregroundColor(Color.designTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(style.messageFont)
                    .foregroundColor(Color.designTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, style.horizontalPadding)
            }
            
            // Action Button
            if let actionTitle = actionTitle,
               let actionAction = actionAction {
                actionButton(title: actionTitle, action: actionAction)
            }
            
            if style == .fullScreen {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .if(style == .card) { view in
            view.padding(AppSpacing.large)
        }
    }
    
    // MARK: - Action Button
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.headline)
                .foregroundColor(.white)
                .frame(maxWidth: style == .fullScreen ? .infinity : nil)
                .padding(AppSpacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                        .fill(Color.designPrimary)
                )
        }
        .if(style == .fullScreen) { view in
            view.padding(.horizontal, AppSpacing.xxl)
        }
    }
    
    // MARK: - Computed Properties
    private var iconColor: Color {
        // Determine icon color based on the icon type
        if icon.contains("checkmark") {
            return Color.designSuccess
        } else if icon.contains("exclamationmark") || icon.contains("xmark") {
            return Color.designError
        } else if icon.contains("magnifyingglass") {
            return Color.designPrimary
        } else if icon.contains("music") {
            return Color.designSecondary
        } else {
            return Color.designTextTertiary
        }
    }
}

// MARK: - Predefined Empty States

extension EmptyStateView {
    // MARK: - Music Library Empty States
    
    static func noMusicLibrary(onOpenSettings: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "music.note.list",
            title: "No Music Found",
            message: "Your music library appears to be empty. Add some music to your device to use Music Matcher.",
            actionTitle: "Open Music App",
            actionAction: onOpenSettings,
            style: .fullScreen
        )
    }
    
    static func noDuplicatesFound(songCount: Int, onRescan: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "No Duplicates Found",
            message: "Your music library doesn't contain songs with the same title and artist across different albums. Scanned \(songCount.formatted()) songs.",
            actionTitle: "Scan Again",
            actionAction: onRescan,
            style: .fullScreen
        )
    }
    
    static func noSearchResults(searchTerm: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No songs found matching '\(searchTerm)'",
            style: .fullScreen
        )
    }
    
    // MARK: - Settings Empty States
    
    static func noIgnoredItems() -> EmptyStateView {
        EmptyStateView(
            icon: "checkmark.circle",
            title: "No Ignored Items",
            message: "You haven't ignored any songs or groups from Smart Scan yet. When you remove items during scanning, they'll appear here.",
            style: .fullScreen
        )
    }
    
    static func noIgnoredSongs() -> EmptyStateView {
        EmptyStateView(
            icon: "music.note",
            title: "No Ignored Songs",
            message: "No individual songs have been ignored.",
            style: .inline
        )
    }
    
    static func noIgnoredGroups() -> EmptyStateView {
        EmptyStateView(
            icon: "music.note.list",
            title: "No Ignored Groups",
            message: "No duplicate groups have been ignored.",
            style: .inline
        )
    }
    
    // MARK: - Loading and Error States
    
    static func loadingMusicLibrary() -> EmptyStateView {
        EmptyStateView(
            icon: "music.note",
            title: "Loading Music Library",
            message: "Please wait while we load your music collection...",
            style: .fullScreen
        )
    }
    
    static func musicLibraryError(onRetry: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Unable to Load Music",
            message: "There was a problem accessing your music library. Please try again.",
            actionTitle: "Retry",
            actionAction: onRetry,
            style: .fullScreen
        )
    }
    
    // MARK: - Permission States
    
    static func musicPermissionDenied(onOpenSettings: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "music.note.house",
            title: "Music Access Required",
            message: "Music Matcher needs access to your music library to find and match duplicate songs.",
            actionTitle: "Open Settings",
            actionAction: onOpenSettings,
            style: .fullScreen
        )
    }
    
    static func musicPermissionRestricted() -> EmptyStateView {
        EmptyStateView(
            icon: "lock",
            title: "Access Restricted",
            message: "Music access is restricted on this device and cannot be enabled.",
            style: .fullScreen
        )
    }
}

// MARK: - Empty State Card Wrapper

struct EmptyStateCard: View {
    let emptyState: EmptyStateView
    
    init(_ emptyState: EmptyStateView) {
        self.emptyState = emptyState
    }
    
    var body: some View {
        AppCard {
            emptyState
        }
    }
}

// MARK: - Loading State View

struct LoadingStateView: View {
    let title: String
    let message: String?
    let showProgress: Bool
    
    init(
        title: String = "Loading...",
        message: String? = nil,
        showProgress: Bool = true
    ) {
        self.title = title
        self.message = message
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            
            if showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.designPrimary))
                    .scaleEffect(1.5)
            }
            
            VStack(spacing: AppSpacing.medium) {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundColor(Color.designTextPrimary)
                
                if let message = message {
                    Text(message)
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            // Full screen style
            EmptyStateView(
                icon: "checkmark.circle",
                title: "No Duplicates Found",
                message: "Your music library is clean!",
                actionTitle: "Scan Again",
                actionAction: {},
                style: .fullScreen
            )
            .frame(height: 300)
            
            // Card style
            EmptyStateCard(
                EmptyStateView(
                    icon: "music.note",
                    title: "No Songs",
                    message: "No songs found in this category.",
                    style: .card
                )
            )
            
            // Inline style
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "No items found.",
                style: .inline
            )
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
