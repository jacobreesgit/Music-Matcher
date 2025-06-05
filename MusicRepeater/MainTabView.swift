import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "music.note")
                        .accessibleElement(label: "Music Repeater")
                    Text("Repeater")
                        .font(AppFont.caption)
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibleElement(label: "Settings")
                    Text("Settings")
                        .font(AppFont.caption)
                }
        }
        .accentColor(Color.appPrimary)
        .background(Color.appBackground)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainTabView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            MainTabView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
                
            MainTabView()
                .preferredColorScheme(.light)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Large Accessibility")
        }
    }
}
#endif
