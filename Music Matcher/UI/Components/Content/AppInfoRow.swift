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
