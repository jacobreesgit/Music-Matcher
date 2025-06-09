import SwiftUI
import MediaPlayer

struct ScanTabView: View {
    @ObservedObject var scanViewModel: ScanViewModel
    @StateObject private var musicRepeaterViewModel = MusicRepeaterViewModel()
    @StateObject private var ignoredItemsManager = IgnoredItemsManager.shared
    @State private var musicLibraryPermission: MPMediaLibraryAuthorizationStatus = .notDetermined
    @State private var selectedGroup: ScanViewModel.DuplicateGroup?
    @State private var showingProcessingView = false
    
    init(scanViewModel: ScanViewModel) {
        self.scanViewModel = scanViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if musicLibraryPermission == .authorized {
                    authorizedView
                } else {
                    permissionView
                }
            }
            .background(Color.designBackground)
            .navigationTitle("Smart Scan")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkMusicLibraryPermission()
            }
            .sheet(item: $selectedGroup) { group in
                DuplicateGroupDetailView(
                    group: group,
                    musicRepeaterViewModel: musicRepeaterViewModel,
                    scanViewModel: scanViewModel
                ) {
                    selectedGroup = nil
                }
            }
            .fullScreenCover(isPresented: $musicRepeaterViewModel.showingProcessingView) {
                ProcessingView(viewModel: musicRepeaterViewModel)
            }
        }
    }
    
    private var authorizedView: some View {
        VStack(spacing: 0) {
            if scanViewModel.isScanning {
                scanningView
            } else if scanViewModel.scanComplete {
                resultsView
            } else {
                initialView
            }
        }
    }
    
    private var initialView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 80))
                .foregroundColor(Color.designPrimary)
            
            VStack(spacing: AppSpacing.medium) {
                Text("Smart Duplicate Detection")
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Find songs with the same title and artist but different albums. Perfect for matching play counts between album and single versions.")
                    .font(AppFont.body)
                    .foregroundColor(Color.designTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            AppPrimaryButton("Start Scan") {
                scanViewModel.startScan()
            }
            .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    private var scanningView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            VStack(spacing: AppSpacing.large) {
                Text("Scanning Library")
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
                
                AppProgressRing(
                    progress: scanViewModel.scanProgress,
                    lineWidth: 10,
                    size: 160
                )
                .overlay(
                    VStack(spacing: 4) {
                        Text("\(Int(scanViewModel.scanProgress * 100))%")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designTextPrimary)
                        
                        Text("complete")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                    }
                )
                
                VStack(spacing: AppSpacing.small) {
                    Text("Analyzing \(scanViewModel.totalSongsScanned) songs")
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                    
                    Text("Looking for duplicate titles across different albums")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextTertiary)
                }
            }
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Results Summary Header
            VStack(spacing: AppSpacing.medium) {
                AppCard {
                    VStack(spacing: AppSpacing.medium) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Scan Complete")
                                    .font(AppFont.headline)
                                    .foregroundColor(Color.designTextPrimary)
                                
                                Text("Found potential duplicates")
                                    .font(AppFont.subheadline)
                                    .foregroundColor(Color.designTextSecondary)
                            }
                            
                            Spacer()
                            
                            Button("Rescan") {
                                scanViewModel.startScan()
                            }
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designPrimary)
                        }
                        
                        HStack(spacing: AppSpacing.large) {
                            VStack(spacing: 4) {
                                Text("\(scanViewModel.totalSongsScanned)")
                                    .font(AppFont.counterMedium)
                                    .foregroundColor(Color.designTextPrimary)
                                
                                Text("songs scanned")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color.designTextSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(scanViewModel.duplicatesFound)")
                                    .font(AppFont.counterMedium)
                                    .foregroundColor(Color.designPrimary)
                                
                                Text("duplicate groups")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color.designTextSecondary)
                            }
                            
                            VStack(spacing: 4) {
                                let totalDuplicates = scanViewModel.duplicateGroups.reduce(0) { $0 + $1.songs.count }
                                Text("\(totalDuplicates)")
                                    .font(AppFont.counterMedium)
                                    .foregroundColor(Color.designSecondary)
                                
                                Text("total songs")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color.designTextSecondary)
                            }
                        }
                        
                        // Show ignored items indicator if any exist
                        if ignoredItemsManager.hasIgnoredItems {
                            Divider()
                                .background(Color.designTextTertiary)
                            
                            HStack {
                                Image(systemName: "eye.slash")
                                    .font(AppFont.iconSmall)
                                    .foregroundColor(Color.designInfo)
                                
                                Text("\(ignoredItemsManager.totalIgnoredItems) items ignored from previous removals")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color.designInfo)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Results List
            if scanViewModel.duplicateGroups.isEmpty {
                emptyResultsView
            } else {
                duplicateGroupsList
            }
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(Color.designSuccess)
            
            Text("No Duplicates Found")
                .font(AppFont.title3)
                .foregroundColor(Color.designTextPrimary)
            
            Text("Your music library doesn't contain songs with the same title and artist across different albums.")
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    private var duplicateGroupsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.medium) {
                ForEach(scanViewModel.duplicateGroups) { group in
                    DuplicateGroupRow(group: group) {
                        selectedGroup = group
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, AppSpacing.medium)
            .padding(.bottom, AppSpacing.large)
        }
    }
    
    private var permissionView: some View {
        AppPermissionScreen(
            icon: "magnifyingglass.circle",
            title: "Library Access Required",
            description: "Smart Scan needs access to your music library to find duplicate songs across different albums.",
            buttonTitle: "Grant Access",
            buttonAction: {
                requestMusicLibraryAccess()
            }
        )
    }
    
    private func checkMusicLibraryPermission() {
        musicLibraryPermission = MPMediaLibrary.authorizationStatus()
    }
    
    private func requestMusicLibraryAccess() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                musicLibraryPermission = status
            }
        }
    }
}

// MARK: - Duplicate Group Row Component
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
