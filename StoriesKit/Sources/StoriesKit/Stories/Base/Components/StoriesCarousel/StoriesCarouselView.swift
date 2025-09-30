import SwiftUI
import Kingfisher

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
            configuration.backgroundColor

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
