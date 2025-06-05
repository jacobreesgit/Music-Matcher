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
                        .padding(.top, AppSpacing.xxl)
                    
                    VStack(spacing: AppSpacing.medium) {
                        // Source Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Source Track", subtitle: "Track to copy play count from")
                            
                            AppSelectionButton(
                                icon: "music.note",
                                title: viewModel.sourceTrackName.isEmpty ? "Choose Source Track" : viewModel.sourceTrackName,
                                subtitle: viewModel.sourceTrackName.isEmpty ? nil : "Play Count: \(viewModel.sourcePlayCount)"
                            ) {
                                showingSourcePicker = true
                            }
                        }
                        
                        // Target Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
                            
                            AppSelectionButton(
                                icon: "music.note.list",
                                title: viewModel.targetTrackName.isEmpty ? "Choose Target Track" : viewModel.targetTrackName,
                                subtitle: viewModel.targetTrackName.isEmpty ? nil : "Play Count: \(viewModel.targetPlayCount)"
                            ) {
                                showingTargetPicker = true
                            }
                        }
                    }
                    .appPadding(.horizontal)
                    
                    // Same Song Warning
                    if viewModel.isSameSong {
                        AppWarningBanner("Warning: You've selected the same song for both source and target.")
                            .appPadding(.horizontal)
                    }
                    
                    // Add bottom spacing for safe area
                    Spacer(minLength: 120)
                }
            }
            
            // Fixed Action Buttons at bottom
            VStack(spacing: AppSpacing.small) {
                HStack(spacing: AppSpacing.medium) {
                    // Match Play Count Button
                    AppPrimaryButton(
                        "Match",
                        subtitle: viewModel.canMatchPlayCount && !viewModel.isSameSong ?
                            "\(viewModel.targetPlayCount) → \(viewModel.sourcePlayCount)" : "Make Equal",
                        isEnabled: viewModel.canPerformActions && !viewModel.isProcessing
                    ) {
                        matchPlayCount()
                    }
                    
                    // Add Play Count Button
                    AppSecondaryButton(
                        "Add",
                        subtitle: viewModel.canMatchPlayCount && !viewModel.isSameSong ?
                            "\(viewModel.targetPlayCount) → \(viewModel.targetPlayCount + viewModel.sourcePlayCount)" : "Add Together",
                        isEnabled: viewModel.canPerformActions && !viewModel.isProcessing
                    ) {
                        addPlayCount()
                    }
                }
                .appPadding(.horizontal)
            }
            .padding(.bottom, AppSpacing.medium)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground))
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
