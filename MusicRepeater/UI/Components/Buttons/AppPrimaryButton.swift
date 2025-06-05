import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    let subtitle: String?
    let action: () -> Void
    let isEnabled: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
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
                    .fill(isEnabled ? Color.designPrimary : Color.designTextTertiary)
                    .appShadow(.light)
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.95)
        .animation(AppAnimation.quick, value: isEnabled)
    }
}

#if DEBUG
struct AppPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.medium) {
            AppPrimaryButton("Match", subtitle: "10 → 25") { }
            AppPrimaryButton("Disabled Button", isEnabled: false) { }
            AppPrimaryButton("Simple Button") { }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
