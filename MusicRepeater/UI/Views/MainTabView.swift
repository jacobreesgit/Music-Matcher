import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView(onNavigateToScan: {
                selectedTab = 1
            })
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibilityLabel("Music Repeater")
                    Text("Repeater")
                        .font(AppFont.caption)
                }
                .tag(0)
            
            ScanTabView()
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
        }
    }
}
