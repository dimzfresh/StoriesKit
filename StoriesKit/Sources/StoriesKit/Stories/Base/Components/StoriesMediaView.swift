import SwiftUI
import UIKit
import Kingfisher

/// Universal view for handling both images and videos in Stories
public struct StoriesMediaView<Placeholder, Failure>: View where Placeholder: View, Failure: View {
    private let mediaModel: StoriesMediaModel
    private let placeholder: (() -> Placeholder)
    private let failure: (() -> Failure)

    public init(
        mediaModel: StoriesMediaModel,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.mediaModel = mediaModel
        self.placeholder = placeholder
        self.failure = failure
    }

    public init(
        mediaModel: StoriesMediaModel,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        onVideoPlay: (() -> Void)? = nil,
        onVideoPause: (() -> Void)? = nil,
        onFirstFrameExtracted: ((UIImage) -> Void)? = nil
    ) where Failure == EmptyView {
        self.mediaModel = mediaModel
        self.placeholder = placeholder
        self.failure = { EmptyView() }
    }

    public var body: some View {
        Group {
            switch mediaModel.media {
            case let .image(imageSource):
                switch imageSource {
                case let .local(image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                case let .remote(url):
                    KFImage(url)
                        .placeholder(placeholder)
                        .cacheOriginalImage()
                        .diskCacheExpiration(.seconds(600))
                        .fade(duration: mediaModel.fadeDuration)
                        .resizable()
                        .scaledToFill()
                }
            case let .video(videoSource):
                VideoPlayerView(
                    videoSource: videoSource,
                    isMuted: false,
                    shouldLoop: true
                )
            }
        }
    }
}
