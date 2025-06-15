import SwiftUI
import MediaPlayer

struct ProcessingView: View {
    @ObservedObject var viewModel: MusicMatcherViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Track Info Section with Artwork
                trackInfoSection
                
                // Animated Progress Ring
                progressRingSection
                
                // Progress Details Card
                progressDetailsCard
                
                Spacer()
                
                // Playback Controls
                playbackControlsSection
                
                Spacer()
            }
            .background(Color.designBackground)
            .navigationBarHidden(true)
            .onDisappear {
                // Don't stop processing when view disappears unless explicitly stopped
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Track Info Section
    private var trackInfoSection: some View {
        VStack(spacing: AppSpacing.large) {
            Text("Processing")
                .font(AppFont.largeTitle)
                .foregroundColor(Color.designTextPrimary)
            
            // Album Artwork and Track Details
            if let targetTrack = viewModel.targetTrack {
                VStack(spacing: AppSpacing.medium) {
                    // Large album artwork
                    ArtworkView(
                        artwork: targetTrack.artwork,
                        size: 160,
                        cornerRadius: AppCornerRadius.large
                    )
                    .appShadow(.medium)
                    
                    // Track Details
                    VStack(spacing: AppSpacing.small) {
                        Text(targetTrack.title ?? "Unknown Track")
                            .font(AppFont.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.designTextPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        if let artist = targetTrack.artist {
                            Text(artist)
                                .font(AppFont.headline)
                                .foregroundColor(Color.designTextSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                        }
                        
                        if let album = targetTrack.albumTitle {
                            Text(album)
                                .font(AppFont.subheadline)
                                .foregroundColor(Color.designTextTertiary)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, AppSpacing.medium)
                }
            } else {
                // Fallback if no track info
                VStack(spacing: AppSpacing.medium) {
                    Text(viewModel.targetTrackName)
                        .font(AppFont.title2)
                        .foregroundColor(Color.designTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.medium)
                    
                    Text("Building up play count...")
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
                }
            }
        }
    }
    
    // MARK: - Progress Ring Section
    private var progressRingSection: some View {
        ZStack {
            AppProgressRing(
                progress: viewModel.totalIterations > 0 ?
                    Double(viewModel.currentIteration) / Double(viewModel.totalIterations) : 0.0,
                lineWidth: 12,
                size: 200
            )
            
            VStack(spacing: AppSpacing.small) {
                Text("\(viewModel.currentIteration)")
                    .font(AppFont.counterLarge)
                    .foregroundColor(Color.designTextPrimary)
                
                Text("of \(viewModel.totalIterations)")
                    .font(AppFont.headline)
                    .foregroundColor(Color.designTextSecondary)
                
                Text("plays")
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
        }
    }
    
    // MARK: - Progress Details Card
    private var progressDetailsCard: some View {
        AppCard(padding: AppSpacing.medium) {
            VStack(spacing: AppSpacing.small) {
                AppInfoRow(
                    "Current Play Count:",
                    value: "\(viewModel.targetPlayCount + viewModel.currentIteration)"
                )
                
                AppInfoRow(
                    "Target:",
                    value: "\(viewModel.getTargetPlayCount())",
                    valueColor: Color.designPrimary
                )
                
                // Progress percentage
                let progressPercentage = viewModel.totalIterations > 0 ?
                    Int((Double(viewModel.currentIteration) / Double(viewModel.totalIterations)) * 100) : 0
                
                AppInfoRow(
                    "Progress:",
                    value: "\(progressPercentage)%",
                    valueColor: Color.designSecondary
                )
                
                // Time remaining estimate (if available)
                if viewModel.currentIteration > 0 && viewModel.isProcessing {
                    let timePerIteration: Double = 33.0 // Approximate time per iteration in seconds
                    let remainingIterations = viewModel.totalIterations - viewModel.currentIteration
                    let estimatedSecondsRemaining = Double(remainingIterations) * timePerIteration
                    
                    AppInfoRow(
                        "Est. Time Remaining:",
                        value: formatTimeRemaining(estimatedSecondsRemaining),
                        valueColor: Color.designInfo
                    )
                }
            }
        }
        .padding(.horizontal, AppSpacing.medium)
    }
    
    // MARK: - Playback Controls Section
    private var playbackControlsSection: some View {
        PlaybackControlPanel(
            isProcessing: viewModel.isProcessing,
            isPlaying: viewModel.isPlaying,
            currentIteration: viewModel.currentIteration,
            totalIterations: viewModel.totalIterations,
            onPlayPause: {
                viewModel.togglePlayback()
            },
            onStop: {
                viewModel.stopProcessing()
                presentationMode.wrappedValue.dismiss()
            }
        )
        .padding(.horizontal, AppSpacing.medium)
    }
    
    // MARK: - Helper Methods
    private func formatTimeRemaining(_ seconds: Double) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            let minutes = Int(seconds) / 60
            let remainingSeconds = Int(seconds) % 60
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            let hours = Int(seconds) / 3600
            let minutes = (Int(seconds) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }
}
