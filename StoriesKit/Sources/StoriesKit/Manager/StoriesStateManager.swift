import Combine
import Foundation
import SwiftUI

/// State manager for Stories coordination and state management
public final class StoriesStateManager: ObservableObject {
    @Published public private(set) var state: State = .default
    let model: StoriesModel

    public init(model: StoriesModel) {
        self.model = model
        state.groups = model.groups
    }
    
    /// Send event to state manager
    public func send(_ event: Event) {
        switch event {
        case let .didToggleGroup(groupId):
            state.event = event

            Task { @MainActor in
                if let groupId {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        state.selectedGroupId = groupId
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.state.selectedGroupId = nil
                    }
                }

                await try? Task.sleep(UInt64(0.3 * Double(NSEC_PER_SEC)))

                let firstGroups = state.groups.filter { $0.pages.contains(where: { !$0.isViewed }) }.sorted { $0.id < $1.id }
                let viewedGroups = state.groups.filter { $0.pages.allSatisfy(\.isViewed) }.sorted { $0.id < $1.id }
                state.groups = firstGroups + viewedGroups
            }
        case let .didSwitchGroup(groupId):
            state.event = event
            state.selectedGroupId = groupId
        case let .didOpenLink(url):
            state.event = event
        case let .didViewPage(groupId, pageId):
            markPageAsViewed(groupId: groupId, pageId: pageId)

            state.event = event
            state.selectedGroupId = groupId
        }
    }

    private func markPageAsViewed(groupId: String, pageId: String) {
        guard let groupIndex = state.groups.firstIndex(where: { $0.id == groupId }),
              let pageIndex = state.groups[groupIndex].pages.firstIndex(where: { $0.id == pageId }) else { return }

        var groups = state.groups
        var pages = groups[groupIndex].pages

        let page = pages[pageIndex]
        pages[pageIndex] = page.updateViewed(true)
        let group = groups[groupIndex]

        groups[groupIndex] = .init(
            id: group.id,
            title: group.title,
            avatarImage: group.avatarImage,
            pages: pages
        )

        state.groups = groups
    }

    public enum Event: Hashable {
        case didToggleGroup(String?)
        case didSwitchGroup(String)
        case didOpenLink(String)
        case didViewPage(String, String)
    }

    public struct State: Hashable {
        public var isShown: Bool { selectedGroupId != nil }
        public var selectedGroupId: String?
        public var groups: [StoriesGroupModel]
        public var event: Event?

        init(
            groups: [StoriesGroupModel],
            selectedGroupId: String? = nil
        ) {
            self.selectedGroupId = selectedGroupId
            self.groups = groups
        }

        static let `default` = Self(groups: [])
    }
}
