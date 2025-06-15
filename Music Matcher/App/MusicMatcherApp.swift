import SwiftUI

@main
struct MusicMatcherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appStateManager = AppStateManager()
    @StateObject private var shortcutActionManager = ShortcutActionManager.shared
    
    var body: some Scene {
        WindowGroup {
            // Show a loading view immediately while the app initializes
            ZStack {
                // Background color to prevent white flash
                Color.designBackground
                    .ignoresSafeArea()
                
                // Main content
                if appStateManager.isInitialized {
                    MainTabView()
                        .environmentObject(shortcutActionManager)
                        .environmentObject(appStateManager)
                        .transition(.opacity)
                } else {
                    // Show a branded loading screen instead of white
                    AppLoadingView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appStateManager.isInitialized)
        }
    }
}
