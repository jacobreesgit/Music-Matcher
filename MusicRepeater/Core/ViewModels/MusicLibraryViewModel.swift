import Foundation
import MediaPlayer
import Combine

class MusicLibraryViewModel: ObservableObject {
    @Published var allSongs: [MPMediaItem] = []
    @Published var filteredSongs: [MPMediaItem] = []
    @Published var searchText: String = "" {
        didSet {
            filterSongs()
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
    
    init() {
        loadMusicLibrary()
        
        // Observe sort option changes
        $sortOption
            .sink { [weak self] _ in
                self?.sortSongs()
            }
            .store(in: &cancellables)
    }
    
    func loadMusicLibrary() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Create a query for all songs
            let query = MPMediaQuery.songs()
            
            // Get all items
            let items = query.items ?? []
            
            DispatchQueue.main.async {
                self?.allSongs = items
                self?.sortSongs()
                self?.filterSongs()
                self?.isLoading = false
            }
        }
    }
    
    func refreshLibrary() {
        loadMusicLibrary()
    }
    
    private func filterSongs() {
        if searchText.isEmpty {
            filteredSongs = allSongs
        } else {
            let searchLower = searchText.lowercased()
            filteredSongs = allSongs.filter { song in
                let title = song.title?.lowercased() ?? ""
                let artist = song.artist?.lowercased() ?? ""
                let album = song.albumTitle?.lowercased() ?? ""
                
                return title.contains(searchLower) ||
                       artist.contains(searchLower) ||
                       album.contains(searchLower)
            }
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
