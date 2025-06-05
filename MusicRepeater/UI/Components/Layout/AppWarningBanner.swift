import SwiftUI

struct AppWarningBanner: View {
    let message: String
    let icon: String
    
    init(_ message: String, icon: String = "exclamationmark.triangle.fill") {
        self.message = message
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.designWarning)
                .font(AppFont.iconMedium)
            
            Text(message)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designWarning)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(AppSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .fill(Color.designWarning.opacity(0.1))
        )
    }
}

#if DEBUG
struct AppWarningBanner_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.medium) {
            AppWarningBanner("Warning: You've selected the same song for both source and target.")
            
            AppWarningBanner("This is a custom warning message.", icon: "exclamationmark.circle.fill")
            
            AppWarningBanner("A very long warning message that should wrap to multiple lines and still look good within the banner layout.")
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
