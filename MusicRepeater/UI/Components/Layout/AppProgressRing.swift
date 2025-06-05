import SwiftUI

struct AppProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
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
            withAnimation(AppAnimation.standard) {
                animatedProgress = newProgress
            }
        }
        .onAppear {
            animatedProgress = progress
        }
    }
}

#if DEBUG
struct AppProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.xl) {
            HStack(spacing: AppSpacing.xl) {
                AppProgressRing(progress: 0.3, size: 100)
                AppProgressRing(progress: 0.6, size: 100)
                AppProgressRing(progress: 0.9, size: 100)
            }
            
            AppProgressRing(progress: 0.75, lineWidth: 8, size: 150)
            
            ZStack {
                AppProgressRing(progress: 0.4, size: 200)
                VStack {
                    Text("8")
                        .font(AppFont.counterLarge)
                        .foregroundColor(Color.designTextPrimary)
                    Text("of 20")
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextSecondary)
                }
            }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
