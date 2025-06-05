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

#if DEBUG
// Mock ContentView for previews that bypasses permission checks
struct MockContentView: View {
    @StateObject private var viewModel = MusicRepeaterViewModel()
    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    // Main Title
                    Text("Music Repeater")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color.designTextPrimary)
                        .padding(.top, AppSpacing.xxl)
                    
                    VStack(spacing: AppSpacing.medium) {
                        // Source Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Source Track", subtitle: "Track to copy play count from")
                            
                            AppSelectionButton(
                                icon: "music.note",
                                title: "Sample Song - Artist Name",
                                subtitle: "Play Count: 42"
                            ) {
                                // Mock action
                            }
                        }
                        
                        // Target Track Section
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
                            
                            AppSelectionButton(
                                icon: "music.note.list",
                                title: "Same Song (Album Version) - Artist Name",
                                subtitle: "Play Count: 25"
                            ) {
                                // Mock action
                            }
                        }
                    }
                    .appPadding(.horizontal)
                    
                    // Add bottom spacing for safe area
                    Spacer(minLength: 120)
                }
            }
            
            // Fixed Action Buttons at bottom
            VStack(spacing: AppSpacing.small) {
                HStack(spacing: AppSpacing.medium) {
                    // Match Play Count Button
                    AppPrimaryButton(
                        "Match",
                        subtitle: "25 → 42",
                        isEnabled: true
                    ) {
                        // Mock action
                    }
                    
                    // Add Play Count Button
                    AppSecondaryButton(
                        "Add",
                        subtitle: "25 → 67",
                        isEnabled: true
                    ) {
                        // Mock action
                    }
                }
                .appPadding(.horizontal)
            }
            .padding(.bottom, AppSpacing.medium)
            .background(Color(UIColor.systemGroupedBackground))
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct MockMainTabView: View {
    var body: some View {
        TabView {
            MockContentView()
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

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MockMainTabView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            MockMainTabView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
                
            MockMainTabView()
                .preferredColorScheme(.light)
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("Large Accessibility")
        }
    }
}
#endif
