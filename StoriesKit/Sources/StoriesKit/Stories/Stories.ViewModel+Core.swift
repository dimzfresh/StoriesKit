import Foundation

extension Stories.ViewModel {
    static func groups(
        inOrder order: [String],
        from groups: [StoriesGroupModel]
    ) -> [StoriesGroupModel] {
        order.compactMap { id in
            groups.first { $0.id == id }
        }
    }

    var sessionGroups: [StoriesGroupModel] {
        Self.groups(
            inOrder: sessionGroupIDs,
            from: stateManager.state.groups
        )
    }

    var currentPlaybackProgress: CGFloat {
        progressModel.value
    }

    func stopActivePlayback() {
        timer?.stop()
        stateManager.videoManager.reset()
        progressModel.reset()
    }

    func markCurrentPageViewed() {
        guard let current = state.current,
              let pageId = getCurrentPage()?.id else { return }

        stateManager.send(.didViewPage(current.selectedGroup.id, pageId))
    }

    func setActivePage(
        for groupId: String,
        page: StoriesPageModel?
    ) -> [String: StoriesPageModel] {
        var dictionary = state.current?.activePages ?? [:]
        if let page {
            dictionary[groupId] = page
        }
        return dictionary
    }
}
