import Foundation
import UIKit

public struct StoriesImageModel: Hashable {
    public let image: ImageSource
    public let placeholder: UIImage?
    public let fadeInDuration: TimeInterval
    public let isViewed: Bool

    public init(
        image: ImageSource,
        placeholder: UIImage? = nil,
        fadeInDuration: TimeInterval = 0.25,
        isViewed: Bool = false
    ) {
        self.image = image
        self.placeholder = placeholder
        self.fadeInDuration = fadeInDuration
        self.isViewed = isViewed
    }

    public enum ImageSource: Hashable {
        case image(UIImage?)
        case url(URL)
    }
}
