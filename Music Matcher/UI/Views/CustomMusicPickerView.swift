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
                
                // Song List
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredSongs.isEmpty && !viewModel.searchText.isEmpty {
                    emptySearchView
                } else if viewModel.allSongs.isEmpty {
                    emptyLibraryView
                } else {
                    songListView
                }
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
    
    private var songListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredSongs, id: \.persistentID) { song in
                    SongDisplayRow(
                        track: song,
                        icon: "music.note",
                        placeholderTitle: "",
                        style: .list,
                        isSelected: selectedSong?.persistentID == song.persistentID,
                        showDateAdded: viewModel.sortOption == .dateAdded
                    ) {
                        selectedSong = song
                        onSelection(song)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.bottom, AppSpacing.medium)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.designPrimary))
                .scaleEffect(1.5)
            
            Text("Loading Music Library...")
                .font(AppFont.headline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Color.designTextTertiary)
            
            Text("No Results")
                .font(AppFont.title3)
                .foregroundColor(Color.designTextPrimary)
            
            Text("No songs found matching '\(viewModel.searchText)'")
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(Color.designTextTertiary)
            
            Text("No Music Found")
                .font(AppFont.title3)
                .foregroundColor(Color.designTextPrimary)
            
            Text("Your music library appears to be empty. Add some music to your device to use Music Matcher.")
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
}
