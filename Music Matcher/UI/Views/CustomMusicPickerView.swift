import SwiftUI
import MediaPlayer

struct CustomMusicPickerView: View {
    @StateObject private var viewModel = MusicLibraryViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedSong: MPMediaItem?
    
    let onSelection: (MPMediaItem) -> Void
    let pickerTitle: String
    
    init(title: String = "Select Song", onSelection: @escaping (MPMediaItem) -> Void) {
        self.pickerTitle = title
        self.onSelection = onSelection
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBarSection
                
                // Content
                contentSection
            }
            .background(Color.designBackground)
            .navigationTitle(pickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.designPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppSpacing.small) {
                        // Sort Menu Button
                        Menu {
                            ForEach(MusicLibraryViewModel.SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    viewModel.sortOption = option
                                }) {
                                    HStack {
                                        Text(option.displayName)
                                        if viewModel.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(Color.designPrimary)
                        }
                        
                        // Refresh Button (if needed)
                        if viewModel.allSongs.count != viewModel.totalSongsCount {
                            Button(action: {
                                viewModel.refreshLibrary()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(Color.designPrimary)
                            }
                        }
                    }
                }
            }
        }
        .accentColor(Color.designPrimary)
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        VStack(spacing: AppSpacing.small) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.designTextSecondary)
                    .font(AppFont.iconSmall)
                
                TextField("Search songs, artists, or albums", text: $viewModel.searchText)
                    .font(AppFont.body)
                    .foregroundColor(Color.designTextPrimary)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.designTextSecondary)
                            .font(AppFont.iconSmall)
                    }
                }
            }
            .padding(AppSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color.designBackgroundTertiary)
            )
            .padding(.horizontal)
            .padding(.top, AppSpacing.small)
            .padding(.bottom, AppSpacing.small)
        }
        .background(Color.designBackground)
    }
    
    // MARK: - Content Section
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            LoadingStateView(
                title: "Loading Music Library...",
                message: "Please wait while we load your music collection."
            )
        } else if viewModel.filteredSongs.isEmpty && !viewModel.searchText.isEmpty {
            EmptyStateView.noSearchResults(searchTerm: viewModel.searchText)
        } else if viewModel.allSongs.isEmpty {
            EmptyStateView.noMusicLibrary {
                // Open Music app or provide guidance
                if let url = URL(string: "music://") {
                    UIApplication.shared.open(url)
                }
            }
        } else {
            songListView
        }
    }
    
    // MARK: - Song List View
    private var songListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredSongs, id: \.persistentID) { song in
                    SongDetailRow(
                        song: song,
                        mode: .picker,
                        action: .pick,
                        isSelected: selectedSong?.persistentID == song.persistentID,
                        showPlayCount: true,
                        showDuration: true,
                        showDateAdded: viewModel.sortOption == .dateAdded, onSecondaryAction:  {
                        selectedSong = song
                        onSelection(song)
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            .padding(.bottom, AppSpacing.medium)
        }
    }
}
