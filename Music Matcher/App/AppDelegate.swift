import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Preload resources early
        ResourcePreloader.shared.preloadResources()
        
        // Handle shortcut item if app was launched via shortcut
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            ShortcutActionManager.shared.handleShortcutItem(shortcutItem)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Handle shortcut item if app was launched via shortcut
        if let shortcutItem = options.shortcutItem {
            ShortcutActionManager.shared.handleShortcutItem(shortcutItem)
        }
        
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        // Handle shortcut item when app is already running
        let handled = ShortcutActionManager.shared.handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }
}

// MARK: - Shortcut Action Manager
class ShortcutActionManager: ObservableObject {
    static let shared = ShortcutActionManager()
    
    @Published var shouldTriggerScan = false
    
    private init() {} // Singleton
    
    @discardableResult
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("🔧 AppDelegate: Handling shortcut item: \(shortcutItem.type)")
        
        switch shortcutItem.type {
        case "com.jacobrees.MusicMatcher.smartscan":
            DispatchQueue.main.async {
                self.triggerScan()
            }
            return true
            
        default:
            return false
        }
    }
    
    func triggerScan() {
        print("🔄 ShortcutActionManager: Triggering Smart Scan")
        shouldTriggerScan = true
        // Reset after a short delay to allow the view to react
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldTriggerScan = false
        }
    }
}
