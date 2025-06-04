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
    
    private let playerManager = MusicPlayerManager()
    private var cancellables = Set<AnyCancellable>()
    
    var canMatchPlayCount: Bool {
        return singleTrack != nil && albumTrack != nil && !isProcessing
    }
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for player progress updates
        playerManager.$currentIteration
            .assign(to: &$currentIteration)
        
        playerManager.$isProcessing
            .assign(to: &$isProcessing)
        
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
    
    func startMatching() {
        guard let singleTrack = singleTrack,
              let albumTrack = albumTrack else {
            return
        }
        
        let singlePlays = singleTrack.playCount
        let albumPlays = albumTrack.playCount
        
        // Calculate how many times we need to play
        let timesToPlay = max(singlePlays - albumPlays, 0)
        
        if timesToPlay == 0 {
            alertMessage = "The album version already has as many (or more) plays than the single version. No additional fast-forwarded plays are needed."
            return
        }
        
        totalIterations = timesToPlay
        currentIteration = 0
        
        // Start the fast-forwarded playback process
        playerManager.startFastForwardPlayback(
            track: albumTrack,
            times: timesToPlay,
            targetTotalPlays: singlePlays
        )
    }
    
    private func updateAlbumPlayCount() {
        // Re-read the album track's play count after completion
        if let albumTrack = albumTrack {
            // Note: In a real scenario, you might need to re-query the media item
            // to get the updated play count, as the MPMediaItem might be cached
            albumPlayCount = albumTrack.playCount + totalIterations
        }
    }
}
