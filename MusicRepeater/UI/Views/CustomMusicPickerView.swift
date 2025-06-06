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
                    songRow(song)
                }
            }
            .padding(.bottom, AppSpacing.medium)
        }
    }
    
    private func songRow(_ song: MPMediaItem) -> some View {
        Button(action: {
            selectedSong = song
            onSelection(song)
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: AppSpacing.medium) {
                // Album Artwork
                Group {
                    if let artwork = song.artwork {
                        ArtworkView(artwork: artwork)
                    } else {
                        RoundedRectangle(cornerRadius: AppCornerRadius.small)
                            .fill(Color.designBackgroundTertiary)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(AppFont.iconSmall)
                                    .foregroundColor(Color.designTextSecondary)
                            )
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                
                // Song Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title ?? "Unknown Title")
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        if let artist = song.artist {
                            Text(artist)
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                                .lineLimit(1)
                        }
                        
                        if song.artist != nil && song.albumTitle != nil {
                            Text("•")
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextTertiary)
                        }
                        
                        if let album = song.albumTitle {
                            Text(album)
                                .font(AppFont.caption)
                                .foregroundColor(Color.designTextSecondary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Additional info
                    HStack(spacing: AppSpacing.small) {
                        // Play count
                        Label("\(song.playCount)", systemImage: "play.fill")
                            .font(AppFont.caption2)
                            .foregroundColor(Color.designPrimary)
                        
                        // Duration
                        if song.playbackDuration > 0 {
                            Text("•")
                                .font(AppFont.caption2)
                                .foregroundColor(Color.designTextTertiary)
                            
                            Text(formatDuration(song.playbackDuration))
                                .font(AppFont.caption2)
                                .foregroundColor(Color.designTextTertiary)
                        }
                        
                        // Date added (if sorting by date)
                        if viewModel.sortOption == .dateAdded {
                            Text("•")
                                .font(AppFont.caption2)
                                .foregroundColor(Color.designTextTertiary)
                            
                            Text(formatDateAdded(song.dateAdded))
                                .font(AppFont.caption2)
                                .foregroundColor(Color.designTextTertiary)
                        }
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: "chevron.right")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            selectedSong?.persistentID == song.persistentID ?
            Color.designPrimary.opacity(0.1) : Color.clear
        )
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
            
            Text("Your music library appears to be empty. Add some music to your device to use Music Repeater.")
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatDateAdded(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#if DEBUG
// Mock ViewModel for Previews
class MockMusicLibraryViewModel: MusicLibraryViewModel {
    private let mockEmpty: Bool
    
    init(isEmpty: Bool = false) {
        self.mockEmpty = isEmpty
        super.init()
        setupMockData()
    }
    
    private func setupMockData() {
        if mockEmpty {
            self.allSongs = []
            self.filteredSongs = []
        } else {
            // Create mock songs (this won't actually work with real MPMediaItems in preview)
            // But we can simulate the loaded state
            self.isLoading = false
            // In a real implementation, you'd create mock MPMediaItems
            // For preview purposes, we'll just simulate non-empty state
        }
    }
}

// Mock CustomMusicPickerView for Previews
struct MockCustomMusicPickerView: View {
    let title: String
    let isEmpty: Bool
    let onSelection: (MPMediaItem) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                VStack(spacing: AppSpacing.small) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.designTextSecondary)
                            .font(AppFont.iconSmall)
                        
                        TextField("Search songs, artists, or albums", text: $searchText)
                            .font(AppFont.body)
                            .foregroundColor(Color.designTextPrimary)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
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
                
                // Content
                if isEmpty {
                    emptyLibraryView
                } else {
                    mockSongListView
                }
            }
            .background(Color.designBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.designPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Title") { }
                        Button("Artist") { }
                        Button("Album") { }
                        Button("Recently Added") { }
                        Button("Play Count") { }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(Color.designPrimary)
                    }
                }
            }
        }
        .accentColor(Color.designPrimary)
    }
    
    private var mockSongListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(mockSongs, id: \.id) { song in
                    mockSongRow(song)
                }
            }
            .padding(.bottom, AppSpacing.medium)
        }
    }
    
    private func mockSongRow(_ song: MockSong) -> some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: AppSpacing.medium) {
                // Mock Album Artwork
                RoundedRectangle(cornerRadius: AppCornerRadius.small)
                    .fill(Color.designBackgroundTertiary)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(AppFont.iconSmall)
                            .foregroundColor(Color.designTextSecondary)
                    )
                    .frame(width: 50, height: 50)
                
                // Song Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text(song.artist)
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextTertiary)
                        
                        Text(song.album)
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: AppSpacing.small) {
                        Label("\(song.playCount)", systemImage: "play.fill")
                            .font(AppFont.caption2)
                            .foregroundColor(Color.designPrimary)
                        
                        Text("•")
                            .font(AppFont.caption2)
                            .foregroundColor(Color.designTextTertiary)
                        
                        Text(song.duration)
                            .font(AppFont.caption2)
                            .foregroundColor(Color.designTextTertiary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(AppFont.iconSmall)
                    .foregroundColor(Color.designTextTertiary)
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
            
            Text("Your music library appears to be empty. Add some music to your device to use Music Repeater.")
                .font(AppFont.body)
                .foregroundColor(Color.designTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    // Mock song data
    private var mockSongs: [MockSong] {
        [
            MockSong(id: 1, title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", playCount: 127, duration: "5:55"),
            MockSong(id: 2, title: "Hotel California", artist: "Eagles", album: "Hotel California", playCount: 89, duration: "6:30"),
            MockSong(id: 3, title: "Stairway to Heaven", artist: "Led Zeppelin", album: "Led Zeppelin IV", playCount: 156, duration: "8:02"),
            MockSong(id: 4, title: "Don't Stop Believin'", artist: "Journey", album: "Escape", playCount: 73, duration: "4:10"),
            MockSong(id: 5, title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", playCount: 94, duration: "5:03"),
            MockSong(id: 6, title: "Imagine", artist: "John Lennon", album: "Imagine", playCount: 112, duration: "3:07"),
            MockSong(id: 7, title: "Billie Jean", artist: "Michael Jackson", album: "Thriller", playCount: 201, duration: "4:54"),
            MockSong(id: 8, title: "Yesterday", artist: "The Beatles", album: "Help!", playCount: 145, duration: "2:05")
        ]
    }
}

struct MockSong {
    let id: Int
    let title: String
    let artist: String
    let album: String
    let playCount: Int
    let duration: String
}

struct CustomMusicPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MockCustomMusicPickerView(title: "Select Source Track", isEmpty: true) { _ in }
                .previewDisplayName("Empty Library")
            
            MockCustomMusicPickerView(title: "Select Target Track", isEmpty: false) { _ in }
                .previewDisplayName("With Songs")
        }
    }
}
#endif
