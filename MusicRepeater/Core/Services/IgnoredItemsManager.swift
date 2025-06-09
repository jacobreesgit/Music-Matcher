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
    @Published var ignoredGroups: Set<String> = [] // Format: "title|artist"
    
    // Detailed tracking for settings UI - now using DuplicateGroup structure
    @Published var ignoredSongDetails: [IgnoredSongDetail] = []
    @Published var ignoredDuplicateGroups: [ScanViewModel.DuplicateGroup] = []
    
    struct IgnoredSongDetail: Identifiable, Codable {
        let id = UUID()
        let songId: MPMediaEntityPersistentID
        let songTitle: String
        let artistName: String
        let albumTitle: String
        let groupKey: String // "title|artist" to identify which group it came from
        let ignoredDate: Date
        
        enum CodingKeys: String, CodingKey {
            case songId, songTitle, artistName, albumTitle, groupKey, ignoredDate
        }
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
        
        // Load ignored group keys
        if let groupData = userDefaults.data(forKey: Keys.ignoredGroups),
           let groupKeys = try? JSONDecoder().decode([String].self, from: groupData) {
            ignoredGroups = Set(groupKeys)
        }
        
        // Load detailed information
        loadIgnoredSongDetails()
        loadIgnoredDuplicateGroups()
        
        print("📋 IgnoredItemsManager: Loaded \(ignoredSongs.count) ignored songs and \(ignoredGroups.count) ignored groups")
    }
    
    private func saveIgnoredItems() {
        // Save ignored song IDs
        if let songData = try? JSONEncoder().encode(Array(ignoredSongs)) {
            userDefaults.set(songData, forKey: Keys.ignoredSongs)
        }
        
        // Save ignored group keys
        if let groupData = try? JSONEncoder().encode(Array(ignoredGroups)) {
            userDefaults.set(groupData, forKey: Keys.ignoredGroups)
        }
        
        // Save detailed information
        saveIgnoredSongDetails()
        saveIgnoredDuplicateGroups()
        
        print("💾 IgnoredItemsManager: Saved \(ignoredSongs.count) ignored songs and \(ignoredGroups.count) ignored groups")
    }
    
    private func loadIgnoredSongDetails() {
        if let data = userDefaults.data(forKey: "ignoredSongDetails"),
           let details = try? JSONDecoder().decode([IgnoredSongDetail].self, from: data) {
            ignoredSongDetails = details
        }
    }
    
    private func saveIgnoredSongDetails() {
        if let data = try? JSONEncoder().encode(ignoredSongDetails) {
            userDefaults.set(data, forKey: "ignoredSongDetails")
        }
    }
    
    private func loadIgnoredDuplicateGroups() {
        if let data = userDefaults.data(forKey: "ignoredDuplicateGroups"),
           let groups = try? JSONDecoder().decode([DuplicateGroupData].self, from: data) {
            ignoredDuplicateGroups = groups.map { $0.toDuplicateGroup() }
        }
    }
    
    private func saveIgnoredDuplicateGroups() {
        let groupData = ignoredDuplicateGroups.map { DuplicateGroupData(from: $0) }
        if let data = try? JSONEncoder().encode(groupData) {
            userDefaults.set(data, forKey: "ignoredDuplicateGroups")
        }
    }
    
    // MARK: - Public Interface
    
    /// Check if a song should be ignored
    func shouldIgnoreSong(_ songId: MPMediaEntityPersistentID) -> Bool {
        return ignoredSongs.contains(songId)
    }
    
    /// Check if a group should be ignored
    func shouldIgnoreGroup(title: String, artist: String) -> Bool {
        let groupKey = createGroupKey(title: title, artist: artist)
        return ignoredGroups.contains(groupKey)
    }
    
    /// Ignore a specific song from a group
    func ignoreSong(_ song: MPMediaItem, fromGroupTitle title: String, artist: String) {
        let songId = song.persistentID
        ignoredSongs.insert(songId)
        
        // Add detailed information
        let detail = IgnoredSongDetail(
            songId: songId,
            songTitle: song.title ?? "Unknown",
            artistName: song.artist ?? "Unknown",
            albumTitle: song.albumTitle ?? "Unknown",
            groupKey: createGroupKey(title: title, artist: artist),
            ignoredDate: Date()
        )
        ignoredSongDetails.append(detail)
        
        saveIgnoredItems()
        
        print("🚫 IgnoredItemsManager: Ignored song '\(detail.songTitle)' from album '\(detail.albumTitle)'")
    }
    
    /// Ignore an entire group - now stores as DuplicateGroup
    func ignoreGroup(_ group: ScanViewModel.DuplicateGroup) {
        let groupKey = createGroupKey(title: group.title, artist: group.artist)
        ignoredGroups.insert(groupKey)
        
        // Store the entire group structure
        ignoredDuplicateGroups.append(group)
        
        saveIgnoredItems()
        
        print("🚫 IgnoredItemsManager: Ignored group '\(group.title)' by \(group.artist) (\(group.songs.count) songs)")
    }
    
    /// Ignore an entire group (legacy method for backward compatibility)
    func ignoreGroup(title: String, artist: String, songCount: Int) {
        let groupKey = createGroupKey(title: title, artist: artist)
        ignoredGroups.insert(groupKey)
        
        // Create a minimal DuplicateGroup for storage
        let group = ScanViewModel.DuplicateGroup(
            title: title,
            artist: artist,
            songs: [] // Empty songs array for legacy groups
        )
        ignoredDuplicateGroups.append(group)
        
        saveIgnoredItems()
        
        print("🚫 IgnoredItemsManager: Ignored group '\(title)' by \(artist) (\(songCount) songs)")
    }
    
    /// Restore a specific ignored song
    func restoreSong(_ songId: MPMediaEntityPersistentID) {
        ignoredSongs.remove(songId)
        ignoredSongDetails.removeAll { $0.songId == songId }
        saveIgnoredItems()
        
        print("✅ IgnoredItemsManager: Restored song with ID \(songId)")
    }
    
    /// Restore an entire ignored group
    func restoreGroup(_ groupKey: String) {
        ignoredGroups.remove(groupKey)
        ignoredDuplicateGroups.removeAll { createGroupKey(title: $0.title, artist: $0.artist) == groupKey }
        saveIgnoredItems()
        
        print("✅ IgnoredItemsManager: Restored group '\(groupKey)'")
    }
    
    /// Restore a group by DuplicateGroup
    func restoreGroup(_ group: ScanViewModel.DuplicateGroup) {
        let groupKey = createGroupKey(title: group.title, artist: group.artist)
        restoreGroup(groupKey)
    }
    
    /// Clear all ignored songs
    func clearAllIgnoredSongs() {
        let count = ignoredSongs.count
        ignoredSongs.removeAll()
        ignoredSongDetails.removeAll()
        saveIgnoredItems()
        
        print("🗑️ IgnoredItemsManager: Cleared \(count) ignored songs")
    }
    
    /// Clear all ignored groups
    func clearAllIgnoredGroups() {
        let count = ignoredGroups.count
        ignoredGroups.removeAll()
        ignoredDuplicateGroups.removeAll()
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
    
    // MARK: - Helper Methods
    
    private func createGroupKey(title: String, artist: String) -> String {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return "\(cleanTitle)|\(cleanArtist)"
    }
    
    // MARK: - Statistics
    
    var totalIgnoredItems: Int {
        return ignoredSongs.count + ignoredGroups.count
    }
    
    var hasIgnoredItems: Bool {
        return totalIgnoredItems > 0
    }
    
    /// Get ignored songs grouped by their original group
    func getIgnoredSongsByGroup() -> [String: [IgnoredSongDetail]] {
        return Dictionary(grouping: ignoredSongDetails) { $0.groupKey }
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
    
    func toDuplicateGroup() -> ScanViewModel.DuplicateGroup {
        // Note: We can't reconstruct actual MPMediaItems, so we'll need to create
        // a special version that works with stored data
        let songs = songData.compactMap { data -> MPMediaItem? in
            // Try to find the song in the current library by persistent ID
            let query = MPMediaQuery.songs()
            query.addFilterPredicate(MPMediaPropertyPredicate(
                value: data.persistentID,
                forProperty: MPMediaItemPropertyPersistentID
            ))
            return query.items?.first
        }
        
        return ScanViewModel.DuplicateGroup(
            title: title,
            artist: artist,
            songs: songs
        )
    }
}
