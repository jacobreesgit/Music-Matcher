import Foundation
import SwiftUI
import MediaPlayer

class ResourcePreloader {
    static let shared = ResourcePreloader()
    
    private init() {}
    
    func preloadResources() {
        Task {
            await preloadAssets()
        }
    }
    
    @MainActor
    private func preloadAssets() async {
        // Preload color assets to prevent lazy loading delays
        _ = Color.designPrimary
        _ = Color.designPrimaryDark
        _ = Color.designSecondary
        _ = Color.designSecondaryDark
        _ = Color.designBackground
        _ = Color.designBackgroundSecondary
        _ = Color.designBackgroundTertiary
        _ = Color.designTextPrimary
        _ = Color.designTextSecondary
        _ = Color.designTextTertiary
        _ = Color.designSuccess
        _ = Color.designWarning
        _ = Color.designError
        _ = Color.designInfo
        
        // Warm up the music library query (without blocking)
        Task.detached(priority: .background) {
            _ = MPMediaLibrary.authorizationStatus()
        }
        
        // Preload tab bar icons
        _ = UIImage(systemName: "music.note")
        _ = UIImage(systemName: "magnifyingglass.circle")
        _ = UIImage(systemName: "gear")
    }
}
