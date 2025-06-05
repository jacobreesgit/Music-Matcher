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

#if DEBUG
struct AppFeatureRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            AppFeatureRow("Match play counts between different versions of songs")
            AppFeatureRow("Add play counts together from multiple sources", bulletColor: Color.designSecondary)
            AppFeatureRow("Works with your existing music library", bulletColor: Color.designWarning)
            AppFeatureRow("Fast playback processing to build up counts quickly", bulletColor: Color.designInfo)
        }
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
