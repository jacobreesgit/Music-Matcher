import SwiftUI
import MediaPlayer

struct ScanTabView: View {
    @ObservedObject var scanViewModel: ScanViewModel
    @StateObject private var musicMatcherViewModel = MusicMatcherViewModel()
    @ObservedObject private var ignoredItemsManager = IgnoredItemsManager.shared
    @EnvironmentObject var appStateManager: AppStateManager
    @State private var selectedGroup: ScanViewModel.DuplicateGroup?
    @State private var showingProcessingView = false
    
    init(scanViewModel: ScanViewModel) {
        self.scanViewModel = scanViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if appStateManager.musicPermissionStatus == .authorized {
                    authorizedView
                } else {
                    permissionView
                }
            }
            .background(Color.designBackground)
            .navigationTitle(appStateManager.musicPermissionStatus == .authorized ? "Smart Scan" : "")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(appStateManager.musicPermissionStatus != .authorized)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force single view on iPad
        .task {
            // Update permission status if needed
            await appStateManager.updateMusicPermissionStatus()
        }
        .sheet(item: $selectedGroup) { group in
            DuplicateGroupDetailView(
                group: group,
                musicMatcherViewModel: musicMatcherViewModel,
                scanViewModel: scanViewModel
            ) {
                selectedGroup = nil
            }
        }
        .fullScreenCover(isPresented: $musicMatcherViewModel.showingProcessingView) {
            ProcessingView(viewModel: musicMatcherViewModel)
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
    
    // MARK: - Initial View
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
    
    // MARK: - Scanning View
    private var scanningView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            ScanProgressView(
                progress: scanViewModel.scanProgress,
                totalSongsScanned: scanViewModel.totalSongsScanned,
                isScanning: scanViewModel.isScanning,
                style: .fullScreen
            )
            
            Spacer()
        }
    }
    
    // MARK: - Results View
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.large) {
                // Results Summary Header
                ScanSummaryCard(
                    totalSongsScanned: scanViewModel.totalSongsScanned,
                    duplicatesFound: scanViewModel.duplicatesFound,
                    totalDuplicateSongs: scanViewModel.duplicateGroups.reduce(0) { $0 + $1.songs.count },
                    totalIgnoredItems: ignoredItemsManager.totalIgnoredItems,
                    showIgnoredItems: ignoredItemsManager.hasIgnoredItems,
                    onRescan: {
                        scanViewModel.startScan()
                    }
                )
                .padding(.horizontal)
                .padding(.top)
                
                // Results Content
                if scanViewModel.duplicateGroups.isEmpty {
                    emptyResultsContent
                } else {
                    duplicateGroupsContent
                }
            }
        }
    }
    
    // MARK: - Empty Results Content
    private var emptyResultsContent: some View {
        EmptyScanResultsCard(
            totalSongsScanned: scanViewModel.totalSongsScanned,
            hasIgnoredItems: ignoredItemsManager.hasIgnoredItems,
            onRescan: {
                scanViewModel.startScan()
            }
        )
        .padding(.horizontal)
    }
    
    // MARK: - Duplicate Groups Content
    private var duplicateGroupsContent: some View {
        LazyVStack(spacing: AppSpacing.medium) {
            ForEach(scanViewModel.duplicateGroups) { group in
                DuplicateGroupCard(
                    group: group,
                    state: .active,
                    onAction: {
                        selectedGroup = group
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.bottom, AppSpacing.large)
    }
    
    // MARK: - Permission View
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
    
    // MARK: - Helper Methods
    private func requestMusicLibraryAccess() {
        MPMediaLibrary.requestAuthorization { status in
            Task {
                await MainActor.run {
                    appStateManager.musicPermissionStatus = status
                }
            }
        }
    }
}
