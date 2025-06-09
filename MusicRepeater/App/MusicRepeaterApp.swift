import SwiftUI

@main
struct MusicRepeaterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var shortcutActionManager = ShortcutActionManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(shortcutActionManager)
        }
    }
}
