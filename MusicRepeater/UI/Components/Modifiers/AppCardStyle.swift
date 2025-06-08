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
