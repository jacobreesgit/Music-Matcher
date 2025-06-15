import Foundation
import MediaPlayer
import Combine

class MusicLibraryViewModel: ObservableObject {
    @Published var allSongs: [MPMediaItem] = []
    @Published var filteredSongs: [MPMediaItem] = []
    @Published var searchText: String = "" {
        didSet {
            // Debounce search
            searchWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.filterSongs()
            }
            searchWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
    }
    @Published var isLoading: Bool = false
    @Published var groupingMode: GroupingMode = .none
    @Published var sortOption: SortOption = .title
    
    enum GroupingMode: String, CaseIterable {
        case none = "None"
        case artist = "Artist"
        case album = "Album"
        
        var displayName: String { rawValue }
    }
    
    enum SortOption: String, CaseIterable {
        case title = "Title"
        case artist = "Artist"
        case album = "Album"
        case dateAdded = "Recently Added"
        case playCount = "Play Count"
        
        var displayName: String { rawValue }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    private var loadingTask: Task<Void, Never>?
    
    init() {
        // Load asynchronously
        loadMusicLibraryAsync()
        
        // Observe sort option changes
        $sortOption
            .sink { [weak self] _ in
                self?.sortSongs()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        loadingTask?.cancel()
        searchWorkItem?.cancel()
    }
    
    func loadMusicLibrary() {
        loadMusicLibraryAsync()
    }
    
    func refreshLibrary() {
        loadMusicLibraryAsync()
    }
    
    private func loadMusicLibraryAsync() {
        loadingTask?.cancel()
        
        loadingTask = Task {
            await loadLibrary()
        }
    }
    
    @MainActor
    private func loadLibrary() async {
        isLoading = true
        
        // Load in background
        let items = await Task.detached(priority: .userInitiated) {
            MPMediaQuery.songs().items ?? []
        }.value
        
        // Update UI
        allSongs = items
        sortSongs()
        filterSongs()
        isLoading = false
    }
    
    private func filterSongs() {
        if searchText.isEmpty {
            filteredSongs = allSongs
        } else {
            // Perform filtering in background for large libraries
            Task {
                let filtered = await filterSongsAsync(searchText: searchText)
                await MainActor.run {
                    self.filteredSongs = filtered
                }
            }
        }
    }
    
    private func filterSongsAsync(searchText: String) async -> [MPMediaItem] {
        let searchLower = searchText.lowercased()
        return allSongs.filter { song in
            let title = song.title?.lowercased() ?? ""
            let artist = song.artist?.lowercased() ?? ""
            let album = song.albumTitle?.lowercased() ?? ""
            
            return title.contains(searchLower) ||
                   artist.contains(searchLower) ||
                   album.contains(searchLower)
        }
    }
    
    private func sortSongs() {
        switch sortOption {
        case .title:
            allSongs.sort { ($0.title ?? "") < ($1.title ?? "") }
        case .artist:
            allSongs.sort {
                let artist0 = $0.artist ?? ""
                let artist1 = $1.artist ?? ""
                if artist0 == artist1 {
                    return ($0.title ?? "") < ($1.title ?? "")
                }
                return artist0 < artist1
            }
        case .album:
            allSongs.sort {
                let album0 = $0.albumTitle ?? ""
                let album1 = $1.albumTitle ?? ""
                if album0 == album1 {
                    return ($0.title ?? "") < ($1.title ?? "")
                }
                return album0 < album1
            }
        case .dateAdded:
            allSongs.sort {
                // dateAdded is non-optional in newer iOS versions
                return $0.dateAdded > $1.dateAdded
            }
        case .playCount:
            allSongs.sort { $0.playCount > $1.playCount }
        }
    }
    
    func groupedSongs() -> [(key: String, songs: [MPMediaItem])] {
        let songsToGroup = searchText.isEmpty ? allSongs : filteredSongs
        
        switch groupingMode {
        case .none:
            return [("All Songs", songsToGroup)]
            
        case .artist:
            let grouped = Dictionary(grouping: songsToGroup) { song in
                song.artist ?? "Unknown Artist"
            }
            return grouped.sorted { $0.key < $1.key }.map { (key: $0.key, songs: $0.value) }
            
        case .album:
            let grouped = Dictionary(grouping: songsToGroup) { song in
                song.albumTitle ?? "Unknown Album"
            }
            return grouped.sorted { $0.key < $1.key }.map { (key: $0.key, songs: $0.value) }
        }
    }
    
    var displayedSongsCount: Int {
        searchText.isEmpty ? allSongs.count : filteredSongs.count
    }
    
    var totalSongsCount: Int {
        allSongs.count
    }
}
