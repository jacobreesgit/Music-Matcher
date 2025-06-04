import Foundation
import MediaPlayer
import Combine

class MusicPlayerManager: ObservableObject {
    @Published var currentIteration: Int = 0
    @Published var isProcessing: Bool = false
    @Published var completionMessage: String = ""
    
    private var musicPlayer: MPMusicPlayerController
    private var totalIterations: Int = 0
    private var currentTrack: MPMediaItem?
    private var targetTotalPlays: Int = 0
    private var playbackStateObserver: Any?
    private var nowPlayingObserver: Any?
    
    init() {
        // Use applicationMusicPlayer to avoid interfering with system music
        self.musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    }
    
    deinit {
        removeObservers()
    }
    
    func startFastForwardPlayback(track: MPMediaItem, times: Int, targetTotalPlays: Int) {
        self.currentTrack = track
        self.totalIterations = times
        self.targetTotalPlays = targetTotalPlays
        self.currentIteration = 0
        self.isProcessing = true
        self.completionMessage = ""
        
        // Start the first iteration
        playNextIteration()
    }
    
    private func playNextIteration() {
        guard let track = currentTrack,
              currentIteration < totalIterations else {
            // All iterations complete
            completeProcess()
            return
        }
        
        // Get track duration
        let duration = track.playbackDuration
        
        // Calculate seek time (5 seconds before end, or 30 seconds to be safer)
        // Using 30 seconds to ensure iOS counts it as a full play
        let seekTime = max(duration - 30, duration * 0.85) // At least 85% through
        
        // Set up the queue with only this track
        let collection = MPMediaItemCollection(items: [track])
        musicPlayer.setQueue(with: collection)
        
        // Add observers for this playback iteration
        addObservers()
        
        // Prepare and play
        musicPlayer.prepareToPlay { [weak self] error in
            if let error = error {
                print("Error preparing to play: \(error)")
                self?.handleError("Failed to prepare track for playback")
                return
            }
            
            DispatchQueue.main.async {
                // Seek to near the end
                self?.musicPlayer.currentPlaybackTime = seekTime
                
                // Start playback
                self?.musicPlayer.play()
            }
        }
    }
    
    private func addObservers() {
        // Remove any existing observers first
        removeObservers()
        
        // Observe playback state changes
        playbackStateObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: musicPlayer,
            queue: .main
        ) { [weak self] _ in
            self?.handlePlaybackStateChange()
        }
        
        // Observe now playing item changes (as backup)
        nowPlayingObserver = NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: musicPlayer,
            queue: .main
        ) { [weak self] _ in
            self?.handleNowPlayingChange()
        }
        
        // Begin generating notifications
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func removeObservers() {
        if let observer = playbackStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = nowPlayingObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    private func handlePlaybackStateChange() {
        if musicPlayer.playbackState == .stopped ||
           musicPlayer.playbackState == .paused {
            // Track finished or was paused
            if musicPlayer.playbackState == .stopped {
                // Increment iteration count
                currentIteration += 1
                
                // Remove observers for this iteration
                removeObservers()
                
                // Small delay before next iteration to ensure system registers the play
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.playNextIteration()
                }
            }
        }
    }
    
    private func handleNowPlayingChange() {
        // This is a backup in case playback state doesn't trigger properly
        if musicPlayer.nowPlayingItem == nil && isProcessing {
            // Track ended
            currentIteration += 1
            removeObservers()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.playNextIteration()
            }
        }
    }
    
    private func completeProcess() {
        // Stop any playback
        musicPlayer.stop()
        
        // Clean up
        removeObservers()
        isProcessing = false
        
        // Set completion message
        if let trackName = currentTrack?.title {
            completionMessage = "Done! '\(trackName)' has now been played a total of \(targetTotalPlays) times to match the single-version count."
        } else {
            completionMessage = "Done! The album version has been played \(totalIterations) times."
        }
        
        // Reset state
        currentTrack = nil
        totalIterations = 0
        currentIteration = 0
    }
    
    private func handleError(_ message: String) {
        removeObservers()
        isProcessing = false
        completionMessage = message
        musicPlayer.stop()
    }
}
