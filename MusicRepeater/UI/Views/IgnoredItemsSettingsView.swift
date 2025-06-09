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
                        ForEach(ignoredItemsManager.ignoredSongDetails) { songDetail in
                            IgnoredSongCard(songDetail: songDetail) { songId in
                                ignoredItemsManager.restoreSong(songId)
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
                        ForEach(ignoredItemsManager.ignoredGroups) { group in
                            IgnoredDuplicateGroupRow(group: group) {
                                ignoredItemsManager.restoreGroup(group)
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

struct IgnoredSongCard: View {
    let songDetail: IgnoredItemsManager.IgnoredSongDetail
    let onRestoreSong: (MPMediaEntityPersistentID) -> Void
    
    var body: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(songDetail.songTitle)
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    Text(songDetail.artistName)
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                        .lineLimit(1)
                    
                    Text(songDetail.albumTitle)
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextTertiary)
                        .lineLimit(1)
                    
                    Text("Ignored \(formatIgnoredDate(songDetail.ignoredDate))")
                        .font(AppFont.caption)
                        .foregroundColor(Color.designTextTertiary)
                }
                
                Spacer()
                
                Button("Restore") {
                    onRestoreSong(songDetail.songId)
                }
                .font(AppFont.subheadline)
                .foregroundColor(Color.designPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .stroke(Color.designPrimary, lineWidth: 1)
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

// MARK: - Ignored Duplicate Group Row using DuplicateGroupRow
struct IgnoredDuplicateGroupRow: View {
    let group: ScanViewModel.DuplicateGroup
    let onRestore: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Use the DuplicateGroupRow component with no action
            DuplicateGroupRow(group: group) {
                // No action - we handle restore separately
            }
            .allowsHitTesting(false) // Disable interaction with the main row
            
            // Add restore section at the bottom
            VStack(spacing: 0) {
                Divider()
                    .background(Color.designTextTertiary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ignored Group")
                            .font(AppFont.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.designWarning)
                        
                        Text("This entire duplicate group is hidden from scans")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Restore Group") {
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
                .padding(AppSpacing.medium)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(Color.designBackgroundSecondary)
                .appShadow(.light)
        )
        .overlay(
            // Add a subtle border to indicate it's ignored
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .stroke(Color.designWarning.opacity(0.3), lineWidth: 1)
        )
    }
}
