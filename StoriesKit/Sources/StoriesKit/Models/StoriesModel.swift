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
    public let text: StoriesModel.Text

    public init(
        groups: [StoriesGroupModel],
        backgroundColor: Color = .black,
        progress: StoriesModel.Progress = .default,
        avatar: StoriesModel.Avatar = .default,
        text: StoriesModel.Text = .default
    ) {
        self.groups = groups
        self.backgroundColor = backgroundColor
        self.progress = progress
        self.avatar = avatar
        self.text = text
    }

    public struct Avatar {
        /// Size of the avatar image
        public let size: CGFloat

        /// Padding around the avatar
        public let padding: EdgeInsets

        public init(
            size: CGFloat = 70,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        ) {
            self.size = size
            self.padding = padding
        }

        public static let `default` = Self()
    }

    public struct Text {
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
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
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
        /// Line width for progress indicators
        public let lineWidth: CGFloat

        /// Gap between progress segments
        public let gap: CGFloat

        /// Color for viewed segments
        public let viewedColor: Color

        /// Color for unviewed segments
        public let unviewedColor: Color

        public init(
            lineWidth: CGFloat = 3,
            gap: CGFloat = 2,
            viewedColor: Color = .gray.opacity(0.6),
            unviewedColor: Color = .green
        ) {
            self.lineWidth = lineWidth
            self.gap = gap
            self.viewedColor = viewedColor
            self.unviewedColor = unviewedColor
        }

        public static let `default` = Self()
    }
}
