import SwiftUI
import MediaPlayer

struct EnhancedTrackSelectionButton: View {
    let track: MPMediaItem?
    let icon: String
    let placeholderTitle: String
    let placeholderSubtitle: String?
    let action: () -> Void
    
    init(
        track: MPMediaItem? = nil,
        icon: String,
        placeholderTitle: String,
        placeholderSubtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.track = track
        self.icon = icon
        self.placeholderTitle = placeholderTitle
        self.placeholderSubtitle = placeholderSubtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                // Album Artwork or Icon
                artworkView
                
                // Track Information
                trackInfoView
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
            }
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var artworkView: some View {
        Group {
            if let track = track, let artwork = track.artwork {
                ArtworkView(artwork: artwork)
            } else {
                placeholderArtwork
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
    }
    
    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: AppCornerRadius.small)
            .fill(Color.designBackgroundTertiary)
            .overlay(
                Image(systemName: icon)
                    .font(AppFont.iconMedium)
                    .foregroundColor(Color.designPrimary)
            )
    }
    
    private var trackInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let track = track {
                selectedTrackInfo(track)
            } else {
                placeholderTrackInfo
            }
        }
    }
    
    private func selectedTrackInfo(_ track: MPMediaItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Track Title
            Text(track.title ?? "Unknown Track")
                .font(AppFont.body)
                .foregroundColor(Color.designTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Artist Name
            if let artist = track.artist {
                Text(artist)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
                    .lineLimit(1)
            }
            
            // Album Name
            if let album = track.albumTitle {
                Text(album)
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
                    .lineLimit(1)
            }
            
            // Additional Info
            HStack(spacing: AppSpacing.small) {
                // Play Count
                Label("\(track.playCount)", systemImage: "play.fill")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designPrimary)
                
                // Duration
                if track.playbackDuration > 0 {
                    Label(formatDuration(track.playbackDuration), systemImage: "clock")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var placeholderTrackInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholderTitle)
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .lineLimit(1)
            
            if let subtitle = placeholderSubtitle {
                Text(subtitle)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextTertiary)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ArtworkView: UIViewRepresentable {
    let artwork: MPMediaItemArtwork
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = AppCornerRadius.small
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Get the artwork image at the appropriate size
        let size = CGSize(width: 60, height: 60)
        if let image = artwork.image(at: size) {
            uiView.image = image
        } else {
            uiView.image = nil
        }
    }
}

// MARK: - Track Info Card Component
struct TrackInfoCard: View {
    let track: MPMediaItem
    let title: String
    let showDetailedInfo: Bool
    
    init(_ title: String, track: MPMediaItem, showDetailedInfo: Bool = false) {
        self.title = title
        self.track = track
        self.showDetailedInfo = showDetailedInfo
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
    
    private var artworkSection: some View {
        Group {
            if let artwork = track.artwork {
                ArtworkView(artwork: artwork)
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color.designBackgroundTertiary)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designPrimary)
                    )
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
    }
    
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
            
            // Play count highlight
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "play.fill")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designPrimary)
                
                Text("\(track.playCount) plays")
                    .font(AppFont.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.designPrimary)
            }
        }
    }
    
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
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy"
                    AppInfoRow("Year", value: formatter.string(from: year))
                }
                
                if track.albumTrackNumber > 0 {
                    AppInfoRow("Track", value: "#\(track.albumTrackNumber)")
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#if DEBUG
struct EnhancedTrackSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.large) {
            // Placeholder state
            EnhancedTrackSelectionButton(
                icon: "music.note",
                placeholderTitle: "Choose Source Track",
                placeholderSubtitle: "Tap to select from your music library"
            ) { }
            
            // Note: In a real preview, you'd need a mock MPMediaItem
            // This would show the selected track state with artwork
            EnhancedTrackSelectionButton(
                track: nil, // Would be actual MPMediaItem
                icon: "music.note.list",
                placeholderTitle: "Choose Target Track"
            ) { }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
