import SwiftUI
import MediaPlayer

struct SongDetailRow: View {
    // MARK: - Configuration
    let song: MPMediaItem?
    let mode: DisplayMode
    let action: ActionType
    let isSelected: Bool
    let isHighlighted: Bool
    let showPlayCount: Bool
    let showDuration: Bool
    let showDateAdded: Bool
    let placeholderTitle: String?
    let placeholderSubtitle: String?
    let onAction: () -> Void
    let onSecondaryAction: (() -> Void)?
    
    // MARK: - Display Modes
    enum DisplayMode {
        case selection      // For source/target selection in ContentView
        case groupMember    // Songs within duplicate groups
        case version        // All versions in detail view
        case ignored        // Ignored songs in settings
        case picker         // Music library picker
        case list          // Generic list display
        
        var artworkSize: CGFloat {
            switch self {
            case .selection: return 60
            case .groupMember: return 50
            case .version: return 55
            case .ignored: return 45
            case .picker: return 50
            case .list: return 50
            }
        }
        
        var showsSelectionIndicator: Bool {
            switch self {
            case .version: return true
            default: return false
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .selection: return AppCornerRadius.medium
            case .version, .ignored: return AppCornerRadius.small
            default: return 0
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .selection: return AppSpacing.medium
            case .version, .ignored: return AppSpacing.small
            default: return AppSpacing.medium
            }
        }
    }
    
    // MARK: - Action Types
    enum ActionType {
        case select
        case selectAsSource
        case selectAsTarget
        case ignore
        case restore
        case remove
        case pick
        case none
        
        var buttonTitle: String? {
            switch self {
            case .ignore: return "Ignore"
            case .restore: return "Restore"
            case .remove: return "Remove"
            default: return nil
            }
        }
        
        var buttonColor: Color {
            switch self {
            case .ignore, .remove: return Color.designError
            case .restore: return Color.designSecondary
            default: return Color.designPrimary
            }
        }
        
        var selectionLabel: String? {
            switch self {
            case .selectAsSource: return "Source"
            case .selectAsTarget: return "Target"
            default: return nil
            }
        }
    }
    
