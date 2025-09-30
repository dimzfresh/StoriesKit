import SwiftUI
import Kingfisher

// MARK: - Configuration Structures

/// Avatar configuration for size and appearance
public struct AvatarConfiguration {
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
}

/// Progress indicator configuration
public struct ProgressConfiguration {
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
}

/// Title configuration
public struct TitleConfiguration {
    /// Number of lines for the title text
    public let numberOfLines: Int
    
    /// Line spacing for multi-line text
    public let lineSpacing: CGFloat
    
    /// Truncation mode for text that doesn't fit
    public let truncationMode: Text.TruncationMode
    
    /// Spacing between avatar and title
    public let spacingFromAvatar: CGFloat
    
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
        spacingFromAvatar: CGFloat = 8,
        padding: EdgeInsets = EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0),
        multilineTextAlignment: TextAlignment = .center,
        font: Font = .system(size: 12, weight: .bold),
        color: Color = .primary
    ) {
        self.numberOfLines = numberOfLines
        self.lineSpacing = lineSpacing
        self.truncationMode = truncationMode
        self.spacingFromAvatar = spacingFromAvatar
        self.padding = padding
        self.multilineTextAlignment = multilineTextAlignment
        self.font = font
        self.color = color
    }
}

/// Layout configuration for spacing and padding
public struct LayoutConfiguration {
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
}

/// Background configuration
public struct BackgroundConfiguration {
    /// Background color for the carousel
    public let color: Color
    
    public init(color: Color = .clear) {
        self.color = color
    }
}

/// Configuration for StoriesCarouselView appearance and behavior
public struct StoriesCarouselConfiguration {
    public let avatar: AvatarConfiguration
    public let progress: ProgressConfiguration
    public let title: TitleConfiguration
    public let layout: LayoutConfiguration
    public let background: BackgroundConfiguration
    
    public init(
        avatar: AvatarConfiguration = .default,
        progress: ProgressConfiguration = .default,
        title: TitleConfiguration = .default,
        layout: LayoutConfiguration = .default,
        background: BackgroundConfiguration = .default
    ) {
        self.avatar = avatar
        self.progress = progress
        self.title = title
        self.layout = layout
        self.background = background
    }
}

/// A customizable carousel view for displaying story groups with progress indicators
public struct StoriesCarouselView: View {
    @ObservedObject private var stateManager: StoriesStateManager
    private let avatarNamespace: Namespace.ID
    private let configuration: StoriesCarouselConfiguration

    @State private var scrollViewProxy: ScrollViewProxy?

    public init(
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID,
        configuration: StoriesCarouselConfiguration = .default
    ) {
        self.stateManager = stateManager
        self.avatarNamespace = avatarNamespace
        self.configuration = configuration
    }
    
    // MARK: - Computed Properties
    
    private var groups: [StoriesGroupModel] {
        let firstGroups = stateManager.state.groups.filter { $0.pages.contains(where: { !$0.isViewed }) }.sorted { $0.id < $1.id }
        let viewedGroups = stateManager.state.groups.filter { $0.pages.allSatisfy(\.isViewed) }.sorted { $0.id < $1.id }
        return firstGroups + viewedGroups
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            configuration.background.color
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: configuration.layout.itemSpacing) {
                        ForEach(groups) { group in
                            StoryGroupItemView(
                                group: group,
                                stateManager: stateManager,
                                avatarNamespace: avatarNamespace,
                                configuration: configuration
                            )
                            .id(group.id)
                        }
                    }
                    .padding(.horizontal, configuration.layout.horizontalPadding)
                }
                .onFirstAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: stateManager.state.selectedGroupId) { groupId in
                    guard let groupId else { return }
                    
                    Task {
                        proxy.scrollTo(groupId, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Story Group Item View

struct StoryGroupItemView: View {
    private let group: StoriesGroupModel
    @ObservedObject private var stateManager: StoriesStateManager
    private let avatarNamespace: Namespace.ID
    private let configuration: StoriesCarouselConfiguration

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SegmentedCircleView(
                    segments: createCustomSegments(for: group),
                    lineWidth: configuration.progress.lineWidth,
                    size: configuration.avatar.size + configuration.avatar.progressPadding,
                    gap: configuration.progress.gap
                )
                
                if group.id != stateManager.state.selectedGroupId {
                    avatarImageView()
                        .matchedGeometryEffect(
                            id: group.id,
                            in: avatarNamespace
                        )
                        .padding(configuration.avatar.padding)
                }
            }
            
            Text(group.title)
                .font(configuration.title.font)
                .foregroundColor(configuration.title.color)
                .lineLimit(configuration.title.numberOfLines)
                .lineSpacing(configuration.title.lineSpacing)
                .truncationMode(configuration.title.truncationMode)
                .multilineTextAlignment(configuration.title.multilineTextAlignment)
                .padding(configuration.title.padding)
        }
        .onTapGesture {
            handleTap()
        }
    }

    init(
        group: StoriesGroupModel,
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID,
        configuration: StoriesCarouselConfiguration
    ) {
        self.group = group
        self.stateManager = stateManager
        self.avatarNamespace = avatarNamespace
        self.configuration = configuration
    }

    @ViewBuilder
    private func avatarImageView() -> some View {
        switch group.avatarImage {
        case let .local(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    width: configuration.avatar.size,
                    height: configuration.avatar.size
                )
                .clipShape(Circle())
        case let .remote(url):
            KFImage(url)
                .placeholder {
                    Circle()
                        .fill(.clear)
                        .frame(
                            width: configuration.avatar.size,
                            height: configuration.avatar.size
                        )
                        .overlay {
                            if let placeholder = group.placeholder {
                                Image(uiImage: placeholder)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(
                                        width: configuration.avatar.size,
                                        height: configuration.avatar.size
                                    )
                                    .clipShape(Circle())
                            }
                        }
                }
                .resizable()
                .scaledToFill()
                .frame(width: configuration.avatar.size, height: configuration.avatar.size)
                .clipShape(Circle())
        }
    }

    private func createCustomSegments(for group: StoriesGroupModel) -> [SegmentedCircleView.Segment] {
        if group.pages.allSatisfy(\.isViewed) {
            [
                .init(
                    color: configuration.progress.viewedColor,
                    isActive: false
                )
            ]
        } else {
            group.pages.map { page in
                if page.isViewed {
                    .init(
                        color: configuration.progress.viewedColor,
                        isActive: false
                    )
                } else {
                    .init(
                        color: configuration.progress.unviewedColor,
                        isActive: true
                    )
                }
            }
        }
    }
    
    private func handleTap() {
        stateManager.send(.didToggleGroup(group.id))
    }
}

// MARK: - Default Configurations

public extension AvatarConfiguration {
    static let `default` = AvatarConfiguration()
}

public extension ProgressConfiguration {
    static let `default` = ProgressConfiguration()
}

public extension TitleConfiguration {
    static let `default` = TitleConfiguration()
}

public extension LayoutConfiguration {
    static let `default` = LayoutConfiguration()
}

public extension BackgroundConfiguration {
    static let `default` = BackgroundConfiguration()
}

public extension StoriesCarouselConfiguration {
    static let `default` = StoriesCarouselConfiguration()
}
