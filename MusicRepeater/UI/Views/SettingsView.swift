import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // Music Player Settings Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use System Music Player")
                                .font(AppFont.body)
                                .foregroundColor(Color.designTextPrimary)
                            
                            Text(settingsManager.useSystemMusicPlayer ?
                                 "Will replace currently playing music" :
                                 "Won't interfere with currently playing music")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsManager.useSystemMusicPlayer)
                            .labelsHidden()
                            .accentColor(Color.designPrimary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color(UIColor.systemBackground))
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
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
