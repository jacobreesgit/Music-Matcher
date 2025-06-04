import Foundation
import MediaPlayer
import Combine

class MusicPlayerManager: ObservableObject {
    @Published var currentIteration: Int = 0
    @Published var isProcessing: Bool = false
    @Published var isPlaying: Bool = false
    @Published var completionMessage: String = ""
    
    private var musicPlayer: MPMusicPlayerController
    private var totalIterations: Int = 0
    private var currentTrack: MPMediaItem?
    private var targetTotalPlays: Int = 0
    private var playbackStateObserver: Any?
    private var playbackTimer: Timer?
    private let settingsManager = SettingsManager.shared
    
    // State management for pause/resume
    private var isPaused: Bool = false
    private var currentSeekTime: TimeInterval = 0
    private var playDuration: TimeInterval = 32.0
    private var iterationStartTime: Date?
    
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
        self.isPaused = false
        self.completionMessage = ""
        
        // Update music player type based on current settings
        updateMusicPlayer()
        
        // Set up observers once at the beginning
        addObservers()
        
        // Start the first iteration
        playNextIteration()
    }
    
    func togglePlayback() {
        if isPaused {
            resumePlayback()
        } else {
            pausePlayback()
        }
    }
    
    func pausePlayback() {
        guard isProcessing && !isPaused else { return }
        
        isPaused = true
        isPlaying = false
        musicPlayer.pause()
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func resumePlayback() {
        guard isProcessing && isPaused else { return }
        
        isPaused = false
        isPlaying = true
        musicPlayer.play()
        
        // Calculate remaining time for this iteration
        let elapsed = iterationStartTime?.timeIntervalSinceNow ?? 0
        let remainingTime = max(playDuration + elapsed, 1.0)
        
        // Reset timer with remaining time
        playbackTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { _ in
            self.moveToNextIteration()
        }
    }
    
    func stopProcessing() {
        // Stop current playback
        musicPlayer.stop()
        
        // Clean up
        removeObservers()
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Reset state
        isProcessing = false
        isPlaying = false
        isPaused = false
        currentTrack = nil
        totalIterations = 0
        currentIteration = 0
        targetTotalPlays = 0
        
        completionMessage = "Processing stopped by user."
    }
    
    private func playNextIteration() {
        guard let track = currentTrack,
              currentIteration < totalIterations,
              isProcessing && !isPaused else {
            if currentIteration >= totalIterations {
                completeProcess()
            }
            return
        }
        
        // Get track duration
        let duration = track.playbackDuration
        guard duration > 0 else {
            handleError("Invalid track duration")
            return
        }
        
        // Calculate seek time - play for the specified duration from the end
        let seekTime = max(duration - playDuration, duration * 0.8)
        currentSeekTime = seekTime
        
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
                guard let self = self, self.isProcessing && !self.isPaused else { return }
                
                // Seek to near the end
                self.musicPlayer.currentPlaybackTime = seekTime
                
                // Start playback
                self.musicPlayer.play()
                self.isPlaying = true
                self.iterationStartTime = Date()
                
                // Set up a backup timer using fixed duration
                self.playbackTimer?.invalidate()
                self.playbackTimer = Timer.scheduledTimer(withTimeInterval: self.playDuration, repeats: false) { _ in
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
            if !isPaused {
                moveToNextIteration()
            }
        case .paused:
            if !isPaused {
                // Sometimes tracks end with paused state
                if let track = currentTrack {
                    let currentTime = musicPlayer.currentPlaybackTime
                    let duration = track.playbackDuration
                    // If we're very close to the end, treat as finished
                    if currentTime >= duration - 2.0 {
                        moveToNextIteration()
                    }
                }
            }
        case .playing:
            if !isPaused {
                isPlaying = true
            }
        default:
            break
        }
    }
    
    private func moveToNextIteration() {
        // Prevent multiple calls
        guard isProcessing && currentIteration < totalIterations && !isPaused else {
            return
        }
        
        // Stop current playback
        musicPlayer.stop()
        isPlaying = false
        
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
                guard let self = self, !self.isPaused else { return }
                self.playNextIteration()
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
        isPlaying = false
        isPaused = false
        
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
        targetTotalPlays = 0
    }
    
    private func handleError(_ message: String) {
        removeObservers()
        playbackTimer?.invalidate()
        playbackTimer = nil
        isProcessing = false
        isPlaying = false
        isPaused = false
        completionMessage = message
        musicPlayer.stop()
    }
}
