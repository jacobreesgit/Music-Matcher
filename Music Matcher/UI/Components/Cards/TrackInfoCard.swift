import SwiftUI
import MediaPlayer

struct TrackInfoCard: View {
    let track: MPMediaItem
    let title: String
    let showDetailedInfo: Bool
    let artworkSize: CGFloat
    
    init(
        _ title: String,
        track: MPMediaItem,
        showDetailedInfo: Bool = false,
        artworkSize: CGFloat = 80
    ) {
        self.title = title
        self.track = track
        self.showDetailedInfo = showDetailedInfo
        self.artworkSize = artworkSize
    }
    
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                // Header
                AppSectionHeader(title)
                
                // Track Info
                HStack(spacing: AppSpacing.medium) {
                    // Album Artwork
                    artworkSection
                    
                    // Track Details
                    trackDetailsSection
                    
                    Spacer()
                }
                
                // Detailed Info (if requested)
                if showDetailedInfo {
                    detailedInfoSection
                }
            }
        }
    }
    
    // MARK: - Artwork Section
    private var artworkSection: some View {
        ArtworkView(
            artwork: track.artwork,
            size: artworkSize,
            cornerRadius: AppCornerRadius.small
        )
        .appShadow(.light)
    }
    
    // MARK: - Track Details Section
    private var trackDetailsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(track.title ?? "Unknown Track")
                .font(AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
                .lineLimit(2)
            
            if let artist = track.artist {
                Text(artist)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
                    .lineLimit(1)
            }
            
            if let album = track.albumTitle {
                Text(album)
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
                    .lineLimit(1)
            }
            
            // Play count highlight with pill design
            PlayCountPill(count: track.playCount, style: .primary)
        }
    }
    
    // MARK: - Detailed Info Section
    @ViewBuilder
    private var detailedInfoSection: some View {
        VStack(spacing: AppSpacing.small) {
            Divider()
                .background(Color.designTextTertiary)
            
            VStack(spacing: AppSpacing.small) {
                if track.playbackDuration > 0 {
                    AppInfoRow("Duration", value: formatDuration(track.playbackDuration))
                }
                
                if let genre = track.genre {
                    AppInfoRow("Genre", value: genre)
                }
                
                if let year = track.releaseDate {
                    AppInfoRow("Year", value: formatYear(from: year))
                }
                
                if track.albumTrackNumber > 0 {
                    AppInfoRow("Track", value: "#\(track.albumTrackNumber)")
                }
                
                AppInfoRow("Date Added", value: formatDateAdded(track.dateAdded))
                
                if track.skipCount > 0 {
                    AppInfoRow("Skip Count", value: "\(track.skipCount)")
                }
                
                if track.rating > 0 {
                    AppInfoRow("Rating", value: "\(track.rating)/5 ⭐️")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDateAdded(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Compact Track Info Card

struct CompactTrackInfoCard: View {
    let track: MPMediaItem
    let label: String
    let highlightPlayCount: Bool
    
    init(
        _ label: String,
        track: MPMediaItem,
        highlightPlayCount: Bool = false
    ) {
        self.label = label
        self.track = track
        self.highlightPlayCount = highlightPlayCount
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            Text(label)
                .font(AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
            
            HStack(spacing: AppSpacing.small) {
                ArtworkView(
                    artwork: track.artwork,
                    size: 40,
                    cornerRadius: AppCornerRadius.xs
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title ?? "Unknown")
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    if let album = track.albumTitle {
                        Text(album)
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(track.playCount)")
                        .font(AppFont.headline)
                        .fontWeight(.bold)
                        .foregroundColor(highlightPlayCount ? Color.designPrimary : Color.designTextPrimary)
                    
                    Text("plays")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                }
            }
        }
        .padding(AppSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(Color.designBackgroundTertiary)
        )
    }
}

// MARK: - Track Comparison Card

struct TrackComparisonCard: View {
    let sourceTrack: MPMediaItem
    let targetTrack: MPMediaItem
    
    var body: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                AppSectionHeader("Play Count Comparison")
                
                HStack(spacing: AppSpacing.medium) {
                    // Source track mini info
                    CompactTrackInfoCard("Source", track: sourceTrack, highlightPlayCount: true)
                    
                    // Arrow and difference
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designTextSecondary)
                        
                        let difference = sourceTrack.playCount - targetTrack.playCount
                        if difference > 0 {
                            Text("+\(difference)")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designSecondary)
                        }
                    }
                    
                    // Target track mini info
                    CompactTrackInfoCard("Target", track: targetTrack, highlightPlayCount: true)
                }
                
                // Action Previews
                Divider()
                    .background(Color.designTextTertiary)
                
                VStack(spacing: AppSpacing.small) {
                    HStack {
                        Text("Match:")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Spacer()
                        
                        Text("\(targetTrack.playCount) → \(sourceTrack.playCount)")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designPrimary)
                    }
                    
                    HStack {
                        Text("Add:")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Spacer()
                        
                        Text("\(targetTrack.playCount) → \(targetTrack.playCount + sourceTrack.playCount)")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct TrackInfoCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // This would need sample MPMediaItems in a real preview
            Text("TrackInfoCard Preview")
                .font(AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
