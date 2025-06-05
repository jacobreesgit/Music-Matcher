import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = AppSpacing.medium, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.designBackgroundSecondary)
                    .appShadow(.light)
            )
    }
}

#if DEBUG
struct AppCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.large) {
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Card Title")
                        .font(AppFont.headline)
                        .foregroundColor(Color.designTextPrimary)
                    
                    Text("This is some content inside a card with the default padding.")
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextSecondary)
                }
            }
            
            AppCard(padding: AppSpacing.large) {
                Text("Card with Custom Padding")
                    .font(AppFont.body)
                    .foregroundColor(Color.designTextPrimary)
            }
            
            AppCard(padding: AppSpacing.small) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(Color.designPrimary)
                    Text("Compact Card")
                        .font(AppFont.subheadline)
                        .foregroundColor(Color.designTextPrimary)
                }
            }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
