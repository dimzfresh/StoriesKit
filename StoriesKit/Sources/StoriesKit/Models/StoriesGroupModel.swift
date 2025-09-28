import UIKit

/// Model representing a group of stories (e.g., from one user)
public struct StoriesGroupModel: Hashable, Identifiable {
    public let id: String
    public let title: String
    public let avatarImage: StoriesMediaModel.MediaSource.ImageType
    public let stories: [StoriesPageModel]
    public let isViewed: Bool
    
    public init(
        id: String,
        title: String,
        avatarImage: StoriesMediaModel.MediaSource.ImageType,
        stories: [StoriesPageModel],
        isViewed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.avatarImage = avatarImage
        self.stories = stories
        self.isViewed = isViewed
    }
}
