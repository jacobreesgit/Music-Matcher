import SwiftUI
import MediaPlayer

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var scanViewModel = ScanViewModel()
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var shortcutActionManager: ShortcutActionManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(onNavigateToScan: {
                selectedTab = 1
            })
            .tabItem {
                Label("Matcher", systemImage: "music.note")
            }
            .tag(0)
            
            ScanTabView(scanViewModel: scanViewModel)
                .tabItem {
                    Label("Smart Scan", systemImage: "magnifyingglass.circle")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(Color.designPrimary)
        .task {
            // Configure tab bar appearance asynchronously
            await configureTabBarAppearance()
            
            // Trigger auto-scan if needed (after a delay)
            await triggerAutoScanIfNeeded()
        }
        .onChange(of: shortcutActionManager.shouldTriggerScan) { _, shouldTrigger in
            if shouldTrigger {
                handleSmartScanShortcut()
            }
        }
    }
    
    @MainActor
    private func configureTabBarAppearance() async {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    @MainActor
    private func triggerAutoScanIfNeeded() async {
        // Don't auto-scan if already done
        guard !appStateManager.hasCompletedInitialScan else { return }
        
        // Wait for app to be fully loaded
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Check permission and scan
        if appStateManager.musicPermissionStatus == .authorized {
            appStateManager.hasCompletedInitialScan = true
            print("🚀 MainTabView: Starting auto-scan after delay...")
            scanViewModel.startScan()
        } else {
            print("❌ MainTabView: Music library access not granted, auto-scan skipped")
        }
    }
    
    private func handleSmartScanShortcut() {
        print("🔍 MainTabView: Handling Smart Scan shortcut")
        
        // Navigate to Smart Scan tab
        selectedTab = 1
        
        if appStateManager.musicPermissionStatus == .authorized {
            // Delay to ensure tab switch completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🚀 MainTabView: Starting Smart Scan from shortcut...")
                scanViewModel.startScan()
            }
        } else {
            print("❌ MainTabView: Cannot start Smart Scan - music library access not granted")
        }
    }
}
