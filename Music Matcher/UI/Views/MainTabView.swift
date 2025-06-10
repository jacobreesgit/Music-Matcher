import SwiftUI
import MediaPlayer

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var scanViewModel = ScanViewModel()
    @State private var hasTriggeredAutoScan = false
    @ObservedObject private var shortcutActionManager = ShortcutActionManager.shared // Changed from @StateObject
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(onNavigateToScan: {
                selectedTab = 1
            })
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibilityLabel("Music Matcher")
                    Text("Matcher")
                        .font(AppFont.caption)
                }
                .tag(0)
            
            ScanTabView(scanViewModel: scanViewModel)
                .tabItem {
                    Image(systemName: "magnifyingglass.circle")
                        .accessibilityLabel("Smart Scan")
                    Text("Smart Scan")
                        .font(AppFont.caption)
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
                .tag(2)
        }
        .accentColor(Color.designPrimary)
        .onAppear {
            // Configure native iOS tab bar appearance for glassy effect
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            
            // This gives the native iOS translucent/glassy effect
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // Trigger auto-scan if we have permission and haven't done it yet
            triggerAutoScanIfNeeded()
        }
        .onChange(of: shortcutActionManager.shouldTriggerScan) { _, shouldTrigger in
            if shouldTrigger {
                handleSmartScanShortcut()
            }
        }
    }
    
    private func triggerAutoScanIfNeeded() {
        guard !hasTriggeredAutoScan else { return }
        
        let permission = MPMediaLibrary.authorizationStatus()
        print("🎵 MainTabView: Checking music library permission status: \(permission.rawValue)")
        
        if permission == .authorized {
            hasTriggeredAutoScan = true
            print("🔄 MainTabView: Music library access granted, triggering auto-scan in 1 second...")
            // Small delay to ensure the app is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("🚀 MainTabView: Starting auto-scan now...")
                scanViewModel.startScan()
            }
        } else {
            print("❌ MainTabView: Music library access not granted (status: \(permission.rawValue)), auto-scan skipped")
        }
    }
    
    private func handleSmartScanShortcut() {
        print("🔍 MainTabView: Handling Smart Scan shortcut")
        
        // Navigate to Smart Scan tab
        selectedTab = 1
        
        // Check for music library permission
        let permission = MPMediaLibrary.authorizationStatus()
        if permission == .authorized {
            // Small delay to ensure tab switch is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🚀 MainTabView: Starting Smart Scan from shortcut...")
                scanViewModel.startScan()
            }
        } else {
            print("❌ MainTabView: Cannot start Smart Scan - music library access not granted")
        }
    }
}
