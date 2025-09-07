import SwiftUI
import Kingfisher

public struct StoriesImageView: View {
    public let model: StoriesImageModel

    public init(
        model: StoriesImageModel
    ) {
        self.model = model
    }
    
    public var body: some View {
        Group {
            switch model.image {
            case let .image(image):
                localImageView(for: image)
            case let .url(url):
                remoteImageView(for: url)
            }
        }
    }
    
    // MARK: - Image Views
    
    private func localImageView(for image: UIImage?) -> some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderView()
            }
        }
    }

    private func remoteImageView(for url: URL) -> some View {
        KFImage(url)
            .placeholder(placeholderView)
            .fade(duration: model.fadeInDuration)
            .resizable()
            .scaledToFill()
    }
    
    private func placeholderView() -> some View {
        Group {
            if let placeholder = model.placeholder {
                Image(uiImage: placeholder)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.clear
            }
        }
    }
}
