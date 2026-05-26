import Foundation

extension Stories.ViewModel {
    func handleNextTap() {
        if canMoveToNextPage() {
            moveToNextPage()
        } else if canMoveToNextGroup() {
            switchToGroup(.next)
        } else {
            markCurrentPageViewed()
            send(.didDismiss)
        }
    }

    func handlePreviousTap() {
        if canMoveToPreviousPage() {
            moveToPreviousPage()
        } else if canMoveToPreviousGroup() {
            switchToGroup(.previous)
        }
    }

    func switchToGroup(_ direction: Stories.ViewEvent.GroupDirection) {
        guard let currentGroup = state.current?.selectedGroup,
              let currentIndex = sessionGroups.firstIndex(where: { $0.id == currentGroup.id }) else { return }

        if direction == .next {
            markCurrentPageViewed()
        }

        stopActivePlayback()

        var group: StoriesGroupModel?

        if direction == .next, canMoveToNextGroup() {
            group = sessionGroups[currentIndex + 1]
        } else if direction == .previous, canMoveToPreviousGroup() {
            group = sessionGroups[currentIndex - 1]
        }

        guard let group else { return }

        let updatedGroup = sessionGroups.first(where: { $0.id == group.id }) ?? group
        let lastActiveForGroup = state.current?.activePages[group.id]
        let startPage: StoriesPageModel?

        if let lastActiveForGroup,
           updatedGroup.pages.contains(where: { $0.id == lastActiveForGroup.id }) {
            startPage = lastActiveForGroup
        } else {
            startPage = updatedGroup.pages.first { !$0.isViewed } ?? updatedGroup.pages.first
        }

        stateManager.send(.didSwitchGroup(group.id))

        let updatedActivePages = setActivePage(for: group.id, page: startPage)
        updateState(
            groups: sessionGroups,
            progress: 0,
            duration: effectiveDuration(for: startPage),
            selectedGroup: updatedGroup,
            activePages: updatedActivePages,
            isPaused: false
        )
        startCurrentPageTimer()
    }

    func moveToNextPage() {
        guard let current = state.current,
              let pageIndex = currentPageIndex(in: current.selectedGroup) else { return }

        markCurrentPageViewed()

        let nextPage = sessionGroups
            .first(where: { $0.id == current.selectedGroup.id })?
            .pages[pageIndex + 1]

        switchToPage(nextPage)
    }

    func moveToPreviousPage() {
        guard let current = state.current,
              let pageIndex = currentPageIndex(in: current.selectedGroup) else { return }

        let previousPage = sessionGroups
            .first(where: { $0.id == current.selectedGroup.id })?
            .pages[pageIndex - 1]

        switchToPage(previousPage)
    }

    func switchToPage(_ page: StoriesPageModel?) {
        guard let page, let current = state.current else { return }

        stopActivePlayback()

        let updatedGroup = sessionGroups.first(where: { $0.id == current.selectedGroup.id }) ?? current.selectedGroup
        let updatedActivePages = setActivePage(for: updatedGroup.id, page: page)
        updateState(
            groups: sessionGroups,
            progress: 0,
            duration: effectiveDuration(for: page),
            selectedGroup: updatedGroup,
            activePages: updatedActivePages,
            isPaused: false
        )
        startCurrentPageTimer()
    }

    func currentPageIndex(in group: StoriesGroupModel? = nil) -> Int? {
        guard let pageId = getCurrentPage()?.id else { return nil }

        let resolvedGroup = group ?? state.current?.selectedGroup
        return resolvedGroup?.pages.firstIndex(where: { $0.id == pageId })
    }

    func canMoveToNextPage() -> Bool {
        guard let current = state.current,
              let pageIndex = currentPageIndex(in: current.selectedGroup) else { return false }

        return pageIndex < current.selectedGroup.pages.count - 1
    }

    func canMoveToNextGroup() -> Bool {
        guard let current = state.current,
              let groupIndex = sessionGroups.firstIndex(where: { $0.id == current.selectedGroup.id }) else {
            return false
        }

        return groupIndex < sessionGroups.count - 1
    }

    func canMoveToPreviousPage() -> Bool {
        guard let current = state.current,
              let pageIndex = currentPageIndex(in: current.selectedGroup) else { return false }

        return pageIndex > 0
    }

    func canMoveToPreviousGroup() -> Bool {
        guard let current = state.current,
              let groupIndex = sessionGroups.firstIndex(where: { $0.id == current.selectedGroup.id }) else {
            return false
        }

        return groupIndex > 0
    }
}
