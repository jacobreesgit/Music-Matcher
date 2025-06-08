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
