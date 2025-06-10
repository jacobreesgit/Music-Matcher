import SwiftUI

struct AppFeatureRow: View {
    let text: String
    let bulletColor: Color
    
    init(_ text: String, bulletColor: Color = Color.designPrimary) {
        self.text = text
        self.bulletColor = bulletColor
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Text("•")
                .foregroundColor(bulletColor)
                .fontWeight(.bold)
                .font(AppFont.subheadline)
            
            Text(text)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
        }
    }
}
