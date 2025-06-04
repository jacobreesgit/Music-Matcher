import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var viewModel = MusicRepeaterViewModel()
    @State private var showingSinglePicker = false
    @State private var showingAlbumPicker = false
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
        VStack(spacing: 20) {
            Text("Music Repeater")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 15) {
                // Single Version Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Single Version")
                        .font(.headline)
                    
                    Button(action: {
                        showingSinglePicker = true
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                            Text(viewModel.singleTrackName.isEmpty ? "Choose Single Version" : viewModel.singleTrackName)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    if !viewModel.singleTrackName.isEmpty {
                        Text("Play Count: \(viewModel.singlePlayCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 5)
                    }
                }
                
                // Album Version Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Album Version")
                        .font(.headline)
                    
                    Button(action: {
                        showingAlbumPicker = true
                    }) {
                        HStack {
                            Image(systemName: "music.note.list")
                            Text(viewModel.albumTrackName.isEmpty ? "Choose Album Version" : viewModel.albumTrackName)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                    
                    if !viewModel.albumTrackName.isEmpty {
                        Text("Play Count: \(viewModel.albumPlayCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 5)
                    }
                }
            }
            .padding(.horizontal)
            
            // Same Song Warning - Full Width
            if viewModel.isSameSong {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Warning: You've selected the same song for both versions.")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 15) {
                // Match Play Count Button
                Button(action: {
                    matchPlayCount()
                }) {
                    VStack(spacing: 4) {
                        Text("Match")
                            .font(.headline)
                        if viewModel.canMatchPlayCount && !viewModel.isSameSong {
                            Text("\(viewModel.albumPlayCount) → \(viewModel.singlePlayCount)")
                                .font(.caption)
                        } else {
                            Text("Make Equal")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canPerformActions ? Color.blue : Color.gray)
                    .cornerRadius(15)
                }
                .disabled(!viewModel.canPerformActions || viewModel.isProcessing)
                
                // Add Play Count Button
                Button(action: {
                    addPlayCount()
                }) {
                    VStack(spacing: 4) {
                        Text("Add")
                            .font(.headline)
                        if viewModel.canMatchPlayCount && !viewModel.isSameSong {
                            Text("\(viewModel.albumPlayCount) → \(viewModel.albumPlayCount + viewModel.singlePlayCount)")
                                .font(.caption)
                        } else {
                            Text("Add Together")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canPerformActions ? Color.green : Color.gray)
                    .cornerRadius(15)
                }
                .disabled(!viewModel.canPerformActions || viewModel.isProcessing)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $showingSinglePicker) {
            MediaPickerView(onSelection: { item in
                viewModel.selectSingleTrack(item)
            })
        }
        .sheet(isPresented: $showingAlbumPicker) {
            MediaPickerView(onSelection: { item in
                viewModel.selectAlbumTrack(item)
            })
        }
        .fullScreenCover(isPresented: $viewModel.showingProcessingView) {
            ProcessingView(viewModel: viewModel)
        }
    }
    
    private var permissionRequestView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: "music.note.house")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // Title and Description
            VStack(spacing: 15) {
                Text("Music Library Access")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Music Repeater needs access to your music library to synchronize play counts between different versions of songs.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
            }
            
            // Permission button
            if musicLibraryPermission == .denied {
                Button(action: {
                    // Open Settings since permission was denied
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
            } else if musicLibraryPermission == .notDetermined {
                Button(action: {
                    requestMusicLibraryAccess()
                }) {
                    Text("Grant Music Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
            }
            
            // Status text
            Group {
                if musicLibraryPermission == .denied {
                    VStack(spacing: 10) {
                        Text("Access Denied")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        Text("To use Music Repeater, please enable Music access in Settings → Privacy & Security → Media & Apple Music → Music Repeater")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                } else if musicLibraryPermission == .restricted {
                    Text("Music access is restricted on this device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
    }
    
    private func checkMusicLibraryPermission() {
        musicLibraryPermission = MPMediaLibrary.authorizationStatus()
    }
    
    private func matchPlayCount() {
        if viewModel.singleTrack == nil {
            alertMessage = "Please select the single version first."
            showingAlert = true
            return
        }
        
        if viewModel.albumTrack == nil {
            alertMessage = "Please select the album version first."
            showingAlert = true
            return
        }
        
        if viewModel.isSameSong {
            alertMessage = "You've selected the same song for both versions. Please choose different versions of the song."
            showingAlert = true
            return
        }
        
        viewModel.startMatching()
    }
    
    private func addPlayCount() {
        if viewModel.singleTrack == nil {
            alertMessage = "Please select the single version first."
            showingAlert = true
            return
        }
        
        if viewModel.albumTrack == nil {
            alertMessage = "Please select the album version first."
            showingAlert = true
            return
        }
        
        if viewModel.isSameSong {
            alertMessage = "You've selected the same song for both versions. Please choose different versions of the song."
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
