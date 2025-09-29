import UIKit

/// Model representing an individual story page
public struct StoriesPageModel: Hashable {
    public let id: String
    public let title: AttributedString
    public let subtitle: AttributedString?
    public let backgroundColor: UIColor
    public let isViewed: Bool
    public let button: StoriesPageModel.Button?
    public let mediaSource: StoriesMediaModel
    public let duration: TimeInterval
    
    public init(
        id: String = UUID().uuidString,
        title: AttributedString,
        subtitle: AttributedString?,
        backgroundColor: UIColor,
        mediaSource: StoriesMediaModel,
        isViewed: Bool = false,
        button: StoriesPageModel.Button? = nil,
        duration: TimeInterval = 4.0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.isViewed = isViewed
        self.button = button
        self.mediaSource = mediaSource
        self.duration = duration
    }

    func updateViewed(_ isViewed: Bool) -> Self {
        .init(
            id: id,
            title: title,
            subtitle: subtitle,
            backgroundColor: backgroundColor,
            mediaSource: mediaSource,
            isViewed: isViewed,
            button: button,
            duration: duration
        )
    }

    /// Button configuration for story pages
    public struct Button: Hashable {
        public let title: AttributedString
        public let backgroundColor: UIColor
        public let corners: Button.Corners
        public let actionType: ActionType

        public init(
            title: AttributedString,
            backgroundColor: UIColor,
            corners: Button.Corners,
            actionType: ActionType
        ) {
            self.title = title
            self.backgroundColor = backgroundColor
            self.corners = corners
            self.actionType = actionType
        }

        /// Types of button actions
        public enum ActionType: Hashable {
            case next
            case close
            case link(URL)
        }

        /// Button corner styles
        public enum Corners: Hashable {
            case none
            case circle
            case radius(CGFloat)
        }
    }
}
