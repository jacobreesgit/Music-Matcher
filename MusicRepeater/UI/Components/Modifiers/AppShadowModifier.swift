import SwiftUI

struct AppShadowModifier: ViewModifier {
    let shadowType: AppShadow
    
    func body(content: Content) -> some View {
        let shadow = shadowType.shadow
        return content
            .shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
    }
}

#if DEBUG
struct AppShadowModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.xl) {
            Text("Light Shadow")
                .padding()
                .background(Color.designBackgroundSecondary)
                .cornerRadius(AppCornerRadius.medium)
                .appShadow(.light)
            
            Text("Medium Shadow")
                .padding()
                .background(Color.designBackgroundSecondary)
                .cornerRadius(AppCornerRadius.medium)
                .appShadow(.medium)
            
            Text("Heavy Shadow")
                .padding()
                .background(Color.designBackgroundSecondary)
                .cornerRadius(AppCornerRadius.medium)
                .appShadow(.heavy)
        }
        .padding(AppSpacing.xl)
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
