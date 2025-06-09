import SwiftUI
import MediaPlayer

struct DuplicateGroupRow: View {
    let group: ScanViewModel.DuplicateGroup
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Header Section (similar to SongDisplayRow layout)
                HStack(spacing: AppSpacing.medium) {
                    // Song Information
                    songInfoView
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(AppFont.iconSmall)
                        .foregroundColor(Color.designTextTertiary)
                }
                .padding(AppSpacing.medium)
                
                // All Song Versions Section
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.designTextTertiary)
                        .padding(.horizontal, AppSpacing.medium)
                    
                    ForEach(group.songs, id: \.persistentID) { song in
                        SongDisplayRow(
                            track: song,
                            icon: "music.note",
                            placeholderTitle: "",
                            style: .list
                        ) {
                            // No action needed, parent button handles the tap
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var songInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Song Title - same as SongDisplayRow but bold
            Text(group.title)
                .font(AppFont.body)
                .fontWeight(.bold)
                .foregroundColor(Color.designTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Artist Name - same as SongDisplayRow
            Text(group.artist)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
                .lineLimit(1)
            
            // Album info - adapted for duplicate groups
            Text(albumInfoText)
                .font(AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
                .lineLimit(1)
            
            // Additional Info Row - similar to SongDisplayRow
            HStack(spacing: AppSpacing.small) {
                // Version Count Pill (similar to play count pill)
                HStack(spacing: 4) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                    
                    Text("\(group.songs.count)")
                        .font(AppFont.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.designInfo)
                )
                
                // Play Count Range (if there are differences)
                if group.hasPlayCountDifferences {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        
                        Text("\(group.minPlayCount)-\(group.maxPlayCount)")
                            .font(AppFont.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.designWarning)
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
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                        
                        Text("\(group.maxPlayCount)")
                            .font(AppFont.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.designSuccess)
                    )
                }
                
                Spacer()
            }
        }
    }
    
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
