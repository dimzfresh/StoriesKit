import SwiftUI
import UIKit
import Nuke
import NukeUI

/// Universal view for handling both images and videos in Stories
public struct StoriesMediaView<Placeholder, Failure>: View where Placeholder: View, Failure: View {
    private let mediaModel: StoriesMediaModel
    private let videoManager: StoriesVideoManager?
    private let isVideoActive: Bool
    private let placeholder: (() -> Placeholder)
    private let failure: (() -> Failure)

    public var body: some View {
        Group {
            switch mediaModel.media {
            case let .image(imageSource):
                imageView(for: imageSource)
            case let .video(videoSource):
                videoView(for: videoSource)
            }
        }
    }

    public init(
        mediaModel: StoriesMediaModel,
        videoManager: StoriesVideoManager? = nil,
        isVideoActive: Bool = false,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.mediaModel = mediaModel
        self.videoManager = videoManager
        self.isVideoActive = isVideoActive
        self.placeholder = placeholder
        self.failure = failure
    }

    public init(
        mediaModel: StoriesMediaModel,
        videoManager: StoriesVideoManager? = nil,
        isVideoActive: Bool = false,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        onVideoPlay: (() -> Void)? = nil,
        onVideoPause: (() -> Void)? = nil,
        onFirstFrameExtracted: ((UIImage) -> Void)? = nil
    ) where Failure == EmptyView {
        self.mediaModel = mediaModel
        self.videoManager = videoManager
        self.isVideoActive = isVideoActive
        self.placeholder = placeholder
        self.failure = { EmptyView() }
    }

    @ViewBuilder
    private func imageView(for source: StoriesMediaModel.MediaSource.ImageType) -> some View {
        switch source {
        case let .local(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        case let .remote(url):
            if let url {
                LazyImage(url: url) { state in
                    Group {
                        if let image = state.image {
                            image
                                .resizable()
                                .scaledToFill()
                        } else if state.error != nil {
                            failure()
                        } else {
                            placeholder()
                        }
                    }
                    .animation(.easeInOut(duration: mediaModel.fadeDuration), value: state.image != nil)
                }
            } else {
                failure()
            }
        }
    }

    @ViewBuilder
    private func videoView(for source: StoriesMediaModel.MediaSource.VideoType) -> some View {
        if let videoManager {
            switch source {
            case let .local(asset):
                VideoPlayerView(
                    videoManager: videoManager,
                    videoSource: .local(asset),
                    isMuted: false,
                    shouldLoop: false,
                    isActive: isVideoActive,
                    onPlaybackEnd: nil
                )
            case let .remote(url):
                if url != nil {
                    VideoPlayerView(
                        videoManager: videoManager,
                        videoSource: .remote(url),
                        isMuted: false,
                        shouldLoop: false,
                        isActive: isVideoActive,
                        onPlaybackEnd: nil
                    )
                } else {
                    failure()
                }
            }
        } else {
            failure()
        }
    }
}
