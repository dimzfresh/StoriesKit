import SwiftUI
import UIKit

/// Central model for StoriesKit configuration
public struct StoriesModel {
    /// Array of story groups
    public let groups: [StoriesGroupModel]
    
    /// Background color for the stories view
    public let backgroundColor: Color
    
    /// Progress indicator configuration
    public let progress: StoriesModel.Progress

    /// Avatar configuration
    public let avatar: StoriesModel.Avatar

    /// Text configuration for user names
    public let userName: StoriesModel.UserName

    public init(
        groups: [StoriesGroupModel],
        backgroundColor: Color = .black,
        progress: StoriesModel.Progress = .default,
        avatar: StoriesModel.Avatar = .default,
        userName: StoriesModel.UserName = .default
    ) {
        self.groups = groups
        self.backgroundColor = backgroundColor
        self.progress = progress
        self.avatar = avatar
        self.userName = userName
    }

    public struct Avatar {
        /// Size of the avatar image
        public let size: CGFloat

        /// Padding around the avatar
        public let padding: EdgeInsets

        public init(
            size: CGFloat = 30,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        ) {
            self.size = size
            self.padding = padding
        }

        public static let `default` = Self()
    }

    public struct UserName {
        /// Font for user names
        public let font: Font

        /// Color for user names
        public let color: Color

        /// Number of lines for text
        public let numberOfLines: Int

        /// Text alignment
        public let alignment: TextAlignment

        /// Padding around the title within its container
        public let padding: EdgeInsets

        public init(
            font: Font = .system(size: 12, weight: .bold),
            color: Color = .white,
            numberOfLines: Int = 1,
            alignment: TextAlignment = .center,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        ) {
            self.font = font
            self.color = color
            self.numberOfLines = numberOfLines
            self.alignment = alignment
            self.padding = padding
        }

        public static let `default` = Self()
    }

    public struct Progress {
        /// Thickness/height of progress segments
        public let lineSize: CGFloat

        /// Spacing between multiple progress bars (if any)
        public let interItemSpacing: CGFloat

        /// Padding of the progress container
        public let containerPadding: EdgeInsets

        /// Color for viewed segments
        public let viewedColor: Color

        /// Color for unviewed segments
        public let unviewedColor: Color

        public init(
            lineSize: CGFloat = 2,
            interItemSpacing: CGFloat = 4,
            containerPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            viewedColor: Color = .gray.opacity(0.6),
            unviewedColor: Color = .green
        ) {
            self.lineSize = lineSize
            self.interItemSpacing = interItemSpacing
            self.containerPadding = containerPadding
            self.viewedColor = viewedColor
            self.unviewedColor = unviewedColor
        }

        public static let `default` = Self()
    }
}
