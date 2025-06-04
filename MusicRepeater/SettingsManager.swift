import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Settings keys
    private enum Keys {
        static let useSystemMusicPlayer = "useSystemMusicPlayer"
    }
    
    // Published properties for UI binding
    @Published var useSystemMusicPlayer: Bool {
        didSet {
            userDefaults.set(useSystemMusicPlayer, forKey: Keys.useSystemMusicPlayer)
        }
    }
    
    private init() {
        // Load saved settings or use defaults
        self.useSystemMusicPlayer = userDefaults.object(forKey: Keys.useSystemMusicPlayer) as? Bool ?? false
    }
}
