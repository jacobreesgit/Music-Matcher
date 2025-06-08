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
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibilityLabel("Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
        }
        .accentColor(Color.designPrimary)
        .background(Color.designBackground)
    }
}
