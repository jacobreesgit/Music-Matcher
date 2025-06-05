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

#if DEBUG
struct AppSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            AppSectionHeader("Source Track")
            
            AppSectionHeader("Target Track", subtitle: "Track to update play count for")
            
            AppSectionHeader("Settings", subtitle: "Configure app preferences and behavior")
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
