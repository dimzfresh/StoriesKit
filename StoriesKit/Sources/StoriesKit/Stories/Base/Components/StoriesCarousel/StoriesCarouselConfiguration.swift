import SwiftUI

/// Configuration for StoriesCarouselView appearance and behavior
public struct StoriesCarouselConfiguration {
    public let avatar: StoriesCarouselConfiguration.Avatar
    public let progress: StoriesCarouselConfiguration.Progress
    public let title: StoriesCarouselConfiguration.Title
    public let layout: StoriesCarouselConfiguration.Layout
    public let backgroundColor: Color

    public init(
        avatar: StoriesCarouselConfiguration.Avatar = .default,
        title: StoriesCarouselConfiguration.Title = .default,
        backgroundColor: Color = .clear,
        progress: StoriesCarouselConfiguration.Progress = .default,
        layout: StoriesCarouselConfiguration.Layout = .default
    ) {
        self.avatar = avatar
        self.title = title
        self.backgroundColor = backgroundColor
        self.progress = progress
        self.layout = layout
    }

    public static let `default` = Self()

    /// Avatar configuration for size and appearance
    public struct Avatar {
        /// Size of the avatar image
        public let size: CGFloat

        /// Size of the progress circle (relative to avatar)
        public let progressPadding: CGFloat

        /// Padding around the avatar within its container
        public let padding: EdgeInsets

        public init(
            size: CGFloat = 70,
            progressPadding: CGFloat = 6,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        ) {
            self.size = size
            self.progressPadding = progressPadding
            self.padding = padding
        }

        public static let `default` = Self()
    }

    /// Title configuration
    public struct Title {
        /// Number of lines for the title text
        public let numberOfLines: Int

        /// Line spacing for multi-line text
        public let lineSpacing: CGFloat

        /// Truncation mode for text that doesn't fit
        public let truncationMode: Text.TruncationMode

        /// Padding around the title within its container
        public let padding: EdgeInsets

        /// Text alignment for multi-line text
        public let multilineTextAlignment: TextAlignment

        /// Font for the title text
        public let font: Font

        /// Color for the title text
        public let color: Color

        public init(
            numberOfLines: Int = 1,
            lineSpacing: CGFloat = 0,
            truncationMode: Text.TruncationMode = .tail,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0),
            multilineTextAlignment: TextAlignment = .center,
            font: Font = .system(size: 12, weight: .bold),
            color: Color = .primary
        ) {
            self.numberOfLines = numberOfLines
            self.lineSpacing = lineSpacing
            self.truncationMode = truncationMode
            self.padding = padding
            self.multilineTextAlignment = multilineTextAlignment
            self.font = font
            self.color = color
        }

        public static let `default` = Self()
    }

    /// Progress indicator configuration
    public struct Progress {
        /// Line width for the progress circle
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

    /// Layout configuration for spacing and padding
    public struct Layout {
        /// Spacing between carousel items
        public let itemSpacing: CGFloat

        /// Horizontal padding for the carousel
        public let horizontalPadding: CGFloat

        public init(
            itemSpacing: CGFloat = 16,
            horizontalPadding: CGFloat = 16
        ) {
            self.itemSpacing = itemSpacing
            self.horizontalPadding = horizontalPadding
        }

        public static let `default` = Self()
    }
}
