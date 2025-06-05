HStack {
                                Image(systemName: "music.note.list")
                                    .font(AppFont.title2)
                                    .foregroundColor(Color.designPrimary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Music Repeater")
                                        .font(AppFont.headline)
                                        .foregroundColor(Color.designTextPrimary)
                                    
                                    Text("Version 1.0")
                                        .font(AppFont.caption)
                                import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // Music Player Settings Section
                Section(header: sectionHeader("Music Player")) {
                    AppCard(padding: AppSpacing.small) {
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            HStack {
                                Text("Use System Music Player")
                                    .font(AppFont.body)
                                    .foregroundColor(Color.designTextPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $settingsManager.useSystemMusicPlayer)
                                    .labelsHidden()
                                    .accentColor(Color.designPrimary)
                            }
                            
                            Text(settingsManager.useSystemMusicPlayer ?
                                 "Will replace currently playing music" :
                                 "Won't interfere with currently playing music")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                        }
                        .appPadding()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                // About Section
                Section(header: sectionHeader("About Music Repeater")) {
                    AppCard(padding: AppSpacing.medium) {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            // App Header
                            HStack {
                                Image(systemName: "music.note.list")
                                    .font(AppFont.title2)
                                    .foregroundColor(Color.appPrimary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Music Repeater")
                                        .font(AppFont.headline)
                                        .foregroundColor(Color.appTextPrimary)
                                    
                                    Text("Version 1.0")
                                        .font(AppFont.caption)
                                        .foregroundColor(Color.designTextSecondary)
                                }
                                
                                Spacer()
                            }
                            
                            // Description
                            Text("Synchronize play counts between different versions of the same song.")
                                .font(AppFont.body)
                                .foregroundColor(Color.designTextSecondary)
                            
                            // Features Section
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text("Features:")
                                    .font(AppFont.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.designTextPrimary)
                                
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    AppFeatureRow("Match play counts between single and album versions")
                                    AppFeatureRow("Add play counts together")
                                    AppFeatureRow("Fast-forward playback to save time")
                                    AppFeatureRow("Choose between system and application music players")
                                }
                            }
                            
                            // Footer
                            Text("Made with ♥ for music lovers")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                                .italic()
                                .padding(.top, AppSpacing.small)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .background(Color.designBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(Color.designPrimary)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppFont.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Color.designTextSecondary)
            .textCase(.none)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            SettingsView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
#endif
