import SwiftUI
import Combine

/// Protocol for Stories view model
protocol IStoriesViewModel: ObservableObject {
    var state: Stories.ViewState { get }
    var stateManager: StoriesStateManager { get }

    func send(_ event: Stories.ViewEvent)

    init(stateManager: StoriesStateManager)
}

extension Stories {
    /// View model for managing Stories state and logic
    final class ViewModel: IStoriesViewModel {
        @Published private(set) var state: ViewState
        @Published private(set) var stateManager: StoriesStateManager

        private let viewEvent = PassthroughSubject<ViewEvent, Never>()
        private var subscriptions = Set<AnyCancellable>()

        private var timer: CountDownTimer?

        init(stateManager: StoriesStateManager) {
            let groups = stateManager.state.groups
            let initialGroupIndex = groups.firstIndex(where: { $0.id == stateManager.state.selectedGroupId }) ?? 0
            let initialGroup = groups.indices.contains(initialGroupIndex) ? groups[initialGroupIndex] : groups.first!
            let initialPage = initialGroup.pages.first { !$0.isViewed } ?? initialGroup.pages.first

            let activePages = Dictionary(uniqueKeysWithValues: groups.map { group in
                let activePage = group.pages.first { !$0.isViewed } ?? group.pages.first
                return (group.id, activePage!)
            })
            
            self.state = .init(
                groups: groups,
                progressBar: .init(
                    progress: 0,
                    duration: initialPage?.duration ?? 5
                ),
                current: .init(
                    selectedGroup: initialGroup,
                    activePages: activePages
                ),
                isPaused: false
            )
            self.stateManager = stateManager

            self.timer = .init(
                onProgressUpdate: { [weak self] progress in
                    self?.updateProgress(progress)
                },
                onStoryComplete: { [weak self] in
                    self?.handleStoryComplete()
                }
            )

            setupBindings()
        }

        deinit {
            timer?.stop()
            // Останавливаем видео плеер при уничтожении ViewModel
            VideoPlayerStateManager.shared.setIdle()
        }

        func send(_ event: ViewEvent) {
            viewEvent.send(event)
        }
    }
}

private extension Stories.ViewModel {
    func setupBindings() {
        viewEvent.sink { [weak self] event in
            guard let self else { return }

            handleEvent(event)
        }
        .store(in: &subscriptions)

        stateManager.$state.sink { [weak self] managerState in
            guard let self else { return }

            var newGroups = managerState.groups

            guard let current = state.current else { return }

            let updatedSelectedGroup = newGroups.first(where: { $0.id == current.selectedGroup.id }) ?? current.selectedGroup

            var updatedActivePages: [String: StoriesPageModel] = [:]
            for (groupId, activePage) in current.activePages {
                if let group = newGroups.first(where: { $0.id == groupId }),
                   let matched = group.pages.first(where: { $0.id == activePage.id }) {
                    updatedActivePages[groupId] = matched
                } else {
                    updatedActivePages[groupId] = activePage
                }
            }

            updateState(
                groups: newGroups,
                progress: state.progressBar.progress,
                duration: getCurrentPage()?.duration ?? state.progressBar.duration,
                selectedGroup: updatedSelectedGroup,
                activePages: updatedActivePages,
                isPaused: state.isPaused
            )
        }
        .store(in: &subscriptions)
    }

    func handleEvent(_ event: Stories.ViewEvent) {
        switch event {
        case .didAppear:
            startCurrentPageTimer()
        case .didTapNext:
            handleNextTap()
        case .didTapPrevious:
            handlePreviousTap()
        case let .didSwitchGroup(direction):
            switchToGroup(direction)
        case .didDismiss:
            // Останавливаем видео плеер при закрытии StoriesKit
            VideoPlayerStateManager.shared.setIdle()
            stateManager.send(.didToggleGroup(nil))
        case .didPauseTimer:
            timer?.pause()
        case .didResumeTimer:
            resumeCurrentPageTimer()
        case let .didTapButtonLink(url):
            stateManager.send(.didOpenLink(url.absoluteString))
        }
    }

    // MARK: - Timer Management

    private func startCurrentPageTimer() {
        guard let currentPage = getCurrentPage() else { return }

        timer?.start(duration: currentPage.duration)

        // Запускаем видео только если текущая страница - видео
        if isCurrentPageVideo() {
            VideoPlayerStateManager.shared.setPlaying()
        } else {
            VideoPlayerStateManager.shared.setIdle()
        }

        if let current = state.current, let pageId = getCurrentPage()?.id {
            stateManager.send(.didViewPage(
                current.selectedGroup.id,
                pageId
            ))
        }
    }

    private func resumeCurrentPageTimer() {
        guard let currentPage = getCurrentPage() else { return }

        timer?.resume(duration: currentPage.duration)

        // Возобновляем видео только если текущая страница - видео
        if isCurrentPageVideo() {
            VideoPlayerStateManager.shared.setPlaying()
        } else {
            VideoPlayerStateManager.shared.setIdle()
        }
    }

    private func updateProgress(_ progress: CGFloat) {
        guard let current = state.current else { return }

        updateState(
            groups: state.groups,
            progress: progress,
            duration: getCurrentPage()?.duration ?? 5,
            selectedGroup: current.selectedGroup,
            activePages: current.activePages,
            isPaused: false
        )
    }

    private func handleStoryComplete() {
        handleNextTap()
    }

    // MARK: - Navigation

