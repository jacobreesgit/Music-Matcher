import SwiftUI
import MediaPlayer

struct ProcessingView: View {
    @ObservedObject var viewModel: MusicRepeaterViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Track Info Section with Artwork
                VStack(spacing: AppSpacing.large) {
                    Text("Processing")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color.designTextPrimary)
                    
                    // Album Artwork (if available)
                    if let targetTrack = viewModel.targetTrack {
                        VStack(spacing: AppSpacing.medium) {
                            // Large album artwork
                            Group {
                                if let artwork = targetTrack.artwork {
                                    ArtworkView(artwork: artwork)
                                } else {
                                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                                        .fill(Color.designBackgroundTertiary)
                                        .overlay(
                                            Image(systemName: "music.note")
                                                .font(.system(size: 60))
                                                .foregroundColor(Color.designPrimary)
                                        )
                                }
                            }
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
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
                            .appPadding(.horizontal)
                        }
                    } else {
                        // Fallback if no track info
                        VStack(spacing: AppSpacing.medium) {
                            Text(viewModel.targetTrackName)
                                .font(AppFont.title2)
                                .foregroundColor(Color.designTextPrimary)
                                .multilineTextAlignment(.center)
                                .appPadding(.horizontal)
                            
                            Text("Building up play count...")
                                .font(AppFont.subheadline)
                                .foregroundColor(Color.designTextSecondary)
                        }
                    }
                }
                
                // Animated Progress Ring
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
                
                // Progress Details Card
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
                .appPadding(.horizontal)
                
                Spacer()
                
                // Playback Controls
                VStack(spacing: AppSpacing.medium) {
                    HStack(spacing: AppSpacing.xl) {
                        // Play/Pause Button
                        AppControlButton(
                            icon: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill",
                            color: Color.designPrimary,
                            size: 60
                        ) {
                            viewModel.togglePlayback()
                        }
                        
                        // Stop Button
                        AppControlButton(
                            icon: "stop.circle.fill",
                            color: Color.designError,
                            size: 60
                        ) {
                            viewModel.stopProcessing()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    // Control Labels
                    HStack(spacing: 70) {
                        Text(viewModel.isPlaying ? "Pause" : "Resume")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                        
                        Text("Stop")
                            .font(AppFont.caption)
                            .foregroundColor(Color.designTextSecondary)
                    }
                }
                
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

#if DEBUG
// Mock ViewModel for Previews
class MockMusicRepeaterViewModel: MusicRepeaterViewModel {
    
    override init() {
        super.init()
        self.targetTrackName = "Bohemian Rhapsody (Remastered) - Queen"
        self.targetPlayCount = 25
        self.isProcessing = true
        self.showingProcessingView = true
    }
    
    convenience init(scenario: ProcessingScenario) {
        self.init()
        
        switch scenario {
        case .justStarted:
            self.currentIteration = 1
            self.totalIterations = 20
            self.isPlaying = true
            
        case .midProgress:
            self.currentIteration = 8
            self.totalIterations = 20
            self.isPlaying = true
            
        case .almostComplete:
            self.currentIteration = 18
            self.totalIterations = 20
            self.isPlaying = true
            
        case .paused:
            self.currentIteration = 12
            self.totalIterations = 20
            self.isPlaying = false
            
        case .largeNumber:
            self.currentIteration = 47
            self.totalIterations = 125
            self.isPlaying = true
        }
    }
}

enum ProcessingScenario {
    case justStarted
    case midProgress
    case almostComplete
    case paused
    case largeNumber
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Just started processing
            ProcessingView(viewModel: MockMusicRepeaterViewModel(scenario: .justStarted))
                .previewDisplayName("Just Started (1/20)")
            
            // Mid progress
            ProcessingView(viewModel: MockMusicRepeaterViewModel(scenario: .midProgress))
                .previewDisplayName("Mid Progress (8/20)")
            
            // Almost complete
            ProcessingView(viewModel: MockMusicRepeaterViewModel(scenario: .almostComplete))
                .previewDisplayName("Almost Complete (18/20)")
            
            // Paused state
            ProcessingView(viewModel: MockMusicRepeaterViewModel(scenario: .paused))
                .previewDisplayName("Paused (12/20)")
            
            // Large numbers
            ProcessingView(viewModel: MockMusicRepeaterViewModel(scenario: .largeNumber))
                .previewDisplayName("Large Numbers (47/125)")
        }
    }
}
#endif
