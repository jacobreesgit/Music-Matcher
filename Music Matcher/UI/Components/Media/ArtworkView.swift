import SwiftUI
import MediaPlayer

struct ArtworkView: View {
    let artwork: MPMediaItemArtwork?
    let size: CGFloat
    let fallbackIcon: String
    let cornerRadius: CGFloat
    
    @State private var uiImage: UIImage?
    
    init(
        artwork: MPMediaItemArtwork?,
        size: CGFloat = 60,
        fallbackIcon: String = "music.note",
        cornerRadius: CGFloat = AppCornerRadius.small
    ) {
        self.artwork = artwork
        self.size = size
        self.fallbackIcon = fallbackIcon
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .background(Color.designBackgroundTertiary)
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            loadArtwork()
        }
        .onChange(of: artwork) { _, _ in
            loadArtwork()
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.designBackgroundTertiary)
            .overlay(
                Image(systemName: fallbackIcon)
                    .font(.system(size: iconSize))
                    .foregroundColor(Color.designPrimary)
            )
    }
    
    private var iconSize: CGFloat {
        switch size {
        case 0..<40: return 14
        case 40..<60: return 18
        case 60..<80: return 24
        case 80..<120: return 32
        default: return 40
        }
    }
    
    private func loadArtwork() {
        guard let artwork = artwork else {
            uiImage = nil
            return
        }
        
        let imageSize = CGSize(width: size, height: size)
        uiImage = artwork.image(at: imageSize)
    }
}

// MARK: - Preview
#if DEBUG
struct ArtworkView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ArtworkView(artwork: nil, size: 60)
            ArtworkView(artwork: nil, size: 80, fallbackIcon: "music.note.list")
            ArtworkView(artwork: nil, size: 120, cornerRadius: AppCornerRadius.large)
        }
        .padding()
        .background(Color.designBackground)
    }
}
#endif
