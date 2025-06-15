import SwiftUI
import MediaPlayer

struct DuplicateGroupCard: View {
    let group: ScanViewModel.DuplicateGroup
    let state: CardState
    let onAction: () -> Void
    let onSecondaryAction: (() -> Void)?
    
    enum CardState {
        case active         // Active duplicate group in scan results
        case ignored        // Ignored duplicate group in settings
        
        var actionTitle: String {
            switch self {
            case .active: return "View Details"
            case .ignored: return "Restore Group"
            }
        }
        
        var actionColor: Color {
            switch self {
            case .active: return Color.designPrimary
            case .ignored: return Color.designSecondary
            }
        }
        
        var statusIcon: String? {
            switch self {
            case .active: return nil
            case .ignored: return "eye.slash.fill"
            }
        }
        
        var statusColor: Color {
            switch self {
            case .active: return Color.clear
            case .ignored: return Color.designWarning
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .active: return nil
            case .ignored: return Color.designWarning.opacity(0.3)
            }
        }
    }
    
    init(
        group: ScanViewModel.DuplicateGroup,
        state: CardState = .active,
        onAction: @escaping () -> Void,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.group = group
        self.state = state
        self.onAction = onAction
        self.onSecondaryAction = onSecondaryAction
    }
    
    var body: some View {
        Button(action: onAction) {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                    .padding(AppSpacing.medium)
                
                // Songs List (for active groups)
                if state == .active {
                    songsListSection
                }
            }
            .background(backgroundView)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: AppSpacing.medium) {
            // Group Information
            groupInfoView
            
            Spacer()
            
            // Status Indicator (for ignored groups)
            if let statusIcon = state.statusIcon {
                VStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(AppFont.iconMedium)
                        .foregroundColor(state.statusColor)
                    
                    Text("Ignored")
                        .font(AppFont.caption)
                        .foregroundColor(state.statusColor)
                }
            } else {
                // Chevron for active groups
                Image(systemName: "chevron.right")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
            }
        }
    }
    
    // MARK: - Group Info View
    private var groupInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Song Title
            Text(group.title)
                .font(AppFont.body)
                .fontWeight(.bold)
                .foregroundColor(Color.designTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Artist Name
            Text(group.artist)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
                .lineLimit(1)
            
            // Album Info
            Text(albumInfoText)
                .font(AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
                .lineLimit(1)
            
            // Metrics Row
            metricsRow
        }
    }
    
    // MARK: - Metrics Row
    private var metricsRow: some View {
        HStack(spacing: AppSpacing.small) {
            // Version Count Pill
            MetricPill(
                icon: "music.note.list",
                value: "\(group.songs.count)",
                color: Color.designInfo,
                label: group.songs.count == 1 ? "version" : "versions"
            )
            
            // Play Count Range
            if group.hasPlayCountDifferences {
                MetricPill(
                    icon: "play.fill",
                    value: "\(group.minPlayCount)-\(group.maxPlayCount)",
                    color: Color.designWarning,
                    label: "plays"
                )
                
                // Potential impact indicator
                let difference = group.maxPlayCount - group.minPlayCount
                if difference > 0 {
                    Text("•")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextTertiary)
                    
                    Text("+\(difference) potential")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designPrimary)
                }
            } else {
                // All same play count
                MetricPill(
                    icon: "play.fill",
                    value: "\(group.maxPlayCount)",
                    color: Color.designSuccess,
                    label: "plays each"
                )
            }
            
            Spacer()
        }
    }
    
    // MARK: - Songs List Section
    private var songsListSection: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.designTextTertiary)
                .padding(.horizontal, AppSpacing.medium)
            
            ForEach(group.songs, id: \.persistentID) { song in
                SongDetailRow(
                    song: song,
                    mode: .groupMember,
                    action: .none,
                    showPlayCount: true,
                    showDuration: false,
                    showDateAdded: false
                ) {
                    // No individual song action needed here
                    // The parent button handles the main action
                }
            }
        }
    }
    
    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
            .fill(Color.designBackgroundSecondary)
            .appShadow(.light)
            .if(state.borderColor != nil) { view in
                view.overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(state.borderColor!, lineWidth: 1)
                )
            }
    }
    
    // MARK: - Computed Properties
    private var albumInfoText: String {
        let albums = Array(Set(group.songs.compactMap { $0.albumTitle })).sorted()
        let displayAlbums = albums.prefix(2)
        
        if albums.count <= 2 {
            return displayAlbums.joined(separator: ", ")
        } else {
            return displayAlbums.joined(separator: ", ") + " + \(albums.count - 2) more"
        }
    }
}

// MARK: - Supporting Components

struct MetricPill: View {
    let icon: String
    let value: String
    let color: Color
    let label: String?
    
    init(icon: String, value: String, color: Color, label: String? = nil) {
        self.icon = icon
        self.value = value
        self.color = color
        self.label = label
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.white)
            
            Text(value)
                .font(AppFont.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color)
        )
    }
}

// MARK: - Ignored Group Variant

struct IgnoredDuplicateGroupCard: View {
    let group: ScanViewModel.DuplicateGroup
    let onRestore: () -> Void
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Header with group info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.title)
                            .font(AppFont.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.designTextPrimary)
                            .lineLimit(2)
                        
                        Text(group.artist)
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                            .lineLimit(1)
                        
                        Text("\(group.songs.count) versions")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designInfo)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    VStack(spacing: 4) {
                        Image(systemName: "eye.slash.fill")
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designWarning)
                        
                        Text("Ignored")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designWarning)
                    }
                }
                
                // Album info
                let albums = Array(Set(group.songs.compactMap { $0.albumTitle })).sorted()
                let displayAlbums = albums.prefix(2)
                let albumText = albums.count <= 2 ?
                    displayAlbums.joined(separator: ", ") :
                    displayAlbums.joined(separator: ", ") + " + \(albums.count - 2) more"
                
                HStack {
                    Text("Albums: \(albumText)")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextTertiary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                // Restore button
                Divider()
                    .background(Color.designTextTertiary)
                
                HStack {
                    Text("This group is hidden from Smart Scans")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                    
                    Spacer()
                    
                    Button("Restore Group") {
                        onRestore()
                    }
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .stroke(Color.designSecondary, lineWidth: 1)
                    )
                }
            }
        }
        .overlay(
            // Add a subtle border to indicate it's ignored
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .stroke(Color.designWarning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#if DEBUG
struct DuplicateGroupCard_Previews: PreviewProvider {
    static var sampleGroup: ScanViewModel.DuplicateGroup {
        // This would need sample MPMediaItems in a real preview
        ScanViewModel.DuplicateGroup(
            title: "Sample Song",
            artist: "Sample Artist",
            songs: []
        )
    }
    
    static var previews: some View {
        VStack(spacing: 20) {
            DuplicateGroupCard(
                group: sampleGroup,
                state: .active
            ) {}
            
            DuplicateGroupCard(
                group: sampleGroup,
                state: .ignored
            ) {}
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
