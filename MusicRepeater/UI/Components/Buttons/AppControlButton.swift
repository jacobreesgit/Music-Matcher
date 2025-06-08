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
