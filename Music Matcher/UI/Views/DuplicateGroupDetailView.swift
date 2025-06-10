import SwiftUI
import MediaPlayer

struct DuplicateGroupDetailView: View {
    let group: ScanViewModel.DuplicateGroup
    @ObservedObject var musicMatcherViewModel: MusicMatcherViewModel
    @ObservedObject var scanViewModel: ScanViewModel
    let onDismiss: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSourceTrack: MPMediaItem?
    @State private var selectedTargetTrack: MPMediaItem?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingRemoveConfirmation = false
    @State private var songToRemove: MPMediaItem?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        // Song Header
                        songHeaderSection
                        
                        // Versions List
                        versionsSection
                        
                        // Selected Tracks Summary
                        if selectedSourceTrack != nil || selectedTargetTrack != nil {
                            selectedTracksSection
                        }
                        
                        // Bottom spacing for actions
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons (fixed at bottom)
                actionButtonsSection
            }
            .background(Color.designBackground)
            .navigationTitle("Duplicate Versions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        onDismiss()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.designPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        songToRemove = nil // This indicates we're removing the whole group
                        showingRemoveConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(Color.designError)
                    }
                }
            }
        }
        .alert(songToRemove != nil ? "Remove Song" : "Remove Group", isPresented: $showingRemoveConfirmation) {
            Button("Remove", role: .destructive) {
                if let songToRemove = songToRemove {
                    removeSong(songToRemove)
                } else {
                    // Remove the entire group
                    scanViewModel.removeGroup(groupId: group.id)
                    onDismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            Button("Cancel", role: .cancel) {
                songToRemove = nil
            }
        } message: {
            if let song = songToRemove {
                Text("Remove '\(song.albumTitle ?? "Unknown Album")' version from this duplicate group?")
            } else {
                Text("Remove this entire duplicate group?")
            }
        }
        .alert("Music Matcher", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onReceive(musicMatcherViewModel.$alertMessage) { message in
            if !message.isEmpty {
                alertMessage = message
                showingAlert = true
                musicMatcherViewModel.alertMessage = ""
            }
        }
    }
    
    private var songHeaderSection: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Album artwork from highest play count version
                if let artwork = group.sourceCandidate?.artwork {
                    ArtworkView(artwork: artwork)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                        .appShadow(.light)
                } else {
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(Color.designBackgroundTertiary)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(Color.designPrimary)
                        )
                }
                
                VStack(spacing: AppSpacing.small) {
                    Text(group.title)
                        .font(AppFont.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.designTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(group.artist)
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("\(group.songs.count) versions found")
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designInfo)
                }
                
                if group.hasPlayCountDifferences {
                    Divider()
                        .background(Color.designTextTertiary)
                    
                    HStack {
                        VStack(spacing: 4) {
                            Text("Lowest")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                            Text("\(group.minPlayCount)")
                                .font(AppFont.headline)
                                .foregroundColor(Color.designError)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Highest")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                            Text("\(group.maxPlayCount)")
                                .font(AppFont.headline)
                                .foregroundColor(Color.designSuccess)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Difference")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                            Text("\(group.maxPlayCount - group.minPlayCount)")
                                .font(AppFont.headline)
                                .foregroundColor(Color.designPrimary)
                        }
                    }
                }
            }
        }
    }
    
    private var versionsSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                AppSectionHeader("All Versions", subtitle: "Tap to select source and target tracks")
                
                VStack(spacing: AppSpacing.small) {
                    ForEach(group.songs, id: \.persistentID) { song in
                        DuplicateVersionRow(
                            song: song,
                            isSource: selectedSourceTrack?.persistentID == song.persistentID,
                            isTarget: selectedTargetTrack?.persistentID == song.persistentID,
                            onSelectAsSource: {
                                selectAsSource(song)
                            },
                            onSelectAsTarget: {
                                selectAsTarget(song)
                            },
                            onRemove: {
                                songToRemove = song
                                showingRemoveConfirmation = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var selectedTracksSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                AppSectionHeader("Selection Summary")
                
                if let sourceTrack = selectedSourceTrack {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text("Source (copy from):")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        HStack {
                            Text(sourceTrack.albumTitle ?? "Unknown Album")
                                .font(AppFont.subheadline)
                                .foregroundColor(Color.designTextPrimary)
                            
                            Spacer()
                            
                            Text("\(sourceTrack.playCount) plays")
                                .font(AppFont.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.designPrimary)
                        }
                    }
                }
                
                if let targetTrack = selectedTargetTrack {
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text("Target (copy to):")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        HStack {
                            Text(targetTrack.albumTitle ?? "Unknown Album")
                                .font(AppFont.subheadline)
                                .foregroundColor(Color.designTextPrimary)
                            
                            Spacer()
                            
                            Text("\(targetTrack.playCount) plays")
                                .font(AppFont.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.designSecondary)
                        }
                    }
                }
                
                if let sourceTrack = selectedSourceTrack,
                   let targetTrack = selectedTargetTrack {
                    
                    Divider()
                        .background(Color.designTextTertiary)
                    
                    let difference = sourceTrack.playCount - targetTrack.playCount
                    if difference > 0 {
                        AppInfoRow(
                            "Plays to add:",
                            value: "\(difference)",
                            valueColor: Color.designInfo
                        )
                        
                        AppInfoRow(
                            "Final play count:",
                            value: "\(sourceTrack.playCount)",
                            valueColor: Color.designSuccess
                        )
                    } else if difference < 0 {
                        Text("⚠️ Source has fewer plays than target")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designWarning)
                    } else {
                        Text("✓ Both tracks have the same play count")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designSuccess)
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.medium) {
                AppPrimaryButton(
                    "Match",
                    isEnabled: canPerformActions
                ) {
                    matchPlayCount()
                }
                
                AppSecondaryButton(
                    "Add",
                    isEnabled: canPerformActions
                ) {
                    addPlayCount()
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, AppSpacing.medium)
        .background(
            Color.designBackground
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private var canPerformActions: Bool {
        guard let sourceTrack = selectedSourceTrack,
              let targetTrack = selectedTargetTrack else {
            return false
        }
        
        return sourceTrack.persistentID != targetTrack.persistentID &&
               sourceTrack.playCount > targetTrack.playCount &&
               !musicMatcherViewModel.isProcessing
    }
    
    // MARK: - Selection Logic
    
    private func selectAsSource(_ song: MPMediaItem) {
        if selectedSourceTrack?.persistentID == song.persistentID {
            // Tapping the same song as source again - deselect it
            selectedSourceTrack = nil
        } else {
            // If this song was previously selected as target, clear target selection
            if selectedTargetTrack?.persistentID == song.persistentID {
                selectedTargetTrack = nil
            }
            // Set as new source
            selectedSourceTrack = song
        }
    }
    
    private func selectAsTarget(_ song: MPMediaItem) {
        if selectedTargetTrack?.persistentID == song.persistentID {
            // Tapping the same song as target again - deselect it
            selectedTargetTrack = nil
        } else {
            // If this song was previously selected as source, clear source selection
            if selectedSourceTrack?.persistentID == song.persistentID {
                selectedSourceTrack = nil
            }
            // Set as new target
            selectedTargetTrack = song
        }
    }
    
    private func removeSong(_ song: MPMediaItem) {
        // Clear selections if the removed song was selected
        if selectedSourceTrack?.persistentID == song.persistentID {
            selectedSourceTrack = nil
        }
        if selectedTargetTrack?.persistentID == song.persistentID {
            selectedTargetTrack = nil
        }
        
        // Remove the song using the scan view model method
        scanViewModel.removeSong(from: group.id, songId: song.persistentID)
        
        // If the group now has less than 2 songs, dismiss the detail view
        if let updatedGroup = scanViewModel.duplicateGroups.first(where: { $0.id == group.id }),
           updatedGroup.songs.count < 2 {
            onDismiss()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func matchPlayCount() {
        guard let sourceTrack = selectedSourceTrack,
              let targetTrack = selectedTargetTrack else {
            alertMessage = "Please select both source and target tracks."
            showingAlert = true
            return
        }
        
        // Set the tracks in the music matcher view model
        musicMatcherViewModel.selectSourceTrack(sourceTrack)
        musicMatcherViewModel.selectTargetTrack(targetTrack)
        
        // Start matching
        musicMatcherViewModel.startMatching()
    }
    
    private func addPlayCount() {
        guard let sourceTrack = selectedSourceTrack,
              let targetTrack = selectedTargetTrack else {
            alertMessage = "Please select both source and target tracks."
            showingAlert = true
            return
        }
        
        // Set the tracks in the music matcher view model
        musicMatcherViewModel.selectSourceTrack(sourceTrack)
        musicMatcherViewModel.selectTargetTrack(targetTrack)
        
        // Start adding
        musicMatcherViewModel.startAdding()
    }
}

// MARK: - Duplicate Version Row Component (unchanged)
struct DuplicateVersionRow: View {
    let song: MPMediaItem
    let isSource: Bool
    let isTarget: Bool
    let onSelectAsSource: () -> Void
    let onSelectAsTarget: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.small) {
            HStack {
                // Album info
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.albumTitle ?? "Unknown Album")
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    if let releaseDate = song.releaseDate {
                        Text(DateFormatter.year.string(from: releaseDate))
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextTertiary)
                    }
                }
                
                Spacer()
                
                // Play count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(song.playCount)")
                        .font(AppFont.headline)
                        .fontWeight(.bold)
                        .foregroundColor(playCountColor)
                    
                    Text("plays")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextSecondary)
                }
                
                // Remove button
                Button(action: onRemove) {
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
            
            // Selection buttons
            HStack(spacing: AppSpacing.small) {
                Button(action: onSelectAsSource) {
                    HStack(spacing: 4) {
                        Image(systemName: isSource ? "checkmark.circle.fill" : "circle")
                            .font(AppFont.iconSmall)
                        Text("Source")
                            .font(AppFont.caption)
                    }
                    .foregroundColor(isSource ? Color.designPrimary : Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(isSource ? Color.designPrimary.opacity(0.2) : Color.clear)
                            .stroke(isSource ? Color.designPrimary : Color.designTextTertiary, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onSelectAsTarget) {
                    HStack(spacing: 4) {
                        Image(systemName: isTarget ? "checkmark.circle.fill" : "circle")
                            .font(AppFont.iconSmall)
                        Text("Target")
                            .font(AppFont.caption)
                    }
                    .foregroundColor(isTarget ? Color.designSecondary : Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(isTarget ? Color.designSecondary.opacity(0.2) : Color.clear)
                            .stroke(isTarget ? Color.designSecondary : Color.designTextTertiary, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding(AppSpacing.small)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                .fill(backgroundColor)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    private var playCountColor: Color {
        if isSource {
            return Color.designPrimary
        } else if isTarget {
            return Color.designSecondary
        } else {
            return Color.designTextPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isSource {
            return Color.designPrimary.opacity(0.1)
        } else if isTarget {
            return Color.designSecondary.opacity(0.1)
        } else {
            return Color.designBackgroundTertiary
        }
    }
    
    private var borderColor: Color {
        if isSource {
            return Color.designPrimary.opacity(0.3)
        } else if isTarget {
            return Color.designSecondary.opacity(0.3)
        } else {
            return Color.designTextTertiary.opacity(0.3)
        }
    }
}

// MARK: - Date Formatter Extension
private extension DateFormatter {
    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}
