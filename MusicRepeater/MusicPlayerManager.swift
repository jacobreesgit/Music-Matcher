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
    private var playbackTimer: Timer?
    private let settingsManager = SettingsManager.shared
    
    init() {
        // Initialize with default player, will be updated when playback starts
        self.musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    }
    
    private func updateMusicPlayer() {
        // Choose player type based on settings
        if settingsManager.useSystemMusicPlayer {
            musicPlayer = MPMusicPlayerController.systemMusicPlayer
        } else {
            musicPlayer = MPMusicPlayerController.applicationMusicPlayer
        }
    }
    
    deinit {
        removeObservers()
        playbackTimer?.invalidate()
    }
    
    func startFastForwardPlayback(track: MPMediaItem, times: Int, targetTotalPlays: Int) {
        self.currentTrack = track
        self.totalIterations = times
        self.targetTotalPlays = targetTotalPlays
        self.currentIteration = 0
        self.isProcessing = true
        self.completionMessage = ""
        
        // Update music player type based on current settings
        updateMusicPlayer()
        
        // Set up observers once at the beginning
        addObservers()
        
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
        guard duration > 0 else {
            handleError("Invalid track duration")
            return
        }
        
        // Use fixed play duration of 32 seconds
        let playDuration: TimeInterval = 32.0
        
        // Calculate seek time - play for the specified duration from the end
        let seekTime = max(duration - playDuration, duration * 0.8)
        
        // Set up the queue with only this track
        let collection = MPMediaItemCollection(items: [track])
        musicPlayer.setQueue(with: collection)
        
        // Prepare and play
        musicPlayer.prepareToPlay { [weak self] error in
            if let error = error {
                self?.handleError("Failed to prepare track for playback")
                return
            }
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Seek to near the end
                self.musicPlayer.currentPlaybackTime = seekTime
                
                // Start playback
                self.musicPlayer.play()
                
                // Set up a backup timer using fixed duration
                self.playbackTimer?.invalidate()
                self.playbackTimer = Timer.scheduledTimer(withTimeInterval: playDuration, repeats: false) { _ in
                    self.moveToNextIteration()
                }
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
        
        // Begin generating notifications
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    private func removeObservers() {
        if let observer = playbackStateObserver {
            NotificationCenter.default.removeObserver(observer)
            playbackStateObserver = nil
        }
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    private func handlePlaybackStateChange() {
        let state = musicPlayer.playbackState
        
        switch state {
        case .stopped:
            moveToNextIteration()
        case .paused:
            // Sometimes tracks end with paused state
            if let track = currentTrack {
                let currentTime = musicPlayer.currentPlaybackTime
                let duration = track.playbackDuration
                // If we're very close to the end, treat as finished
                if currentTime >= duration - 2.0 {
                    moveToNextIteration()
                }
            }
        case .playing:
            break
        default:
            break
        }
    }
    
    private func moveToNextIteration() {
        // Prevent multiple calls
        guard isProcessing && currentIteration < totalIterations else {
            return
        }
        
        // Stop current playback
        musicPlayer.stop()
        
        // Invalidate timer
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Increment iteration count
        currentIteration += 1
        
        // Check if we're done
        if currentIteration >= totalIterations {
            completeProcess()
        } else {
            // Use fixed delay of 1 second before next iteration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.playNextIteration()
            }
        }
    }
    
    private func completeProcess() {
        // Stop any playback
        musicPlayer.stop()
        
        // Clean up
        removeObservers()
        playbackTimer?.invalidate()
        playbackTimer = nil
        isProcessing = false
        
        // Set completion message
        if let trackName = currentTrack?.title {
            completionMessage = "Done! '\(trackName)' has now been played a total of \(targetTotalPlays) times."
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
        playbackTimer?.invalidate()
        playbackTimer = nil
        isProcessing = false
        completionMessage = message
        musicPlayer.stop()
    }
}
