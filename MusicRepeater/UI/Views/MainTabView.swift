import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibilityLabel("Music Repeater")
                    Text("Repeater")
                        .font(AppFont.caption)
                }
            
            ScanTabView()
                .tabItem {
                    Image(systemName: "magnifyingglass.circle")
                        .accessibilityLabel("Smart Scan")
                    Text("Smart Scan")
                        .font(AppFont.caption)
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
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