    func handleNextTap() {
        if canMoveToNextPage() {
            moveToNextPage()
        } else if canMoveToNextGroup() {
            switchToGroup(.next)
        } else {
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

    func handleLongPress(_ pressing: Bool) {
        if pressing {
            timer?.pause()

            VideoPlayerStateManager.shared.setPaused()
        } else {
            resumeCurrentPageTimer()
        }
    }

    func switchToGroup(_ direction: Stories.ViewEvent.GroupDirection) {
        guard let currentGroup = state.current?.selectedGroup,
              let currentIndex = state.groups.firstIndex(where: { $0.id == currentGroup.id }) else { return }
        
        // Останавливаем видео при переключении групп
        VideoPlayerStateManager.shared.setIdle()

        var group: StoriesGroupModel?

        if direction == .next, canMoveToNextGroup() {
            group = state.groups[currentIndex + 1]
        } else if direction == .previous, canMoveToPreviousGroup() {
            group = state.groups[currentIndex - 1]
        }

        guard let group else { return }

        let updatedGroup = state.groups.first(where: { $0.id == group.id }) ?? group
        let lastActiveForGroup = state.current?.activePages[group.id]
        let startPage: StoriesPageModel?
        
        if let lastActiveForGroup,
           let lastActiveIndex = updatedGroup.pages.firstIndex(where: { $0.id == lastActiveForGroup.id }) {
            startPage = updatedGroup.pages[lastActiveIndex]
        } else {
            startPage = updatedGroup.pages.first { !$0.isViewed } ?? updatedGroup.pages.first
        }

        stateManager.send(.didSwitchGroup(group.id))

        let updatedActivePages = setActivePage(for: group.id, page: startPage)
        updateState(
            groups: state.groups,
            progress: 0,
            duration: startPage?.duration ?? 5,
            selectedGroup: updatedGroup,
            activePages: updatedActivePages,
            isPaused: false
        )
        startCurrentPageTimer()
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentPage() -> StoriesPageModel? {
        guard let current = state.current else { return nil }

        return current.activePages[current.selectedGroup.id]
    }
    
    private func canMoveToNextPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.selectedGroup.pages.firstIndex(where: { $0.id == getCurrentPage()?.id }) ?? 0
        return currentPageIndex < current.selectedGroup.pages.count - 1
    }
    
    private func canMoveToNextGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0.id == current.selectedGroup.id }) ?? 0
        return currentGroupIndex < state.groups.count - 1
    }
    
    private func canMoveToPreviousPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.selectedGroup.pages.firstIndex(where: { $0.id == getCurrentPage()?.id }) ?? 0
        return currentPageIndex > 0
    }
    
    private func canMoveToPreviousGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0.id == current.selectedGroup.id }) ?? 0
        return currentGroupIndex > 0
    }
    
    private func isValidGroupIndex(_ groupIndex: Int) -> Bool {
        groupIndex >= 0 && groupIndex < state.groups.count
    }
    
    private func moveToNextPage() {
        guard let current = state.current else { return }

        let currentPageIndex = current.selectedGroup.pages.firstIndex(where: { $0.id == getCurrentPage()?.id }) ?? 0
        let nextPageIndex = currentPageIndex + 1

        if let groupId = state.current?.selectedGroup.id, let pageId = getCurrentPage()?.id {
            stateManager.send(.didViewPage(groupId, pageId))
        }

        let nextPage = state.groups.first(where: { $0.id == current.selectedGroup.id })?.pages[nextPageIndex]
        switchToPage(nextPage)
    }
    
    private func moveToPreviousPage() {
        guard let current = state.current else { return }

        let currentPageIndex = current.selectedGroup.pages.firstIndex(where: { $0.id == getCurrentPage()?.id }) ?? 0
        let prevPageIndex = currentPageIndex - 1

        let prevPage = state.groups.first(where: { $0.id == current.selectedGroup.id })?.pages[prevPageIndex]
        switchToPage(prevPage)
    }
    
    
    
    private func switchToPage(_ page: StoriesPageModel?) {
        guard let page, let current = state.current else { return }
        
        // Останавливаем видео при переключении страниц
        VideoPlayerStateManager.shared.setIdle()
        
        let updatedGroup = state.groups.first(where: { $0.id == current.selectedGroup.id }) ?? current.selectedGroup
        let updatedActivePages = setActivePage(for: updatedGroup.id, page: page)
        updateState(
            groups: state.groups,
            progress: 0,
            duration: page.duration,
            selectedGroup: updatedGroup,
            activePages: updatedActivePages,
            isPaused: false
        )
        startCurrentPageTimer()
    }

    private func setActivePage(
        for groupId: String,
        page: StoriesPageModel?
    ) -> [String: StoriesPageModel] {
        var dictionary = state.current?.activePages ?? [:]
        if let page {
            dictionary[groupId] = page
        }
        return dictionary
    }

    private func updateState(
        groups: [StoriesGroupModel],
        progress: CGFloat,
        duration: TimeInterval,
        selectedGroup: StoriesGroupModel,
        activePages: [String: StoriesPageModel],
        isPaused: Bool
    ) {
        state = .init(
            groups: groups,
            progressBar: .init(
                progress: progress,
                duration: duration
            ),
            current: .init(
                selectedGroup: selectedGroup,
                activePages: activePages
            ),
            isPaused: isPaused
        )
    }
    
    private func isCurrentPageVideo() -> Bool {
        guard let currentPage = getCurrentPage() else { return false }
        
        switch currentPage.mediaSource.media {
        case .video:
            return true
        case .image:
            return false
        }
    }
}
