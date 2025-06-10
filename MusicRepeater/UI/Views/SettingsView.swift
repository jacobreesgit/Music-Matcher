import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsManager = SettingsManager.shared // Changed from @StateObject
    @ObservedObject private var ignoredItemsManager = IgnoredItemsManager.shared // Changed from @StateObject
    @State private var showingIgnoredItems = false
    
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
                    .listRowBackground(Color.designBackgroundSecondary)
                } header: {
                    sectionHeader("Music Player")
                }
                
                // Smart Scan Settings Section
                Section {
                    Button(action: {
                        showingIgnoredItems = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ignored Items")
                                    .font(AppFont.body)
                                    .foregroundColor(Color.designTextPrimary)
                                
                                if ignoredItemsManager.hasIgnoredItems {
                                    Text("\(ignoredItemsManager.totalIgnoredItems) items hidden from scans")
                                        .font(AppFont.caption)
                                        .foregroundColor(Color.designTextSecondary)
                                } else {
                                    Text("No items ignored")
                                        .font(AppFont.caption)
                                        .foregroundColor(Color.designTextSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            if ignoredItemsManager.hasIgnoredItems {
                                Text("\(ignoredItemsManager.totalIgnoredItems)")
                                    .font(AppFont.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.designInfo)
                                    )
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(AppFont.iconSmall)
                                .foregroundColor(Color.designTextTertiary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 8)
                    .listRowBackground(Color.designBackgroundSecondary)
                } header: {
                    sectionHeader("Smart Scan")
                }
            }
            .background(Color.designBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .accentColor(Color.designPrimary)
        .sheet(isPresented: $showingIgnoredItems) {
            IgnoredItemsSettingsView()
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppFont.subheadline)
            .fontWeight(.medium)
            .foregroundColor(Color.designTextSecondary)
            .textCase(.none)
    }
}
