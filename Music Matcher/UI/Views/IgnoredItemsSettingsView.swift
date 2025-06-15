import SwiftUI
import MediaPlayer

struct IgnoredItemsSettingsView: View {
    @ObservedObject private var ignoredItemsManager = IgnoredItemsManager.shared
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
                    EmptyStateView.noIgnoredItems()
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
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            // Summary Card
            summaryCard
            
            // Tab Content with Selector
            TabContentView(
                tabs: [
                    TabSelector.TabItem(
                        title: "Songs",
                        count: ignoredItemsManager.ignoredSongs.count,
                        color: Color.designPrimary
                    ),
                    TabSelector.TabItem(
                        title: "Groups",
                        count: ignoredItemsManager.ignoredGroups.count,
                        color: Color.designSecondary
                    )
                ],
                style: .underline
            ) { tabIndex in
                if tabIndex == 0 {
                    ignoredSongsContent
                } else {
                    ignoredGroupsContent
                }
            }
        }
    }
    
    // MARK: - Summary Card
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
                    MetricDisplay(
                        value: "\(ignoredItemsManager.ignoredSongs.count)",
                        label: "songs",
                        color: Color.designPrimary,
                        icon: "music.note"
                    )
                    
                    MetricDisplay(
                        value: "\(ignoredItemsManager.ignoredGroups.count)",
                        label: "groups",
                        color: Color.designSecondary,
                        icon: "music.note.list"
                    )
                    
                    MetricDisplay(
                        value: "\(ignoredItemsManager.totalIgnoredItems)",
                        label: "total",
                        color: Color.designInfo,
                        icon: "eye.slash"
                    )
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
    
    // MARK: - Ignored Songs Content
    @ViewBuilder
    private var ignoredSongsContent: some View {
        if ignoredItemsManager.ignoredSongs.isEmpty {
            EmptyStateView.noIgnoredSongs()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(ignoredItemsManager.ignoredSongDetails) { songDetail in
                        SongDetailRow(
                            song: nil, // We don't have the actual MPMediaItem, just details
                            mode: .ignored,
                            action: .restore,
                            showPlayCount: false,
                            placeholderTitle: songDetail.songTitle,
                            placeholderSubtitle: songDetail.artistName, onSecondaryAction:  {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                ignoredItemsManager.restoreSong(songDetail.songId)
                            }
                        })
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.large)
            }
        }
    }
    
    // MARK: - Ignored Groups Content
    @ViewBuilder
    private var ignoredGroupsContent: some View {
        if ignoredItemsManager.ignoredGroups.isEmpty {
            EmptyStateView.noIgnoredGroups()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: AppSpacing.medium) {
                    ForEach(ignoredItemsManager.ignoredGroups) { group in
                        DuplicateGroupCard(
                            group: group,
                            state: .ignored,
                            onAction: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    ignoredItemsManager.restoreGroup(group)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppSpacing.medium)
                .padding(.bottom, AppSpacing.large)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func performClearAll() {
        withAnimation(.easeInOut(duration: 0.3)) {
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
}
