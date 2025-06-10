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
            .navigationTitle(musicLibraryPermission == .authorized ? "Smart Scan" : "")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(musicLibraryPermission != .authorized)
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
            title: "Music Library Access",
            description: "Smart Scan needs access to your music library to find duplicate songs with the same title and artist across different albums.",
            buttonTitle: "Grant Music Access",
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
