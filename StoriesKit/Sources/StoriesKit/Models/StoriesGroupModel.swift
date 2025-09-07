import Foundation

public struct StoriesGroupModel: Hashable {
    public let id: String
    public let title: String
    public let avatarImage: StoriesImageModel.ImageSource
    public let stories: [StoriesPageModel]
    public let isViewed: Bool
    
    public init(
        id: String,
        title: String,
        avatarImage: StoriesImageModel.ImageSource,
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
