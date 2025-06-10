import SwiftUI

struct AppProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    @State private var lastUpdateTime: Date = Date()
    
    init(progress: Double, lineWidth: CGFloat = 12, size: CGFloat = 200) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.designPrimary.opacity(0.3), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.designPrimary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(AppAnimation.standard, value: animatedProgress)
            
            // Glow effect
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.designPrimary.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth + 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 3)
                .animation(AppAnimation.standard, value: animatedProgress)
        }
        .frame(width: size, height: size)
        .onChange(of: progress) { _, newProgress in
            updateProgressWithThrottling(newProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
    }
    
    private func updateProgressWithThrottling(_ newProgress: Double) {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
        
        // Only update if at least 50ms have passed since the last update
        // This prevents multiple updates per frame
        if timeSinceLastUpdate >= 0.05 {
            lastUpdateTime = now
            withAnimation(AppAnimation.standard) {
                animatedProgress = newProgress
            }
        } else {
            // Schedule an update after the throttle period
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.updateProgressWithThrottling(newProgress)
            }
        }
    }
}
