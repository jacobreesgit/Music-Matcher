import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Music Player")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Use System Music Player")
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: $settingsManager.useSystemMusicPlayer)
                                .labelsHidden()
                        }
                        
                        Text(settingsManager.useSystemMusicPlayer ?
                             "Will replace currently playing music" :
                             "Won't interfere with currently playing music")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("About Music Repeater")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "music.note.list")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Music Repeater")
                                    .font(.headline)
                                Text("Version 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Synchronize play counts between different versions of the same song.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Features:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                FeatureRow(text: "Match play counts between single and album versions")
                                FeatureRow(text: "Add play counts together")
                                FeatureRow(text: "Fast-forward playback to save time")
                                FeatureRow(text: "Choose between system and application music players")
                            }
                        }
                        
                        Text("Made with ♥ for music lovers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.blue)
                .fontWeight(.bold)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// Remove the separate AboutView since it's now integrated
