import SwiftUI
import Combine
import Kingfisher

/// A customizable carousel view for displaying story groups with progress indicators
public struct StoriesCarouselView: View {
    @ObservedObject private var stateManager: StoriesStateManager
    private let avatarNamespace: Namespace.ID
    private let configuration: StoriesCarouselConfiguration

    @State private var scrollViewProxy: ScrollViewProxy?
    @State private var displayedGroups: [StoriesGroupModel] = []

    public init(
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID,
        configuration: StoriesCarouselConfiguration = .default
    ) {
        self.stateManager = stateManager
        self.avatarNamespace = avatarNamespace
        self.configuration = configuration
        _displayedGroups = .init(initialValue: stateManager.state.groups)
    }
    
    // MARK: - Body

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: configuration.layout.itemSpacing) {
                    ForEach(displayedGroups) { group in
                        CarouselItemView(
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
            .onReceive({ () -> AnyPublisher<([StoriesGroupModel], String?), Never> in
                stateManager.$state
                    .map(\.groups)
                    .removeDuplicates()
                    .map(sortGroups)
                    .delay(for: .seconds(0.3), scheduler: DispatchQueue.main)
                    .combineLatest(
                        stateManager.$state
                            .map(\.selectedGroupId)
                            .removeDuplicates()
                            .delay(for: .seconds(0.3), scheduler: DispatchQueue.main)
                    )
                    .eraseToAnyPublisher()
            }()) { sortedGroups, groupId in
                displayedGroups = sortedGroups

                if let groupId {
                    Task {
                        proxy.scrollTo(groupId, anchor: .center)
                    }
                }
            }
        }
        .background(configuration.backgroundColor)
    }

    private func sortGroups(_ groups: [StoriesGroupModel]) -> [StoriesGroupModel] {
        let firstGroups = groups.filter { $0.pages.contains(where: { !$0.isViewed }) }.sorted { $0.id < $1.id }
        let viewedGroups = groups.filter { $0.pages.allSatisfy(\.isViewed) }.sorted { $0.id < $1.id }
        return firstGroups + viewedGroups
    }
}
