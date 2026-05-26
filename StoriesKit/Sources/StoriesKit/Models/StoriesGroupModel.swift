import UIKit
import SwiftUI

/// Model representing a group of stories (e.g., from one user)
public struct StoriesGroupModel: Hashable, Identifiable {
    public let id: String
    public let title: String
    public let avatarImage: StoriesMediaModel.MediaSource.ImageType
    public let placeholder: UIImage?
    public let pages: [StoriesPageModel]

    /// `true` when every page in the group is marked viewed (including an empty group).
    public var isFullyViewed: Bool {
        pages.allSatisfy(\.isViewed)
    }

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

    /// Groups with unviewed pages first, then fully viewed; ties broken by `id`.
    public static func sortedForDisplay(_ groups: [StoriesGroupModel]) -> [StoriesGroupModel] {
        groups.sorted { lhs, rhs in
            if lhs.isFullyViewed != rhs.isFullyViewed {
                return !lhs.isFullyViewed
            }
            return lhs.id < rhs.id
        }
    }
}
