import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var viewModel = MusicMatcherViewModel()
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var musicLibraryPermission: MPMediaLibraryAuthorizationStatus = .notDetermined
    @State private var hasCheckedPermission = false
    
    let onNavigateToScan: () -> Void
    
    init(onNavigateToScan: @escaping () -> Void = {}) {
        self.onNavigateToScan = onNavigateToScan
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if musicLibraryPermission == .authorized {
                    authorizedView
                } else {
                    permissionRequestView
                }
            }
            .background(Color.designBackground)
            .navigationTitle(musicLibraryPermission == .authorized ? "Music Matcher" : "")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(musicLibraryPermission != .authorized)
        }
        .onAppear {
            if !hasCheckedPermission {
                checkMusicLibraryPermission()
                hasCheckedPermission = true
            }
        }
        .onReceive(viewModel.$alertMessage) { message in
            if !message.isEmpty {
                alertMessage = message
                showingAlert = true
                viewModel.alertMessage = ""
            }
        }
        .alert("Music Matcher", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var authorizedView: some View {
        FixedActionButtonsContainer(
            buttons: ActionButtonGroup.musicMatcherActions(
                canPerformActions: viewModel.canPerformActions && !viewModel.isProcessing && !isSourceLessThanTarget,
                onMatch: { matchPlayCount() },
                onAdd: { addPlayCount() }
            )
        ) {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Tip about Smart Scan
                    if viewModel.sourceTrack == nil && viewModel.targetTrack == nil {
                        smartScanTipCard
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    VStack(spacing: AppSpacing.large) {
                        // Source Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Source Track", subtitle: "Track to copy play count from")
                            
                            SongDetailRow(
                                song: viewModel.sourceTrack,
                                mode: .selection,
                                action: .select,
                                placeholderTitle: "Choose Source Track",
                                placeholderSubtitle: "Tap to select from your music library", onSecondaryAction:  {
                                showingSourcePicker = true
                            })
                        }
                        
                        // Target Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
                            
                            SongDetailRow(
                                song: viewModel.targetTrack,
                                mode: .selection,
                                action: .select,
                                placeholderTitle: "Choose Target Track",
                                placeholderSubtitle: "Tap to select from your music library", onSecondaryAction:  {
                                showingTargetPicker = true
                            })
                        }
                    }
                    .padding(.horizontal)
                    
                    // Warning Banners
                    warningBannersSection
                        .padding(.horizontal)
                    
                    // Track Comparison Section
                    if let sourceTrack = viewModel.sourceTrack,
                       let targetTrack = viewModel.targetTrack,
                       !viewModel.isSameSong,
                       sourceTrack.playCount > targetTrack.playCount {
                        PlayCountComparison(
                            sourceTrack: sourceTrack,
                            targetTrack: targetTrack
                        )
                        .padding(.horizontal)
                    }
                    
                    // Add bottom spacing for fixed buttons
                    Spacer(minLength: 140)
                }
            }
        }
        .sheet(isPresented: $showingSourcePicker) {
            CustomMusicPickerView(title: "Select Source Track") { item in
                viewModel.selectSourceTrack(item)
            }
        }
        .sheet(isPresented: $showingTargetPicker) {
            CustomMusicPickerView(title: "Select Target Track") { item in
                viewModel.selectTargetTrack(item)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showingProcessingView) {
            ProcessingView(viewModel: viewModel)
        }
    }
    
    // MARK: - Smart Scan Tip Card
    private var smartScanTipCard: some View {
        Button(action: {
            onNavigateToScan()
        }) {
            AppCard {
                HStack {
                    Image(systemName: "lightbulb")
                        .font(AppFont.iconMedium)
                        .foregroundColor(Color.designInfo)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tip: Try Smart Scan!")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designTextPrimary)
                        
                        Text("Automatically find duplicate songs across different albums")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(AppFont.iconSmall)
                        .foregroundColor(Color.designTextTertiary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Warning Banners Section
    @ViewBuilder
    private var warningBannersSection: some View {
        VStack(spacing: AppSpacing.medium) {
            // Same Song Warning
            if viewModel.isSameSong {
                AppWarningBanner("Warning: You've selected the same song for both source and target.")
            }
            
            // Play Count Warnings
            if let sourceTrack = viewModel.sourceTrack,
               let targetTrack = viewModel.targetTrack,
               !viewModel.isSameSong {
                
                if sourceTrack.playCount == targetTrack.playCount {
                    AppWarningBanner("Both tracks have the same play count (\(sourceTrack.playCount)). No additional plays are needed.", icon: "exclamationmark.triangle.fill")
                } else if sourceTrack.playCount < targetTrack.playCount {
                    AppWarningBanner("Source track has fewer plays (\(sourceTrack.playCount)) than target track (\(targetTrack.playCount)). Consider swapping the tracks or selecting a different source.", icon: "exclamationmark.triangle.fill")
                }
            }
        }
    }
    
    // MARK: - Permission Request View
    private var permissionRequestView: some View {
        Group {
            if musicLibraryPermission == .denied {
                AppPermissionScreen(
                    icon: "music.note.house",
                    title: "Music Library Access",
                    description: "Music Matcher needs access to your music library to synchronize play counts between different versions of songs.",
                    buttonTitle: "Open Settings",
                    buttonAction: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    },
                    statusMessage: "To use Music Matcher, please enable Music access in Settings → Privacy & Security → Media & Apple Music → Music Matcher"
                )
            } else if musicLibraryPermission == .restricted {
                AppPermissionScreen(
                    icon: "music.note.house",
                    title: "Music Library Access",
                    description: "Music access is restricted on this device.",
                    buttonTitle: "Contact Administrator",
                    buttonAction: { },
                    statusMessage: "Music access is restricted and cannot be enabled by the user."
                )
            } else {
                AppPermissionScreen(
                    icon: "music.note.house",
                    title: "Music Library Access",
                    description: "Music Matcher needs access to your music library to synchronize play counts between different versions of songs.",
                    buttonTitle: "Grant Music Access",
                    buttonAction: {
                        requestMusicLibraryAccess()
                    }
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isSourceLessThanTarget: Bool {
        guard let sourceTrack = viewModel.sourceTrack,
              let targetTrack = viewModel.targetTrack else {
            return false
        }
        return sourceTrack.playCount <= targetTrack.playCount
    }
    
    // MARK: - Helper Methods
    private func checkMusicLibraryPermission() {
        musicLibraryPermission = MPMediaLibrary.authorizationStatus()
    }
    
    private func matchPlayCount() {
        if viewModel.sourceTrack == nil {
            alertMessage = "Please select the source track first."
            showingAlert = true
            return
        }
        
        if viewModel.targetTrack == nil {
            alertMessage = "Please select the target track first."
            showingAlert = true
            return
        }
        
        if viewModel.isSameSong {
            alertMessage = "You've selected the same song for both source and target. Please choose different versions of the song."
            showingAlert = true
            return
        }
        
        viewModel.startMatching()
    }
    
    private func addPlayCount() {
        if viewModel.sourceTrack == nil {
            alertMessage = "Please select the source track first."
            showingAlert = true
            return
        }
        
        if viewModel.targetTrack == nil {
            alertMessage = "Please select the target track first."
            showingAlert = true
            return
        }
        
        if viewModel.isSameSong {
            alertMessage = "You've selected the same song for both source and target. Please choose different versions of the song."
            showingAlert = true
            return
        }
        
        viewModel.startAdding()
    }
    
    private func requestMusicLibraryAccess() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                musicLibraryPermission = status
                if status != .authorized {
                    // Don't show additional alert since the UI already shows the status
                }
            }
        }
    }
}
