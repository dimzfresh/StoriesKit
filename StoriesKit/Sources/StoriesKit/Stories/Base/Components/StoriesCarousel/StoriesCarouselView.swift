import SwiftUI
import Combine

/// A customizable carousel view for displaying story groups with progress indicators
public struct StoriesCarouselView: View {
    @ObservedObject private var stateManager: StoriesStateManager
    private let avatarNamespace: Namespace.ID
    private let configuration: StoriesCarouselConfiguration

    @State private var displayedGroups: [StoriesGroupModel] = []

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
            .onReceive({ () -> AnyPublisher<([StoriesGroupModel], String?), Never> in
                stateManager.$state
                    .map(\.groups)
                    .removeDuplicates()
                    .map(StoriesGroupModel.sortedForDisplay)
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

}
