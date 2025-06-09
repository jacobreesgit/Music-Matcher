import Foundation
import MediaPlayer
import Combine

class ScanViewModel: ObservableObject {
    @Published var isScanning: Bool = false
    @Published var scanProgress: Double = 0.0
    @Published var duplicateGroups: [DuplicateGroup] = []
    @Published var scanComplete: Bool = false
    @Published var totalSongsScanned: Int = 0
    @Published var duplicatesFound: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let ignoredItemsManager = IgnoredItemsManager.shared
    
    struct DuplicateGroup: Identifiable, Codable {
        let id: UUID
        let title: String
        let artist: String
        var songs: [MPMediaItem]
        
        // Codable implementation
        enum CodingKeys: String, CodingKey {
            case id, title, artist
        }
        
        // Custom encoder (MPMediaItem can't be encoded directly)
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(title, forKey: .title)
            try container.encode(artist, forKey: .artist)
        }
        
        // Custom decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(UUID.self, forKey: .id)
            self.title = try container.decode(String.self, forKey: .title)
            self.artist = try container.decode(String.self, forKey: .artist)
            self.songs = [] // Will be populated separately
        }
        
        // Standard initializer
        init(title: String, artist: String, songs: [MPMediaItem]) {
            self.id = UUID()
            self.title = title
            self.artist = artist
            self.songs = songs
        }
        
        // Get the song with highest play count
        var sourceCandidate: MPMediaItem? {
            songs.max { $0.playCount < $1.playCount }
        }
        
        // Get songs that could benefit from play count matching
        var targetCandidates: [MPMediaItem] {
            guard let source = sourceCandidate else { return [] }
            return songs.filter { $0.playCount < source.playCount }
        }
        
        var hasPlayCountDifferences: Bool {
            let playCounts = songs.map { $0.playCount }
            return playCounts.min() != playCounts.max()
        }
        
        var maxPlayCount: Int {
            songs.map { $0.playCount }.max() ?? 0
        }
        
        var minPlayCount: Int {
            songs.map { $0.playCount }.min() ?? 0
        }
    }
    
    func startScan() {
        guard !isScanning else {
            print("🔍 ScanViewModel: Scan already in progress, ignoring duplicate call")
            return
        }
        
        print("🔍 ScanViewModel: Starting music library scan...")
        
        isScanning = true
        scanProgress = 0.0
        duplicateGroups = []
        scanComplete = false
        totalSongsScanned = 0
        duplicatesFound = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.performScan()
        }
    }
    
    private func performScan() {
        // Get all songs from library
        let query = MPMediaQuery.songs()
        let allSongs = query.items ?? []
        
        print("🎵 ScanViewModel: Retrieved \(allSongs.count) songs from music library")
        
        DispatchQueue.main.async {
            self.totalSongsScanned = allSongs.count
        }
        
        // Group songs by title and artist combination
        var songGroups: [String: [MPMediaItem]] = [:]
        
        for (index, song) in allSongs.enumerated() {
            // Update progress (throttled by the UI component)
            let progress = Double(index) / Double(allSongs.count)
            DispatchQueue.main.async {
                self.scanProgress = progress
            }
            
            // Skip songs that are individually ignored
            if ignoredItemsManager.shouldIgnoreSong(song.persistentID) {
                continue
            }
            
            // Create key from title and artist (case insensitive, trimmed)
            let title = song.title?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let artist = song.artist?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            
            // Skip songs without proper title or artist
            guard !title.isEmpty && !artist.isEmpty else { continue }
            
            // Skip if this entire group is ignored
            if ignoredItemsManager.shouldIgnoreGroup(title: song.title ?? "", artist: song.artist ?? "") {
                continue
            }
            
            let key = "\(title)|\(artist)"
            
            if songGroups[key] == nil {
                songGroups[key] = []
            }
            songGroups[key]?.append(song)
        }
        
        // Filter for groups with multiple songs (potential duplicates)
        let duplicates = songGroups.compactMap { (key, songs) -> DuplicateGroup? in
            guard songs.count > 1 else { return nil }
            
            // Check if songs have different albums (true duplicates)
            let albums = Set(songs.compactMap { $0.albumTitle })
            guard albums.count > 1 else { return nil }
            
            // Apply ignored items filtering
            let filteredSongs = ignoredItemsManager.filterIgnoredSongs(songs)
            guard filteredSongs.count >= 2 else { return nil }
            
            // Use original casing from first song for display
            let firstSong = filteredSongs.first!
            return DuplicateGroup(
                title: firstSong.title ?? "Unknown",
                artist: firstSong.artist ?? "Unknown",
                songs: filteredSongs.sorted { $0.playCount > $1.playCount } // Sort by play count descending
            )
        }
        
        // Sort groups by potential impact (highest play count differences first)
        let sortedDuplicates = duplicates.sorted { group1, group2 in
            let impact1 = group1.maxPlayCount - group1.minPlayCount
            let impact2 = group2.maxPlayCount - group2.minPlayCount
            return impact1 > impact2
        }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.duplicateGroups = sortedDuplicates
            self.duplicatesFound = sortedDuplicates.count
            self.scanProgress = 1.0
            self.isScanning = false
            self.scanComplete = true
            
            let totalDuplicateSongs = sortedDuplicates.reduce(0) { $0 + $1.songs.count }
            let ignoredCount = self.ignoredItemsManager.totalIgnoredItems
            
            print("✅ ScanViewModel: Scan completed!")
            print("📊 ScanViewModel: Found \(sortedDuplicates.count) duplicate groups containing \(totalDuplicateSongs) total songs out of \(allSongs.count) scanned")
            
            if ignoredCount > 0 {
                print("🚫 ScanViewModel: \(ignoredCount) items were ignored from previous removals")
            }
            
            if sortedDuplicates.isEmpty {
                if ignoredCount > 0 {
                    print("🎉 ScanViewModel: No new duplicates found - remaining library is clean!")
                } else {
                    print("🎉 ScanViewModel: No duplicates found - library is clean!")
                }
            }
        }
    }
    
    // MARK: - Remove Functionality (Updated to use IgnoredItemsManager)
    
    /// Removes a specific song from a duplicate group and marks it as ignored
    /// If the group ends up with less than 2 songs, the entire group is removed from current results
    func removeSong(from groupId: UUID, songId: MPMediaEntityPersistentID) {
        guard let groupIndex = duplicateGroups.firstIndex(where: { $0.id == groupId }) else {
            print("⚠️ ScanViewModel: Could not find group with id \(groupId)")
            return
        }
        
        let group = duplicateGroups[groupIndex]
        
        // Find the song to remove
        guard let song = group.songs.first(where: { $0.persistentID == songId }) else {
            print("⚠️ ScanViewModel: Could not find song with id \(songId) in group")
            return
        }
        
        let originalSongCount = group.songs.count
        
        // Mark the song as ignored permanently
        ignoredItemsManager.ignoreSong(song, fromGroup: group)
        
        // Remove the song from the current group
        duplicateGroups[groupIndex].songs.removeAll { $0.persistentID == songId }
        
        let newSongCount = duplicateGroups[groupIndex].songs.count
        
        print("🗑️ ScanViewModel: Permanently ignored song '\(song.albumTitle ?? "Unknown")' from group '\(group.title)' (\(originalSongCount) → \(newSongCount) songs)")
        
        // If group has less than 2 songs remaining, remove it from current results
        if newSongCount < 2 {
            let removedGroup = duplicateGroups.remove(at: groupIndex)
            duplicatesFound = duplicateGroups.count
            print("📝 ScanViewModel: Removed group '\(removedGroup.title)' from current results as it now has less than 2 songs")
        }
        
        // Update duplicates count
        duplicatesFound = duplicateGroups.count
    }
    
    /// Removes an entire duplicate group and marks it as ignored
    func removeGroup(groupId: UUID) {
        guard let groupIndex = duplicateGroups.firstIndex(where: { $0.id == groupId }) else {
            print("⚠️ ScanViewModel: Could not find group with id \(groupId)")
            return
        }
        
        let group = duplicateGroups[groupIndex]
        
        // Mark the entire group as ignored permanently
        ignoredItemsManager.ignoreGroup(group)
        
        // Remove from current results
        duplicateGroups.remove(at: groupIndex)
        duplicatesFound = duplicateGroups.count
        
        print("🗑️ ScanViewModel: Permanently ignored entire group '\(group.title)' by \(group.artist) (\(group.songs.count) songs)")
    }
    
    func clearResults() {
        duplicateGroups = []
        scanComplete = false
        totalSongsScanned = 0
        duplicatesFound = 0
        scanProgress = 0.0
    }
    
    // MARK: - Ignored Items Interface
    
    var hasIgnoredItems: Bool {
        return ignoredItemsManager.hasIgnoredItems
    }
    
    var totalIgnoredItems: Int {
        return ignoredItemsManager.totalIgnoredItems
    }
}
