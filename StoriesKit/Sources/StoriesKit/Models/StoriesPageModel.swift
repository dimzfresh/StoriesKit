import UIKit

public struct StoriesPageModel: Hashable {
    public let title: AttributedString
    public let subtitle: AttributedString?
    public let backgroundColor: UIColor
    public let button: StoriesPageModel.Button?
    public let backgroundImage: StoriesImageModel
    public let duration: TimeInterval
    
    public init(
        title: AttributedString,
        subtitle: AttributedString?,
        backgroundColor: UIColor,
        button: StoriesPageModel.Button? = nil,
        backgroundImage: StoriesImageModel,
        duration: TimeInterval = 4.0
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.button = button
        self.backgroundImage = backgroundImage
        self.duration = duration
    }

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

        public enum ActionType: Hashable {
            case next
            case close
            case link(URL)
        }

        public enum Corners: Hashable {
            case none
            case circle
            case radius(CGFloat)
        }
    }
}
