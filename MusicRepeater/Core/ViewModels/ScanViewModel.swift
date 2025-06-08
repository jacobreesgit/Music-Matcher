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
    
    struct DuplicateGroup: Identifiable {
        let id = UUID()
        let title: String
        let artist: String
        let songs: [MPMediaItem]
        
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
            
            // Create key from title and artist (case insensitive, trimmed)
            let title = song.title?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            let artist = song.artist?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            
            // Skip songs without proper title or artist
            guard !title.isEmpty && !artist.isEmpty else { continue }
            
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
            
            // Use original casing from first song for display
            let firstSong = songs.first!
            return DuplicateGroup(
                title: firstSong.title ?? "Unknown",
                artist: firstSong.artist ?? "Unknown",
                songs: songs.sorted { $0.playCount > $1.playCount } // Sort by play count descending
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
            print("✅ ScanViewModel: Scan completed!")
            print("📊 ScanViewModel: Found \(sortedDuplicates.count) duplicate groups containing \(totalDuplicateSongs) total songs out of \(allSongs.count) scanned")
            
            if sortedDuplicates.isEmpty {
                print("🎉 ScanViewModel: No duplicates found - library is clean!")
            } else {
                print("🎵 ScanViewModel: Top duplicate groups:")
                for (index, group) in sortedDuplicates.prefix(3).enumerated() {
                    let playCountDiff = group.maxPlayCount - group.minPlayCount
                    print("   \(index + 1). \"\(group.title)\" by \(group.artist) - \(group.songs.count) versions (play count range: \(group.minPlayCount)-\(group.maxPlayCount), diff: \(playCountDiff))")
                }
            }
        }
    }
    
    func clearResults() {
        duplicateGroups = []
        scanComplete = false
        totalSongsScanned = 0
        duplicatesFound = 0
        scanProgress = 0.0
    }
}
