import UIKit
import SwiftUI

/// Model representing an individual story page
public struct StoriesPageModel: Hashable {
    public let id: String
    public let date: String
    public let mediaSource: StoriesMediaModel
    public let isViewed: Bool
    public let duration: TimeInterval
    public let padding: EdgeInsets
    public let cornerRadius: CGFloat
    public let content: AnyView?

    public init(
        id: String = UUID().uuidString,
        date: String,
        mediaSource: StoriesMediaModel,
        isViewed: Bool = false,
        duration: TimeInterval = 5.0,
        padding: EdgeInsets = .init(top: 54, leading: 0, bottom: 44, trailing: 0),
        cornerRadius: CGFloat = 12,
        content: AnyView? = nil
    ) {
        self.id = id
        self.date = date
        self.mediaSource = mediaSource
        self.isViewed = isViewed
        self.duration = duration
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content
    }

    func updateViewed(_ isViewed: Bool) -> Self {
        .init(
            id: id,
            date: date,
            mediaSource: mediaSource,
            isViewed: isViewed,
            duration: duration,
            content: content
        )
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isViewed)
        hasher.combine(date)
        hasher.combine(mediaSource)
        hasher.combine(duration)
        hasher.combine(cornerRadius)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.isViewed == rhs.isViewed
        && lhs.mediaSource == rhs.mediaSource
        && lhs.duration == rhs.duration
        && lhs.cornerRadius == rhs.cornerRadius
    }
}
