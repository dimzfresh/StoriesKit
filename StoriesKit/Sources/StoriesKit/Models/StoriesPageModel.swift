import UIKit
import SwiftUI

/// Model representing an individual story page
public struct StoriesPageModel: Hashable {
    public let id: String
    public let isViewed: Bool
    public let mediaSource: StoriesMediaModel
    public let button: StoriesPageModel.Button?
    public let duration: TimeInterval
    public let corners: Corners
    public let content: AnyView?

    public init(
        id: String = UUID().uuidString,
        mediaSource: StoriesMediaModel,
        isViewed: Bool = false,
        button: StoriesPageModel.Button? = nil,
        duration: TimeInterval = 5.0,
        corners: Corners = .radius(12),
        content: AnyView? = nil
    ) {
        self.id = id
        self.isViewed = isViewed
        self.button = button
        self.mediaSource = mediaSource
        self.duration = duration
        self.corners = corners
        self.content = content
    }

    func updateViewed(_ isViewed: Bool) -> Self {
        .init(
            id: id,
            mediaSource: mediaSource,
            isViewed: isViewed,
            button: button,
            duration: duration,
            content: content
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isViewed)
        hasher.combine(mediaSource)
        hasher.combine(button)
        hasher.combine(duration)
        hasher.combine(corners)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.isViewed == rhs.isViewed
        && lhs.mediaSource == rhs.mediaSource
        && lhs.button == rhs.button
        && lhs.duration == rhs.duration
        && lhs.corners == rhs.corners
    }

    /// Button configuration for story pages
    public struct Button: Hashable {
        public let title: AttributedString
        public let backgroundColor: Color
        public let corners: Corners
        public let actionType: ActionType

        public init(
            title: AttributedString,
            backgroundColor: Color,
            corners: Corners,
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
    }

    /// Corner styles
    public enum Corners: Hashable {
        case none
        case circle
        case radius(CGFloat)
    }
}
