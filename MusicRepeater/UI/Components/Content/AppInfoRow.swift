import SwiftUI

struct AppInfoRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    init(_ label: String, value: String, valueColor: Color = Color.designTextPrimary) {
        self.label = label
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.subheadline)
                .foregroundColor(Color.designTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFont.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
        }
    }
}

#if DEBUG
struct AppInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppSpacing.small) {
            AppInfoRow("Current Play Count:", value: "42")
            AppInfoRow("Target:", value: "100", valueColor: Color.designPrimary)
            AppInfoRow("Status:", value: "Processing", valueColor: Color.designWarning)
            AppInfoRow("Error:", value: "Failed to load", valueColor: Color.designError)
            AppInfoRow("Success:", value: "Completed", valueColor: Color.designSuccess)
        }
        .padding()
        .background(Color.designBackgroundSecondary)
        .cornerRadius(AppCornerRadius.medium)
        .padding()
        .background(Color.designBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
