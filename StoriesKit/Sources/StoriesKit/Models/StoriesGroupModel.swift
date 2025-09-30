import UIKit
import SwiftUI

/// Model representing a group of stories (e.g., from one user)
public struct StoriesGroupModel: Hashable, Identifiable {
    public let id: String
    public let title: String
    public let avatarImage: StoriesMediaModel.MediaSource.ImageType
    public let placeholder: UIImage?
    public let pages: [StoriesPageModel]

    public init(
        id: String,
        title: String,
        avatarImage: StoriesMediaModel.MediaSource.ImageType,
        placeholder: UIImage? = nil,
        pages: [StoriesPageModel]
    ) {
        self.id = id
        self.title = title
        self.avatarImage = avatarImage
        self.placeholder = placeholder
        self.pages = pages
    }
}
