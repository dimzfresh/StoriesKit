import SwiftUI

struct RandomImagesView: View {
    let images: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(images.prefix(5).indices, id: \.self) { index in
                AsyncImageView(
                    url: URL(string: images[index]),
                    placeholder: "music.note",
                    width: UIScreen.main.bounds.width - 32,
                    height: 200,
                    cornerRadius: 16
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.2), value: images[index])
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let sampleImages = (1...5).map { index in
        "https://picsum.photos/400/200?random=\(index + 100)"
    }
    
    ScrollView {
        RandomImagesView(images: sampleImages)
    }
}