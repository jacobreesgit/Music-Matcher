import Foundation
import MediaPlayer
import Combine

class MusicRepeaterViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var singleTrack: MPMediaItem? = nil
    @Published var albumTrack: MPMediaItem? = nil
    @Published var singleTrackName: String = ""
    @Published var albumTrackName: String = ""
    @Published var singlePlayCount: Int = 0
    @Published var albumPlayCount: Int = 0
    @Published var isProcessing: Bool = false
    @Published var currentIteration: Int = 0
    @Published var totalIterations: Int = 0
    @Published var alertMessage: String = ""
    @Published var isPlaying: Bool = false
    @Published var showingProcessingView: Bool = false
    
    private let playerManager = MusicPlayerManager()
    private var cancellables = Set<AnyCancellable>()
    private var targetPlayCount: Int = 0
    private var isMatchingMode: Bool = false
    
    var canMatchPlayCount: Bool {
        return singleTrack != nil && albumTrack != nil && !isProcessing
    }
    
    var isSameSong: Bool {
        guard let singleTrack = singleTrack,
              let albumTrack = albumTrack else {
            return false
        }
        
        // Check if it's the same song by comparing persistent ID
        return singleTrack.persistentID == albumTrack.persistentID
    }
    
    var canPerformActions: Bool {
        return canMatchPlayCount && !isSameSong
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for player progress updates
        playerManager.$currentIteration
            .assign(to: &$currentIteration)
        
        playerManager.$isProcessing
            .sink { [weak self] processing in
                self?.isProcessing = processing
                if !processing {
                    self?.showingProcessingView = false
                    self?.isPlaying = false
                }
            }
            .store(in: &cancellables)
        
        playerManager.$isPlaying
            .assign(to: &$isPlaying)
        
        // Listen for completion
        playerManager.$completionMessage
            .sink { [weak self] message in
                if !message.isEmpty {
                    self?.alertMessage = message
                    self?.updateAlbumPlayCount()
                }
            }
            .store(in: &cancellables)
    }
    
    func selectSingleTrack(_ item: MPMediaItem) {
        singleTrack = item
        singleTrackName = item.title ?? "Unknown Track"
        if let artist = item.artist {
            singleTrackName += " - \(artist)"
        }
        singlePlayCount = item.playCount
    }
    
    func selectAlbumTrack(_ item: MPMediaItem) {
        albumTrack = item
        albumTrackName = item.title ?? "Unknown Track"
        if let artist = item.artist {
            albumTrackName += " - \(artist)"
        }
        albumPlayCount = item.playCount
    }
    
    func getTargetPlayCount() -> Int {
        return targetPlayCount
    }
    
    func startMatching() {
        guard let singleTrack = singleTrack,
              let albumTrack = albumTrack else {
            return
        }
        
        if isSameSong {
            alertMessage = "You've selected the same song for both versions. Please choose different versions of the song."
            return
        }
        
        let singlePlays = singleTrack.playCount
        let albumPlays = albumTrack.playCount
        
        // Calculate how many times we need to play to match
        let timesToPlay = max(singlePlays - albumPlays, 0)
        
        if timesToPlay == 0 {
            alertMessage = "The album version already has as many (or more) plays than the single version. No additional plays are needed."
            return
        }
        
        isMatchingMode = true
        totalIterations = timesToPlay
        targetPlayCount = singlePlays
        currentIteration = 0
        showingProcessingView = true
        
        // Start the fast-forwarded playback process
        playerManager.startFastForwardPlayback(
            track: albumTrack,
            times: timesToPlay,
            targetTotalPlays: singlePlays
        )
    }
    
    func startAdding() {
        guard let singleTrack = singleTrack,
              let albumTrack = albumTrack else {
            return
        }
        
        if isSameSong {
            alertMessage = "You've selected the same song for both versions. Please choose different versions of the song."
            return
        }
        
        let singlePlays = singleTrack.playCount
        let albumPlays = albumTrack.playCount
        
        // Add the single play count to the album play count
        let timesToPlay = singlePlays
        let targetTotalPlays = albumPlays + singlePlays
        
        if timesToPlay == 0 {
            alertMessage = "The single version has 0 plays, so no additional plays will be added."
            return
        }
        
        isMatchingMode = false
        totalIterations = timesToPlay
        targetPlayCount = targetTotalPlays
        currentIteration = 0
        showingProcessingView = true
        
        // Start the fast-forwarded playback process
        playerManager.startFastForwardPlayback(
            track: albumTrack,
            times: timesToPlay,
            targetTotalPlays: targetTotalPlays
        )
    }
    
    func togglePlayback() {
        playerManager.togglePlayback()
    }
    
    func stopProcessing() {
        playerManager.stopProcessing()
        showingProcessingView = false
        
        // Update the album play count to reflect the actual iterations completed
        updateAlbumPlayCount()
        
        // Set a message to inform the user
        if currentIteration > 0 {
            alertMessage = "Processing stopped. \(currentIteration) plays were added to the album version."
        } else {
            alertMessage = "Processing stopped. No plays were added."
        }
    }
    
    private func updateAlbumPlayCount() {
        // Re-read the album track's play count after completion
        if let albumTrack = albumTrack {
            // Note: In a real scenario, you might need to re-query the media item
            // to get the updated play count, as the MPMediaItem might be cached
            // Use currentIteration instead of totalIterations to reflect actual plays completed
            albumPlayCount = albumTrack.playCount + currentIteration
        }
    }
}
