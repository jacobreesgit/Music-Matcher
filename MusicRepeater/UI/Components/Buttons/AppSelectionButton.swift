import SwiftUI

struct AppSelectionButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(AppFont.iconMedium)
                    .foregroundColor(Color.designPrimary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.body)
                        .foregroundColor(Color.designTextPrimary)
                        .lineLimit(1)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(AppFont.subheadline)
                            .foregroundColor(Color.designTextSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .fill(Color.appCardBackground)
            )
        }
    }
}

#if DEBUG
struct AppSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.medium) {
            AppSelectionButton(
                icon: "music.note",
                title: "Choose Source Track",
                subtitle: nil
            ) { }
            
            AppSelectionButton(
                icon: "music.note",
                title: "Song Title - Artist Name",
                subtitle: "Play Count: 42"
            ) { }
            
            AppSelectionButton(
                icon: "music.note.list",
                title: "Very Long Song Title That Should Truncate",
                subtitle: "Play Count: 123"
            ) { }
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
