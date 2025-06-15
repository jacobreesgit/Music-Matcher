import SwiftUI

struct AppLoadingView: View {
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: AppSpacing.large) {
            // App Icon with music note fallback
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                    .fill(LinearGradient(
                        colors: [Color.designPrimary, Color.designPrimaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            .shadow(color: Color.designPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // App Name
            Text("Music Matcher")
                .font(AppFont.title)
                .foregroundColor(Color.designTextPrimary)
                .opacity(iconOpacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.designBackground)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
    }
}
