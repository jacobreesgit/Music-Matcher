import SwiftUI

struct ProcessingView: View {
    @ObservedObject var viewModel: MusicRepeaterViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Track Info Section
                VStack(spacing: AppSpacing.medium) {
                    Text("Processing")
                        .font(AppFont.largeTitle)
                        .foregroundColor(Color.designTextPrimary)
                    
                    Text(viewModel.targetTrackName)
                        .font(AppFont.title2)
                        .foregroundColor(Color.designTextPrimary)
                        .multilineTextAlignment(.center)
                        .appPadding(.horizontal)
                    
                    Text("Building up play count...")
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextSecondary)
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
                
                // Progress Details
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
}

#if DEBUG
struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model for preview
        let viewModel = MusicRepeaterViewModel()
        // Set some mock data
        // viewModel.targetTrackName = "Sample Song - Artist Name"
        // viewModel.currentIteration = 5
        // viewModel.totalIterations = 20
        // viewModel.targetPlayCount = 10
        
        return Group {
            ProcessingView(viewModel: viewModel)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ProcessingView(viewModel: viewModel)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
#endif
