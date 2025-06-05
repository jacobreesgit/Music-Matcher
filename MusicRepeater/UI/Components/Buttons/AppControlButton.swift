import SwiftUI

struct AppControlButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    init(icon: String, color: Color = Color.designPrimary, size: CGFloat = 60, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color)
        }
        .scaleEffect(1.0)
        .animation(AppAnimation.quick, value: icon)
    }
}

#if DEBUG
struct AppControlButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.large) {
            HStack(spacing: AppSpacing.xl) {
                AppControlButton(icon: "play.circle.fill") { }
                AppControlButton(icon: "pause.circle.fill") { }
                AppControlButton(icon: "stop.circle.fill", color: Color.designError) { }
            }
            
            HStack(spacing: AppSpacing.xl) {
                AppControlButton(icon: "play.circle.fill", size: 40) { }
                AppControlButton(icon: "pause.circle.fill", size: 40) { }
                AppControlButton(icon: "stop.circle.fill", color: Color.designError, size: 40) { }
            }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
