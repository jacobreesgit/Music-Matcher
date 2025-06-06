import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var viewModel = MusicRepeaterViewModel()
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var musicLibraryPermission: MPMediaLibraryAuthorizationStatus = .notDetermined
    @State private var hasCheckedPermission = false
    
    var body: some View {
        Group {
            if musicLibraryPermission == .authorized {
                authorizedView
            } else {
                permissionRequestView
            }
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
        .alert("Music Repeater", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var authorizedView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Main Title
                    Text("Music Repeater")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color.designTextPrimary)
                        .padding(.top, AppSpacing.xl)
                    
                    VStack(spacing: AppSpacing.large) {
                        // Source Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Source Track", subtitle: "Track to copy play count from")
                            
                            AppSelectionButton(
                                track: viewModel.sourceTrack,
                                icon: "music.note",
                                placeholderTitle: "Choose Source Track",
                                placeholderSubtitle: "Tap to select from your music library"
                            ) {
                                showingSourcePicker = true
                            }
                        }
                        
                        // Target Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
                            
                            AppSelectionButton(
                                track: viewModel.targetTrack,
                                icon: "music.note.list",
                                placeholderTitle: "Choose Target Track",
                                placeholderSubtitle: "Tap to select from your music library"
                            ) {
                                showingTargetPicker = true
                            }
                        }
                    }
                    .appPadding(.horizontal)
                    
                    // Warning Banners (all at same width level)
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
                    .appPadding(.horizontal)
                    
                    // Track Comparison Section (only show when source has more plays than target)
                    if let sourceTrack = viewModel.sourceTrack,
                       let targetTrack = viewModel.targetTrack,
                       !viewModel.isSameSong,
                       sourceTrack.playCount > targetTrack.playCount {
                        trackComparisonSection(source: sourceTrack, target: targetTrack)
                            .appPadding(.horizontal)
                    }
                    
                    // Add bottom spacing for safe area
                    Spacer(minLength: 140)
                }
            }
            
            // Fixed Action Buttons at bottom
            actionButtonsSection
        }
        .background(Color.designBackground)
        .sheet(isPresented: $showingSourcePicker) {
            MediaPickerView(onSelection: { item in
                viewModel.selectSourceTrack(item)
            })
        }
        .sheet(isPresented: $showingTargetPicker) {
            MediaPickerView(onSelection: { item in
                viewModel.selectTargetTrack(item)
            })
        }
        .fullScreenCover(isPresented: $viewModel.showingProcessingView) {
            ProcessingView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private func trackComparisonSection(source: MPMediaItem, target: MPMediaItem) -> some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                AppSectionHeader("Play Count Comparison")
                
                HStack(spacing: AppSpacing.medium) {
                    // Source track mini info
                    VStack(spacing: AppSpacing.small) {
                        Text("Source")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("\(source.playCount)")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designPrimary)
                        
                        Text("plays")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Arrow and difference
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(AppFont.iconMedium)
                            .foregroundColor(Color.designTextSecondary)
                        
                        let difference = source.playCount - target.playCount
                        Text("+\(difference)")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designSecondary)
                    }
                    
                    // Target track mini info
                    VStack(spacing: AppSpacing.small) {
                        Text("Target")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("\(target.playCount)")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designSecondary)
                        
                        Text("plays")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
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
                        
                        Text("\(target.playCount) → \(source.playCount)")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designPrimary)
                    }
                    
                    HStack {
                        Text("Add:")
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Spacer()
                        
                        Text("\(target.playCount) → \(target.playCount + source.playCount)")
                            .font(AppFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designSecondary)
                    }
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.medium) {
                // Match Play Count Button
                AppPrimaryButton(
                    "Match",
                    isEnabled: viewModel.canPerformActions && !viewModel.isProcessing && !isSourceLessThanTarget
                ) {
                    matchPlayCount()
                }
                
                // Add Play Count Button
                AppSecondaryButton(
                    "Add",
                    isEnabled: viewModel.canPerformActions && !viewModel.isProcessing && !isSourceLessThanTarget
                ) {
                    addPlayCount()
                }
            }
            .appPadding(.horizontal)
        }
        .padding(.bottom, AppSpacing.medium)
        .background(
            Color.designBackground
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private var isSourceLessThanTarget: Bool {
        guard let sourceTrack = viewModel.sourceTrack,
              let targetTrack = viewModel.targetTrack else {
            return false
        }
        return sourceTrack.playCount <= targetTrack.playCount
    }
    
    private var permissionRequestView: some View {
        Group {
            if musicLibraryPermission == .denied {
                AppPermissionScreen(
                    icon: "music.note.house",
                    title: "Music Library Access",
                    description: "Music Repeater needs access to your music library to synchronize play counts between different versions of songs.",
                    buttonTitle: "Open Settings",
                    buttonAction: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    },
                    statusMessage: "To use Music Repeater, please enable Music access in Settings → Privacy & Security → Media & Apple Music → Music Repeater"
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
                    description: "Music Repeater needs access to your music library to synchronize play counts between different versions of songs.",
                    buttonTitle: "Grant Music Access",
                    buttonAction: {
                        requestMusicLibraryAccess()
                    }
                )
            }
        }
        .background(Color.designBackground)
    }
    
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

// MediaPicker wrapper for SwiftUI
struct MediaPickerView: UIViewControllerRepresentable {
    let onSelection: (MPMediaItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = context.coordinator
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = true
        picker.showsItemsWithProtectedAssets = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MPMediaPickerControllerDelegate {
        let parent: MediaPickerView
        
        init(_ parent: MediaPickerView) {
            self.parent = parent
        }
        
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            if let item = mediaItemCollection.items.first {
                parent.onSelection(item)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
