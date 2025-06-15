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
            FixedActionButtonsContainer(
                buttons: ActionButtonGroup.musicMatcherActions(
                    canPerformActions: canPerformActions,
                    onMatch: { matchPlayCount() },
                    onAdd: { addPlayCount() }
                )
            ) {
                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        // Song Header
                        groupHeaderCard
                        
                        // Versions List
                        versionsCard
                        
                        // Selected Tracks Summary
                        if selectedSourceTrack != nil || selectedTargetTrack != nil {
                            selectionSummaryCard
                        }
                        
                        // Bottom spacing for actions
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal)
                }
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
    
    // MARK: - Group Header Card
    private var groupHeaderCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                // Album artwork from highest play count version
                if let artwork = group.sourceCandidate?.artwork {
                    ArtworkView(
                        artwork: artwork,
                        size: 100,
                        cornerRadius: AppCornerRadius.medium
                    )
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
                    playCountSummary
                }
            }
        }
    }
    
    // MARK: - Play Count Summary
    private var playCountSummary: some View {
        VStack(spacing: AppSpacing.small) {
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
    
    // MARK: - Versions Card
    private var versionsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                AppSectionHeader("All Versions", subtitle: "Tap to select source and target tracks")
                
                VStack(spacing: AppSpacing.small) {
                    ForEach(group.songs, id: \.persistentID) { song in
                        SongDetailRow(
                            song: song,
                            mode: .version,
                            action: selectedAction(for: song),
                            isSelected: isSelected(song),
                            showPlayCount: true,
                            onAction: {
                                handleSongSelection(song)
                            },
                            onSecondaryAction: {
                                songToRemove = song
                                showingRemoveConfirmation = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Selection Summary Card
    @ViewBuilder
    private var selectionSummaryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                AppSectionHeader("Selection Summary")
                
                if let sourceTrack = selectedSourceTrack {
                    selectionRow(
                        title: "Source (copy from):",
                        track: sourceTrack,
                        color: Color.designPrimary
                    )
                }
                
                if let targetTrack = selectedTargetTrack {
                    selectionRow(
                        title: "Target (copy to):",
                        track: targetTrack,
                        color: Color.designSecondary
                    )
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
    
    // MARK: - Selection Row
    private func selectionRow(title: String, track: MPMediaItem, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title)
                .font(AppFont.caption)
                .foregroundColor(Color.designTextSecondary)
            
            HStack {
                Text(track.albumTitle ?? "Unknown Album")
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextPrimary)
                
                Spacer()
                
                Text("\(track.playCount) plays")
                    .font(AppFont.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
        }
    }
    
    // MARK: - Computed Properties
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
    
    private func selectedAction(for song: MPMediaItem) -> SongDetailRow.ActionType {
        if selectedSourceTrack?.persistentID == song.persistentID {
            return .selectAsSource
        } else if selectedTargetTrack?.persistentID == song.persistentID {
            return .selectAsTarget
        } else if selectedSourceTrack == nil {
            return .selectAsSource
        } else {
            return .selectAsTarget
        }
    }
    
    private func isSelected(_ song: MPMediaItem) -> Bool {
        return selectedSourceTrack?.persistentID == song.persistentID ||
               selectedTargetTrack?.persistentID == song.persistentID
    }
    
    private func handleSongSelection(_ song: MPMediaItem) {
        let currentAction = selectedAction(for: song)
        
        switch currentAction {
        case .selectAsSource:
            selectAsSource(song)
        case .selectAsTarget:
            selectAsTarget(song)
        default:
            break
        }
    }
    
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

// MARK: - Date Formatter Extension
private extension DateFormatter {
    static let year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
}
