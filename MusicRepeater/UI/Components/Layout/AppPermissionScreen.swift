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
