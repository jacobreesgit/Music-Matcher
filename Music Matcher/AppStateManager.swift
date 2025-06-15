import Foundation
import MediaPlayer
import SwiftUI

class AppStateManager: ObservableObject {
    @Published var isInitialized = false
    @Published var hasCompletedInitialScan = false
    @Published var musicPermissionStatus: MPMediaLibraryAuthorizationStatus = .notDetermined
    
    init() {
        // Perform initialization asynchronously
        Task {
            await initialize()
        }
    }
    
    @MainActor
    private func initialize() async {
        // Check permissions first (non-blocking)
        musicPermissionStatus = MPMediaLibrary.authorizationStatus()
        
        // Preload resources
        ResourcePreloader.shared.preloadResources()
        
        // Small delay to ensure smooth transition
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Mark as initialized
        isInitialized = true
    }
    
    @MainActor
    func updateMusicPermissionStatus() async {
        let status = MPMediaLibrary.authorizationStatus()
        if musicPermissionStatus != status {
            musicPermissionStatus = status
        }
    }
}
