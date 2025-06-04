import SwiftUI

struct ProcessingView: View {
    @ObservedObject var viewModel: MusicRepeaterViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Track Info Section
                VStack(spacing: 15) {
                    Text("Processing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(viewModel.albumTrackName)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Building up play count...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Animated Progress Ring
                ZStack {
                    AnimatedProgressRing(
                        progress: viewModel.totalIterations > 0 ?
                            Double(viewModel.currentIteration) / Double(viewModel.totalIterations) : 0.0,
                        lineWidth: 12,
                        ringColor: Color.blue.opacity(0.3),
                        progressColor: Color.blue
                    )
                    .frame(width: 200, height: 200)
                    
                    VStack(spacing: 8) {
                        Text("\(viewModel.currentIteration)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("of \(viewModel.totalIterations)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("plays")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress Details
                VStack(spacing: 8) {
                    HStack {
                        Text("Current Play Count:")
                        Spacer()
                        Text("\(viewModel.albumPlayCount + viewModel.currentIteration)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Target:")
                        Spacer()
                        Text("\(viewModel.getTargetPlayCount())")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 40)
                .font(.subheadline)
                
                Spacer()
                
                // Playback Controls
                HStack(spacing: 30) {
                    // Play/Pause Button
                    Button(action: {
                        viewModel.togglePlayback()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                    }
                    
                    // Stop Button
                    Button(action: {
                        viewModel.stopProcessing()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                }
                
                // Control Labels
                HStack(spacing: 70) {
                    Text(viewModel.isPlaying ? "Pause" : "Resume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Stop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onDisappear {
                // Don't stop processing when view disappears unless explicitly stopped
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AnimatedProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let ringColor: Color
    let progressColor: Color
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ringColor, lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: animatedProgress)
            
            // Glow effect
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    progressColor.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth + 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 3)
                .animation(.easeInOut(duration: 0.5), value: animatedProgress)
        }
        .onChange(of: progress) { newProgress in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = newProgress
            }
        }
        .onAppear {
            animatedProgress = progress
        }
    }
}
