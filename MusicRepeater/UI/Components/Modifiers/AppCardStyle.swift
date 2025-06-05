import SwiftUI

struct AppCardStyle: ViewModifier {
    let isElevated: Bool
    
    init(elevated: Bool = false) {
        self.isElevated = elevated
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(isElevated ? .medium : .light)
            )
    }
}

#if DEBUG
struct AppCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.large) {
            Text("Standard Card")
                .padding()
                .appCardStyle()
            
            Text("Elevated Card")
                .padding()
                .appCardStyle(elevated: true)
            
            VStack {
                Text("Complex Content Card")
                    .font(AppFont.headline)
                Text("With multiple elements")
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
            .padding()
            .appCardStyle(elevated: true)
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
