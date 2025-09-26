import Kingfisher
import SwiftUI

struct RandomImagesView: View {
    let images: [String]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(images.prefix(5).indices, id: \.self) { index in
                ZStack {
                    KFImage(URL(string: images[index]))
                        .placeholder {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(16)
                }
                .clipped()
            }
        }
        .padding(.horizontal, 16)
    }
}
