import SwiftUI
import MediaPlayer

struct IgnoredItemsSettingsView: View {
    @StateObject private var ignoredItemsManager = IgnoredItemsManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var showingClearAllAlert = false
    @State private var clearAllType: ClearAllType = .songs
    
    enum ClearAllType {
        case songs
        case groups
        case all
        
        var title: String {
            switch self {
            case .songs: return "Clear All Songs"
            case .groups: return "Clear All Groups"
            case .all: return "Clear Everything"
            }
        }
        
        var message: String {
            switch self {
            case .songs: return "This will restore all individually ignored songs. They will appear in future scans."
            case .groups: return "This will restore all ignored groups. They will appear in future scans."
            case .all: return "This will restore all ignored songs and groups. They will all appear in future scans."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !ignoredItemsManager.hasIgnoredItems {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .background(Color.designBackground)
            .navigationTitle("Ignored Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.designPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if ignoredItemsManager.hasIgnoredItems {
                        Menu {
                            if !ignoredItemsManager.ignoredSongs.isEmpty {
                                Button("Clear All Songs") {
                                    clearAllType = .songs
                                    showingClearAllAlert = true
                                }
                            }
                            
                            if !ignoredItemsManager.ignoredGroups.isEmpty {
                                Button("Clear All Groups") {
                                    clearAllType = .groups
                                    showingClearAllAlert = true
                                }
                            }
                            
                            Button("Clear Everything") {
                                clearAllType = .all
                                showingClearAllAlert = true
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color.designError)
                        }
                    }
                }
            }
        }
        .alert(clearAllType.title, isPresented: $showingClearAllAlert) {
            Button("Clear", role: .destructive) {
                performClearAll()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(clearAllType.message)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(Color.designSuccess)
            
            VStack(spacing: AppSpacing.medium) {
                Text("No Ignored Items")
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
                
                Text("You haven't ignored any songs or groups from Smart Scan yet. When you remove items during scanning, they'll appear here.")
                    .font(AppFont.body)
                    .foregroundColor(Color.designTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            // Summary Card
            summaryCard
            
            // Tab Selector
            tabSelector
            
            // Swipeable Content
            TabView(selection: $selectedTab) {
                ignoredSongsView
                    .tag(0)
                
                ignoredGroupsView
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
    
    private var summaryCard: some View {
        AppCard {
            VStack(spacing: AppSpacing.medium) {
                HStack {
                    Text("Ignored Items Summary")
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                    
                    Spacer()
                }
                
                HStack(spacing: AppSpacing.large) {
                    VStack(spacing: 4) {
                        Text("\(ignoredItemsManager.ignoredSongs.count)")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designPrimary)
                        
                        Text("songs")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("\(ignoredItemsManager.ignoredGroups.count)")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designSecondary)
                        
                        Text("groups")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("\(ignoredItemsManager.totalIgnoredItems)")
                            .font(AppFont.counterMedium)
                            .foregroundColor(Color.designInfo)
                        
                        Text("total")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Text("These items won't appear in future Smart Scans")
                    .font(AppFont.caption)
                    .foregroundColor(Color.designTextTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            // Songs Tab
            Button(action: { selectedTab = 0 }) {
                VStack(spacing: 4) {
                    Text("Songs (\(ignoredItemsManager.ignoredSongs.count))")
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 0 ? Color.designPrimary : Color.designTextSecondary)
                    
                    Rectangle()
                        .fill(selectedTab == 0 ? Color.designPrimary : Color.clear)
                        .frame(height: 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
            
            // Groups Tab
            Button(action: { selectedTab = 1 }) {
                VStack(spacing: 4) {
                    Text("Groups (\(ignoredItemsManager.ignoredGroups.count))")
                        .font(AppFont.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == 1 ? Color.designSecondary : Color.designTextSecondary)
                    
                    Rectangle()
                        .fill(selectedTab == 1 ? Color.designSecondary : Color.clear)
                        .frame(height: 2)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.top, AppSpacing.medium)
    }
    
    private var ignoredSongsView: some View {
        Group {
            if ignoredItemsManager.ignoredSongs.isEmpty {
                emptyTabView(icon: "music.note", message: "No ignored songs")
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.medium) {
                        let groupedSongs = ignoredItemsManager.getIgnoredSongsByGroup()
                        
                        ForEach(Array(groupedSongs.keys.sorted()), id: \.self) { groupKey in
                            if let songs = groupedSongs[groupKey] {
                                IgnoredSongGroupCard(groupKey: groupKey, songs: songs) { songId in
                                    ignoredItemsManager.restoreSong(songId)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, AppSpacing.medium)
                    .padding(.bottom, AppSpacing.large)
                }
            }
        }
    }
    
    private var ignoredGroupsView: some View {
        Group {
            if ignoredItemsManager.ignoredGroups.isEmpty {
                emptyTabView(icon: "music.note.list", message: "No ignored groups")
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.medium) {
                        ForEach(ignoredItemsManager.ignoredGroupDetails) { group in
                            IgnoredGroupCard(group: group) {
                                ignoredItemsManager.restoreGroup(group.groupKey)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, AppSpacing.medium)
                    .padding(.bottom, AppSpacing.large)
                }
            }
        }
    }
    
    private func emptyTabView(icon: String, message: String) -> some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                VStack(spacing: AppSpacing.large) {
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color.designTextTertiary)
                    
                    Text(message)
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func performClearAll() {
        switch clearAllType {
        case .songs:
            ignoredItemsManager.clearAllIgnoredSongs()
        case .groups:
            ignoredItemsManager.clearAllIgnoredGroups()
        case .all:
            ignoredItemsManager.clearAll()
        }
    }
}

// MARK: - Supporting Views

struct IgnoredSongGroupCard: View {
    let groupKey: String
    let songs: [IgnoredItemsManager.IgnoredSongDetail]
    let onRestoreSong: (MPMediaEntityPersistentID) -> Void
    
    private var groupInfo: (title: String, artist: String) {
        if let firstSong = songs.first {
            // Extract from the first song's actual data
            return (firstSong.songTitle, firstSong.artistName)
        }
        
        // Fallback: parse from group key
        let components = groupKey.components(separatedBy: "|")
        return (components.first ?? "Unknown", components.last ?? "Unknown")
    }
    
    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                // Group Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(groupInfo.title)
                            .font(AppFont.headline)
                            .foregroundColor(Color.designTextPrimary)
                        
                        Text(groupInfo.artist)
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(songs.count) song\(songs.count == 1 ? "" : "s")")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designInfo)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.designInfo.opacity(0.2))
                        )
                }
                
                // Individual Songs
                VStack(spacing: AppSpacing.small) {
                    ForEach(songs.sorted(by: { $0.ignoredDate > $1.ignoredDate }), id: \.id) { song in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.albumTitle)
                                    .font(AppFont.subheadline)
                                    .foregroundColor(Color.designTextPrimary)
                                    .lineLimit(1)
                                
                                Text("Ignored \(formatIgnoredDate(song.ignoredDate))")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color.designTextTertiary)
                            }
                            
                            Spacer()
                            
                            Button("Restore") {
                                onRestoreSong(song.songId)
                            }
                            .font(AppFont.caption)
                            .foregroundColor(Color.designPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                    .stroke(Color.designPrimary, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, AppSpacing.small)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.small)
                                .fill(Color.designBackgroundTertiary)
                        )
                    }
                }
            }
        }
    }
    
    private func formatIgnoredDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct IgnoredGroupCard: View {
    let group: IgnoredItemsManager.IgnoredGroupDetail
    let onRestore: () -> Void
    
    var body: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(group.songTitle)
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(2)
                    
                    Text(group.artistName)
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                        .lineLimit(1)
                    
                    HStack {
                        Text("\(group.songCount) songs")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designInfo)
                        
                        Text("•")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextTertiary)
                        
                        Text("Ignored \(formatIgnoredDate(group.ignoredDate))")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextTertiary)
                    }
                }
                
                Spacer()
                
                Button("Restore") {
                    onRestore()
                }
                .font(AppFont.subheadline)
                .foregroundColor(Color.designSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .stroke(Color.designSecondary, lineWidth: 1)
                )
            }
        }
    }
    
    private func formatIgnoredDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
