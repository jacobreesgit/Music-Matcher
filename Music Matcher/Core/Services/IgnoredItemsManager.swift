import Foundation
import MediaPlayer
import Combine

class IgnoredItemsManager: ObservableObject {
    static let shared = IgnoredItemsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Storage keys
    private enum Keys {
        static let ignoredSongs = "ignoredSongs"
        static let ignoredGroups = "ignoredGroups"
    }
    
    // Published properties for UI binding
    @Published var ignoredSongs: Set<MPMediaEntityPersistentID> = []
    @Published var ignoredGroups: [ScanViewModel.DuplicateGroup] = []
    
    // Derived properties for UI
    var ignoredSongDetails: [IgnoredSongDetail] {
        return ignoredSongs.compactMap { songId in
            // Try to find the song in the current library
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: songId,
                forProperty: MPMediaItemPropertyPersistentID
            ))
            
            guard let song = query.items?.first else { return nil }
            
            return IgnoredSongDetail(
                songId: songId,
                songTitle: song.title ?? "Unknown",
                artistName: song.artist ?? "Unknown",
                albumTitle: song.albumTitle ?? "Unknown",
                ignoredDate: Date() // We'll lose the original date, but this is acceptable for the rewrite
            )
        }
    }
    
    var ignoredDuplicateGroups: [ScanViewModel.DuplicateGroup] {
        return ignoredGroups
    }
    
    struct IgnoredSongDetail: Identifiable {
        let id = UUID()
        let songId: MPMediaEntityPersistentID
        let songTitle: String
        let artistName: String
        let albumTitle: String
        let ignoredDate: Date
    }
    
    private init() {
        loadIgnoredItems()
    }
    
    // MARK: - Load/Save Data
    
    private func loadIgnoredItems() {
        // Load ignored song IDs
        if let songData = userDefaults.data(forKey: Keys.ignoredSongs),
           let songIds = try? JSONDecoder().decode([MPMediaEntityPersistentID].self, from: songData) {
            ignoredSongs = Set(songIds)
        }
        
        // Load ignored groups
        if let groupData = userDefaults.data(forKey: Keys.ignoredGroups),
           let groupDataArray = try? JSONDecoder().decode([DuplicateGroupData].self, from: groupData) {
            ignoredGroups = groupDataArray.compactMap { $0.toDuplicateGroup() }
        }
        
        print("📋 IgnoredItemsManager: Loaded \(ignoredSongs.count) ignored songs and \(ignoredGroups.count) ignored groups")
    }
    
    private func saveIgnoredItems() {
        // Save ignored song IDs
        if let songData = try? JSONEncoder().encode(Array(ignoredSongs)) {
            userDefaults.set(songData, forKey: Keys.ignoredSongs)
        }
        
        // Save ignored groups
        let groupDataArray = ignoredGroups.map { DuplicateGroupData(from: $0) }
        if let groupData = try? JSONEncoder().encode(groupDataArray) {
            userDefaults.set(groupData, forKey: Keys.ignoredGroups)
        }
        
        print("💾 IgnoredItemsManager: Saved \(ignoredSongs.count) ignored songs and \(ignoredGroups.count) ignored groups")
    }
    
    // MARK: - Public Interface
    
    /// Check if a song should be ignored
    func shouldIgnoreSong(_ songId: MPMediaEntityPersistentID) -> Bool {
        return ignoredSongs.contains(songId)
    }
    
    /// Check if a group should be ignored
    func shouldIgnoreGroup(title: String, artist: String) -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return ignoredGroups.contains { group in
            let groupTitle = group.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let groupArtist = group.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return groupTitle == cleanTitle && groupArtist == cleanArtist
        }
    }
    
    /// Ignore a specific song from a group
    func ignoreSong(_ song: MPMediaItem, fromGroup group: ScanViewModel.DuplicateGroup) {
        let songId = song.persistentID
        ignoredSongs.insert(songId)
        saveIgnoredItems()
        
        print("🚫 IgnoredItemsManager: Ignored song '\(song.title ?? "Unknown")' from album '\(song.albumTitle ?? "Unknown")'")
    }
    
    /// Ignore an entire group
    func ignoreGroup(_ group: ScanViewModel.DuplicateGroup) {
        // Remove any existing group with the same title/artist to avoid duplicates
        ignoredGroups.removeAll { existingGroup in
            let existingTitle = existingGroup.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let existingArtist = existingGroup.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let newTitle = group.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let newArtist = group.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return existingTitle == newTitle && existingArtist == newArtist
        }
        
        // Add the new group
        ignoredGroups.append(group)
        saveIgnoredItems()
        
        print("🚫 IgnoredItemsManager: Ignored group '\(group.title)' by \(group.artist) (\(group.songs.count) songs)")
    }
    
    /// Restore a specific ignored song
    func restoreSong(_ songId: MPMediaEntityPersistentID) {
        ignoredSongs.remove(songId)
        saveIgnoredItems()
        
        print("✅ IgnoredItemsManager: Restored song with ID \(songId)")
    }
    
    /// Restore an entire ignored group
    func restoreGroup(_ group: ScanViewModel.DuplicateGroup) {
        let groupTitle = group.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let groupArtist = group.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        ignoredGroups.removeAll { existingGroup in
            let existingTitle = existingGroup.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let existingArtist = existingGroup.artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return existingTitle == groupTitle && existingArtist == groupArtist
        }
        
        saveIgnoredItems()
        
        print("✅ IgnoredItemsManager: Restored group '\(group.title)' by \(group.artist)")
    }
    
    /// Clear all ignored songs
    func clearAllIgnoredSongs() {
        let count = ignoredSongs.count
        ignoredSongs.removeAll()
        saveIgnoredItems()
        
        print("🗑️ IgnoredItemsManager: Cleared \(count) ignored songs")
    }
    
    /// Clear all ignored groups
    func clearAllIgnoredGroups() {
        let count = ignoredGroups.count
        ignoredGroups.removeAll()
        saveIgnoredItems()
        
        print("🗑️ IgnoredItemsManager: Cleared \(count) ignored groups")
    }
    
    /// Clear everything
    func clearAll() {
        clearAllIgnoredSongs()
        clearAllIgnoredGroups()
    }
    
    // MARK: - Filtering for Scan Results
    
    /// Filter songs from a group, removing ignored ones
    func filterIgnoredSongs(_ songs: [MPMediaItem]) -> [MPMediaItem] {
        return songs.filter { !shouldIgnoreSong($0.persistentID) }
    }
    
    /// Check if a group should be included after filtering ignored songs
    func shouldIncludeGroup(title: String, artist: String, songs: [MPMediaItem]) -> Bool {
        // Don't include if the entire group is ignored
        if shouldIgnoreGroup(title: title, artist: artist) {
            return false
        }
        
        // Don't include if filtering ignored songs leaves less than 2 songs
        let filteredSongs = filterIgnoredSongs(songs)
        return filteredSongs.count >= 2
    }
    
    // MARK: - Statistics
    
    var totalIgnoredItems: Int {
        return ignoredSongs.count + ignoredGroups.count
    }
    
    var hasIgnoredItems: Bool {
        return totalIgnoredItems > 0
    }
    
    /// Get ignored songs grouped by their source group (simplified for rewrite)
    func getIgnoredSongsByGroup() -> [String: [IgnoredSongDetail]] {
        let allDetails = ignoredSongDetails
        return Dictionary(grouping: allDetails) { detail in
            "\(detail.songTitle)|\(detail.artistName)"
        }
    }
}

