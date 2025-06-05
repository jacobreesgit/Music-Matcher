import SwiftUI

struct AppPermissionScreen: View {
    let icon: String
    let title: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void
    let statusMessage: String?
    let isButtonDestructive: Bool
    
    init(
        icon: String,
        title: String,
        description: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void,
        statusMessage: String? = nil,
        isButtonDestructive: Bool = false
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.statusMessage = statusMessage
        self.isButtonDestructive = isButtonDestructive
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(Color.designPrimary)
            
            // Title and Description
            VStack(spacing: AppSpacing.medium) {
                Text(title)
                    .font(AppFont.title)
                    .foregroundColor(Color.designTextPrimary)
                
                Text(description)
                    .font(AppFont.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            // Button
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(AppFont.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.large)
                            .fill(isButtonDestructive ? Color.designError : Color.designPrimary)
                    )
            }
            .padding(.horizontal, AppSpacing.xxl)
            
            // Status Message
            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .font(AppFont.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.designTextSecondary)
                    .padding(.horizontal, AppSpacing.large)
            }
            
            Spacer()
        }
    }
}

#if DEBUG
struct AppPermissionScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppPermissionScreen(
                icon: "music.note.house",
                title: "Music Library Access",
                description: "Music Repeater needs access to your music library to synchronize play counts between different versions of songs.",
                buttonTitle: "Grant Music Access",
                buttonAction: { }
            )
            .previewDisplayName("Request Permission")
            
            AppPermissionScreen(
                icon: "music.note.house",
                title: "Music Library Access",
                description: "Music Repeater needs access to your music library to synchronize play counts between different versions of songs.",
                buttonTitle: "Open Settings",
                buttonAction: { },
                statusMessage: "To use Music Repeater, please enable Music access in Settings → Privacy & Security → Media & Apple Music → Music Repeater"
            )
            .previewDisplayName("Settings Required")
            
            AppPermissionScreen(
                icon: "xmark.circle",
                title: "Access Restricted",
                description: "Music access is restricted on this device.",
                buttonTitle: "Contact Administrator",
                buttonAction: { },
                statusMessage: "Music access is restricted and cannot be enabled by the user.",
                isButtonDestructive: true
            )
            .previewDisplayName("Restricted Access")
        }
        .background(Color.designBackground)
    }
}
#endif