    // MARK: - Initializers
    init(
        song: MPMediaItem?,
        mode: DisplayMode = .list,
        action: ActionType = .none,
        isSelected: Bool = false,
        isHighlighted: Bool = false,
        showPlayCount: Bool = true,
        showDuration: Bool = false,
        showDateAdded: Bool = false,
        placeholderTitle: String? = nil,
        placeholderSubtitle: String? = nil,
        onAction: @escaping () -> Void = {},
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.song = song
        self.mode = mode
        self.action = action
        self.isSelected = isSelected
        self.isHighlighted = isHighlighted
        self.showPlayCount = showPlayCount
        self.showDuration = showDuration
        self.showDateAdded = showDateAdded
        self.placeholderTitle = placeholderTitle
        self.placeholderSubtitle = placeholderSubtitle
        self.onAction = onAction
        self.onSecondaryAction = onSecondaryAction
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: onAction) {
            HStack(spacing: AppSpacing.medium) {
                // Album Artwork
                ArtworkView(
                    artwork: song?.artwork,
                    size: mode.artworkSize,
                    fallbackIcon: song == nil ? "plus.circle" : "music.note"
                )
                
                // Song Information
                songInfoSection
                
                Spacer()
                
                // Selection Indicator (for version selection)
                if mode.showsSelectionIndicator, let label = action.selectionLabel {
                    SelectionBadge(
                        title: label,
                        color: action == .selectAsSource ? Color.designPrimary : Color.designSecondary,
                        isSelected: isSelected
                    )
                }
                
                // Action Button (for settings/management)
                if let buttonTitle = action.buttonTitle {
                    actionButton(title: buttonTitle)
                }
                
                // Secondary Action (for version management)
                if let onSecondaryAction = onSecondaryAction {
                    Button(action: onSecondaryAction) {
                        Image(systemName: "trash")
                            .font(AppFont.iconSmall)
                            .foregroundColor(Color.designError)
                            .padding(AppSpacing.xs)
                            .background(
                                Circle()
                                    .fill(Color.designError.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Chevron (for navigation)
                if shouldShowChevron {
                    Image(systemName: "chevron.right")
                        .font(AppFont.iconSmall)
                        .foregroundColor(Color.designTextTertiary)
                }
            }
            .padding(mode.padding)
            .background(backgroundView)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Song Info Section
    private var songInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Song Title
            Text(displayTitle)
                .font(titleFont)
                .fontWeight(titleFontWeight)
                .foregroundColor(titleColor)
                .lineLimit(titleLineLimit)
                .multilineTextAlignment(.leading)
            
            // Artist
            if let artist = song?.artist ?? placeholderSubtitle {
                Text(artist)
                    .font(subtitleFont)
                    .foregroundColor(subtitleColor)
                    .lineLimit(1)
            }
            
            // Album (context-dependent)
            if shouldShowAlbum, let album = song?.albumTitle {
                Text(album)
                    .font(AppFont.caption)
                    .foregroundColor(albumTextColor)
                    .lineLimit(1)
            }
            
            // Additional Info Row
            if song != nil {
                additionalInfoRow
            }
        }
    }
    
    // MARK: - Additional Info Row
    private var additionalInfoRow: some View {
        HStack(spacing: AppSpacing.small) {
            // Play Count Pill
            if showPlayCount, let song = song {
                PlayCountPill(count: song.playCount, style: playCountStyle)
            }
            
            // Duration
            if showDuration, let song = song, song.playbackDuration > 0 {
                DurationLabel(duration: song.playbackDuration)
            }
            
            // Date Added
            if showDateAdded, let song = song {
                Text("•")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
                
                Text(formatDateAdded(song.dateAdded))
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Action Button
    private func actionButton(title: String) -> some View {
        Button(action: onAction) {
            Text(title)
                .font(AppFont.caption)
                .foregroundColor(action.buttonColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .stroke(action.buttonColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View {
        Group {
            switch mode {
            case .selection:
                RoundedRectangle(cornerRadius: mode.cornerRadius)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            case .ignored:
                RoundedRectangle(cornerRadius: mode.cornerRadius)
                    .fill(Color.designWarning.opacity(0.05))
                    .stroke(Color.designWarning.opacity(0.3), lineWidth: 1)
            case .version:
                RoundedRectangle(cornerRadius: mode.cornerRadius)
                    .fill(selectionBackgroundColor)
                    .stroke(selectionBorderColor, lineWidth: 1)
            default:
                if isSelected {
                    Color.designPrimary.opacity(0.1)
                } else {
                    Color.clear
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var displayTitle: String {
        if let song = song {
            return song.title ?? "Unknown Track"
        } else {
            return placeholderTitle ?? defaultPlaceholderTitle
        }
    }
    
    private var defaultPlaceholderTitle: String {
        switch mode {
        case .selection: return "Choose Track"
        case .picker: return "Select Song"
        default: return "Unknown Track"
        }
    }
    
    private var titleFont: Font {
        switch mode {
        case .selection: return AppFont.body
        case .groupMember, .version: return AppFont.subheadline
        case .ignored: return AppFont.subheadline
        default: return AppFont.body
        }
    }
    
    private var titleFontWeight: Font.Weight {
        switch mode {
        case .selection: return .bold
        case .groupMember: return .medium
        default: return .medium
        }
    }
    
    private var titleLineLimit: Int {
        switch mode {
        case .selection: return 2
        default: return 1
        }
    }
    
    private var subtitleFont: Font {
        switch mode {
        case .ignored: return AppFont.caption
        default: return AppFont.subheadline
        }
    }
    
    private var titleColor: Color {
        if song == nil {
            return Color.designTextSecondary
        }
        if isHighlighted {
            return Color.designPrimary
        }
        if mode == .ignored {
            return Color.designTextPrimary
        }
        return Color.designTextPrimary
    }
    
    private var subtitleColor: Color {
        if song == nil {
            return Color.designTextTertiary
        }
        return Color.designTextSecondary
    }
    
    private var shouldShowAlbum: Bool {
        switch mode {
        case .selection, .picker, .ignored: return true
        case .groupMember: return false // Albums are shown in group header
        case .version: return true
        case .list: return true
        }
    }
    
    private var albumTextColor: Color {
        switch mode {
        case .ignored: return Color.designWarning
        default: return Color.designTextTertiary
        }
    }
    
    private var playCountStyle: PlayCountPill.Style {
        switch mode {
        case .selection: return .primary
        case .groupMember, .version: return .compact
        case .ignored: return .muted
        default: return .standard
        }
    }
    
    private var shouldShowChevron: Bool {
        switch mode {
        case .selection, .picker: return true
        case .groupMember: return action == .none
        default: return false
        }
    }
    
    private var selectionBackgroundColor: Color {
        switch (action, isSelected) {
        case (.selectAsSource, true): return Color.designPrimary.opacity(0.1)
        case (.selectAsTarget, true): return Color.designSecondary.opacity(0.1)
        default: return Color.designBackgroundTertiary
        }
    }
    
    private var selectionBorderColor: Color {
        switch (action, isSelected) {
        case (.selectAsSource, true): return Color.designPrimary.opacity(0.3)
        case (.selectAsTarget, true): return Color.designSecondary.opacity(0.3)
        default: return Color.designTextTertiary.opacity(0.3)
        }
    }
    
    // MARK: - Helper Methods
    private func formatDateAdded(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Supporting Components

struct PlayCountPill: View {
    let count: Int
    let style: Style
    
    enum Style {
        case primary, secondary, compact, standard, muted
        
        var backgroundColor: Color {
            switch self {
            case .primary: return Color.designPrimary
            case .secondary: return Color.designSecondary
            case .muted: return Color.designTextTertiary
            case .compact, .standard: return Color.designInfo
            }
        }
        
        var fontSize: Font {
            switch self {
            case .compact: return AppFont.caption2
            default: return AppFont.caption
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "play.fill")
                .font(.system(size: style == .compact ? 8 : 10))
                .foregroundColor(.white)
            
            Text("\(count)")
                .font(style.fontSize)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(style.backgroundColor)
        )
    }
}

struct SelectionBadge: View {
    let title: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(AppFont.iconSmall)
            Text(title)
                .font(AppFont.caption)
        }
        .foregroundColor(isSelected ? color : Color.designTextSecondary)
        .padding(.horizontal, AppSpacing.small)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(isSelected ? color.opacity(0.2) : Color.clear)
                .stroke(isSelected ? color : Color.designTextTertiary, lineWidth: 1)
        )
    }
}

struct DurationLabel: View {
    let duration: TimeInterval
    
    var body: some View {
        Label(formatDuration(duration), systemImage: "clock")
            .font(AppFont.caption)
            .foregroundColor(Color.designTextSecondary)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#if DEBUG
struct SongDetailRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Selection mode (placeholder)
            SongDetailRow(
                song: nil,
                mode: .selection,
                action: .select,
                placeholderTitle: "Choose Source Track",
                placeholderSubtitle: "Tap to select from your music library"
            ) {}
            
            // Version mode with selection
            SongDetailRow(
                song: nil,
                mode: .version,
                action: .selectAsSource,
                isSelected: true
            ) {}
            
            // Ignored mode
            SongDetailRow(
                song: nil,
                mode: .ignored,
                action: .restore
            ) {}
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
