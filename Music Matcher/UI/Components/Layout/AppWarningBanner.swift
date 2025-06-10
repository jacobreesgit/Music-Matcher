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
