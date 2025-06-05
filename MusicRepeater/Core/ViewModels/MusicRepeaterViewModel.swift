import Foundation
import MediaPlayer
import Combine

class MusicRepeaterViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var sourceTrack: MPMediaItem? = nil
    @Published var targetTrack: MPMediaItem? = nil
    @Published var sourceTrackName: String = ""
    @Published var targetTrackName: String = ""
    @Published var sourcePlayCount: Int = 0
    @Published var targetPlayCount: Int = 0
    @Published var isProcessing: Bool = false
    @Published var currentIteration: Int = 0
    @Published var totalIterations: Int = 0
    @Published var alertMessage: String = ""
    @Published var isPlaying: Bool = false
    @Published var showingProcessingView: Bool = false
    
    private let playerManager = MusicPlayerManager()
    private var cancellables = Set<AnyCancellable>()
    private var targetPlayCountGoal: Int = 0
    private var isMatchingMode: Bool = false
    
    var canMatchPlayCount: Bool {
        return sourceTrack != nil && targetTrack != nil && !isProcessing
    }
    
    var isSameSong: Bool {
        guard let sourceTrack = sourceTrack,
              let targetTrack = targetTrack else {
            return false
        }
        
        // Check if it's the same song by comparing persistent ID
        return sourceTrack.persistentID == targetTrack.persistentID
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
                    self?.updateTargetPlayCount()
                }
            }
            .store(in: &cancellables)
    }
    
    func selectSourceTrack(_ item: MPMediaItem) {
        sourceTrack = item
        sourceTrackName = item.title ?? "Unknown Track"
        if let artist = item.artist {
            sourceTrackName += " - \(artist)"
        }
        sourcePlayCount = item.playCount
    }
    
    func selectTargetTrack(_ item: MPMediaItem) {
        targetTrack = item
        targetTrackName = item.title ?? "Unknown Track"
        if let artist = item.artist {
            targetTrackName += " - \(artist)"
        }
        targetPlayCount = item.playCount
    }
    
    func getTargetPlayCount() -> Int {
        return targetPlayCountGoal
    }
    
    func startMatching() {
        guard let sourceTrack = sourceTrack,
              let targetTrack = targetTrack else {
            return
        }
        
        if isSameSong {
            alertMessage = "You've selected the same song for both source and target. Please choose different versions of the song."
            return
        }
        
        let sourcePlays = sourceTrack.playCount
        let targetPlays = targetTrack.playCount
        
        // Calculate how many times we need to play to match
        let timesToPlay = max(sourcePlays - targetPlays, 0)
        
        if timesToPlay == 0 {
            alertMessage = "The target track already has as many (or more) plays than the source track. No additional plays are needed."
            return
        }
        
        isMatchingMode = true
        totalIterations = timesToPlay
        targetPlayCountGoal = sourcePlays
        currentIteration = 0
        showingProcessingView = true
        
        // Start the fast-forwarded playback process
        playerManager.startFastForwardPlayback(
            track: targetTrack,
            times: timesToPlay,
            targetTotalPlays: sourcePlays
        )
    }
    
    func startAdding() {
        guard let sourceTrack = sourceTrack,
              let targetTrack = targetTrack else {
            return
        }
        
        if isSameSong {
            alertMessage = "You've selected the same song for both source and target. Please choose different versions of the song."
            return
        }
        
        let sourcePlays = sourceTrack.playCount
        let targetPlays = targetTrack.playCount
        
        // Add the source play count to the target play count
        let timesToPlay = sourcePlays
        let targetTotalPlays = targetPlays + sourcePlays
        
        if timesToPlay == 0 {
            alertMessage = "The source track has 0 plays, so no additional plays will be added."
            return
        }
        
        isMatchingMode = false
        totalIterations = timesToPlay
        targetPlayCountGoal = targetTotalPlays
        currentIteration = 0
        showingProcessingView = true
        
        // Start the fast-forwarded playback process
        playerManager.startFastForwardPlayback(
            track: targetTrack,
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
        
        // Update the target play count to reflect the actual iterations completed
        updateTargetPlayCount()
        
        // Set a message to inform the user
        if currentIteration > 0 {
            alertMessage = "Processing stopped. \(currentIteration) plays were added to the target track."
        } else {
            alertMessage = "Processing stopped. No plays were added."
        }
    }
    
    private func updateTargetPlayCount() {
        // Re-read the target track's play count after completion
        if let targetTrack = targetTrack {
            // Note: In a real scenario, you might need to re-query the media item
            // to get the updated play count, as the MPMediaItem might be cached
            // Use currentIteration instead of totalIterations to reflect actual plays completed
            targetPlayCount = targetTrack.playCount + currentIteration
        }
    }
}
