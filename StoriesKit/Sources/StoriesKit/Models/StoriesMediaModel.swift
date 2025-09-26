import Foundation
import UIKit
import AVFoundation

/// Model for story media with support for images and videos
public struct StoriesMediaModel: Hashable {
    public let media: MediaSource
    public let placeholder: UIImage?
    public let failure: UIImage?
    public let fadeDuration: TimeInterval

    public init(
        media: MediaSource,
        placeholder: UIImage? = nil,
        failure: UIImage? = nil,
        fadeDuration: TimeInterval = 0.05
    ) {
        self.media = media
        self.placeholder = placeholder
        self.failure = failure
        self.fadeDuration = fadeDuration
    }

    /// Media source types supporting both images and videos
    public enum MediaSource: Hashable {
        case image(ImageType)
        case video(VideoType)

        public enum ImageType: Hashable {
            case local(UIImage)
            case remote(URL)
        }

        public enum VideoType: Hashable {
            case local(AVAsset)
            case remote(URL)
        }
    }
}