// MARK: - Codable Support for DuplicateGroup

private struct DuplicateGroupData: Codable {
    let title: String
    let artist: String
    let songData: [SongData]
    
    struct SongData: Codable {
        let persistentID: MPMediaEntityPersistentID
        let title: String?
        let artist: String?
        let albumTitle: String?
        let playCount: Int
        let playbackDuration: TimeInterval
        let dateAdded: Date
    }
    
    init(from group: ScanViewModel.DuplicateGroup) {
        self.title = group.title
        self.artist = group.artist
        self.songData = group.songs.map { song in
            SongData(
                persistentID: song.persistentID,
                title: song.title,
                artist: song.artist,
                albumTitle: song.albumTitle,
                playCount: song.playCount,
                playbackDuration: song.playbackDuration,
                dateAdded: song.dateAdded
            )
        }
    }
    
    func toDuplicateGroup() -> ScanViewModel.DuplicateGroup? {
        // Try to reconstruct the group from current library
        let currentSongs = songData.compactMap { data -> MPMediaItem? in
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: data.persistentID,
                forProperty: MPMediaItemPropertyPersistentID
            ))
            return query.items?.first
        }
        
        // Only return the group if we can find at least some songs
        guard !currentSongs.isEmpty else { return nil }
        
        return ScanViewModel.DuplicateGroup(
            title: title,
            artist: artist,
            songs: currentSongs
        )
    }
}
