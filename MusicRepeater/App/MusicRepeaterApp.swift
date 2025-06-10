import SwiftUI

@main
struct MusicRepeaterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var shortcutActionManager = ShortcutActionManager.shared // Changed from @StateObject
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(shortcutActionManager)
        }
    }
}
