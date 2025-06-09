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
    
    // Detailed tracking for settings UI
    @Published var ignoredSongDetails: [IgnoredSongDetail] = []
    @Published var ignoredGroupDetails: [IgnoredGroupDetail] = []
    
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
    
    struct IgnoredGroupDetail: Identifiable, Codable {
        let id = UUID()
        let groupKey: String // "title|artist"
        let songTitle: String
        let artistName: String
        let songCount: Int
        let ignoredDate: Date
        
        enum CodingKeys: String, CodingKey {
            case groupKey, songTitle, artistName, songCount, ignoredDate
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
        loadIgnoredGroupDetails()
        
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
        saveIgnoredGroupDetails()
        
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
    
    private func loadIgnoredGroupDetails() {
        if let data = userDefaults.data(forKey: "ignoredGroupDetails"),
           let details = try? JSONDecoder().decode([IgnoredGroupDetail].self, from: data) {
            ignoredGroupDetails = details
        }
    }
    
    private func saveIgnoredGroupDetails() {
        if let data = try? JSONEncoder().encode(ignoredGroupDetails) {
            userDefaults.set(data, forKey: "ignoredGroupDetails")
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
    
    /// Ignore an entire group
    func ignoreGroup(title: String, artist: String, songCount: Int) {
        let groupKey = createGroupKey(title: title, artist: artist)
        ignoredGroups.insert(groupKey)
        
        // Add detailed information
        let detail = IgnoredGroupDetail(
            groupKey: groupKey,
            songTitle: title,
            artistName: artist,
            songCount: songCount,
            ignoredDate: Date()
        )
        ignoredGroupDetails.append(detail)
        
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
        ignoredGroupDetails.removeAll { $0.groupKey == groupKey }
        saveIgnoredItems()
        
        print("✅ IgnoredItemsManager: Restored group '\(groupKey)'")
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
        ignoredGroupDetails.removeAll()
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
