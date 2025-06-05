import SwiftUI

struct AppSecondaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ title: String, subtitle: String? = nil, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(AppFont.headline)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFont.caption)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .fill(isEnabled ? Color.designSecondary : Color.designTextTertiary)
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(AppAnimation.quick, value: isEnabled)
    }
}

#if DEBUG
struct AppSecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.medium) {
            AppSecondaryButton("Add", subtitle: "10 → 35") { }
            AppSecondaryButton("Disabled Button", isEnabled: false) { }
            AppSecondaryButton("Simple Button") { }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
