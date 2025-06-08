import SwiftUI

struct AppSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.headline)
                .foregroundColor(Color.designTextPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFont.subheadline)
                    .foregroundColor(Color.designTextSecondary)
            }
        }
    }
}
