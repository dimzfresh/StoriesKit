import SwiftUI
import Combine

/// Protocol for Stories view model
protocol IStoriesViewModel: ObservableObject {
    var state: Stories.ViewState { get }
    var stateManager: StoriesStateManager { get }

    func send(_ event: Stories.ViewEvent)

    init(
        groups: [StoriesGroupModel],
        stateManager: StoriesStateManager
    )
}

extension Stories {
    /// View model for managing Stories state and logic
    final class ViewModel: IStoriesViewModel {
        @Published private(set) var state: ViewState
        @Published private(set) var stateManager: StoriesStateManager

        private let viewEvent = PassthroughSubject<ViewEvent, Never>()
        private var subscriptions = Set<AnyCancellable>()

        private var timer: CountDownTimer?

        init(
            groups: [StoriesGroupModel],
            stateManager: StoriesStateManager
        ) {
            let initialGroupIndex = groups.firstIndex(where: { $0.id == stateManager.state.selectedGroupId }) ?? 0
            let initialGroup = groups[initialGroupIndex]
            let initialPage = initialGroup.pages.first { !$0.isViewed } ?? initialGroup.pages.first

            self.state = .init(
                groups: groups,
                progressBar: .init(
                    progress: 0,
                    duration: initialPage?.duration ?? 5
                ),
                current: initialPage.map { .init(group: initialGroup, page: $0) },
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

        if let current = state.current {
            stateManager.send(.didViewPage(current.group.id, current.page.id))
        }
    }

    private func resumeCurrentPageTimer() {
        guard let currentPage = getCurrentPage() else { return }

        timer?.resume(duration: currentPage.duration)
    }

    private func updateProgress(_ progress: CGFloat) {
        guard let current = state.current else { return }

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: progress,
                duration: current.page.duration
            ),
            current: current,
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
        } else {
            resumeCurrentPageTimer()
        }
    }

    func switchToGroup(_ direction: Stories.ViewEvent.GroupDirection) {
        guard let currentGroup = state.current?.group,
              let currentIndex = state.groups.firstIndex(where: { $0.id == currentGroup.id }) else { return }

        var group: StoriesGroupModel?

        if direction == .next, canMoveToNextGroup() {
            group = state.groups[currentIndex + 1]
        } else if direction == .previous, canMoveToPreviousGroup() {
            group = state.groups[currentIndex - 1]
        }

        guard let group else { return }

        let updatedGroup = state.groups.first(where: { $0.id == group.id }) ?? group
        let startPage = updatedGroup.pages.first { !$0.isViewed } ?? updatedGroup.pages.first

        stateManager.send(.didSwitchGroup(group.id))

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: startPage?.duration ?? 5
            ),
            current: startPage.map { .init(group: updatedGroup, page: $0) },
            isPaused: false
        )
        startCurrentPageTimer()
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentPage() -> StoriesPageModel? {
        state.current?.page
    }
    
    private func canMoveToNextPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0.id == current.page.id }) ?? 0
        return currentPageIndex < current.group.pages.count - 1
    }
    
    private func canMoveToNextGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0.id == current.group.id }) ?? 0
        return currentGroupIndex < state.groups.count - 1
    }
    
    private func canMoveToPreviousPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0.id == current.page.id }) ?? 0
        return currentPageIndex > 0
    }
    
    private func canMoveToPreviousGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0.id == current.group.id }) ?? 0
        return currentGroupIndex > 0
    }
    
    private func isValidGroupIndex(_ groupIndex: Int) -> Bool {
        groupIndex >= 0 && groupIndex < state.groups.count
    }
    
    private func moveToNextPage() {
        guard let current = state.current else { return }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0.id == current.page.id }) ?? 0
        let nextPageIndex = currentPageIndex + 1

        updatePagesViewedState(pageIndex: currentPageIndex, markAsViewed: true)

        let nextPage = state.groups.first(where: { $0.id == current.group.id })?.pages[nextPageIndex]
        switchToPage(nextPage)
    }
    
    private func moveToPreviousPage() {
        guard let current = state.current else { return }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0.id == current.page.id }) ?? 0
        let prevPageIndex = currentPageIndex - 1

        updatePagesViewedState(pageIndex: currentPageIndex, markAsViewed: false)

        let prevPage = state.groups.first(where: { $0.id == current.group.id })?.pages[prevPageIndex]
        switchToPage(prevPage)
    }
    
    private func updatePagesViewedState(pageIndex: Int, markAsViewed: Bool) {
        var groups = state.groups
        guard let groupIndex = groups.firstIndex(where: { $0.id == state.current?.group.id }) else { return }

        let group = groups[groupIndex]
        var pages = groups[groupIndex].pages
        
        if markAsViewed {
            for index in 0...pageIndex {
                pages[index] = pages[index].updateViewed(true)
            }
        } else {
            pages[pageIndex] = pages[pageIndex].updateViewed(false)
            if pageIndex - 1 == 0 {
                pages[0] = pages[0].updateViewed(false)
            }
        }

        groups[groupIndex] = .init(
            id: group.id,
            title: group.title,
            avatarImage: group.avatarImage,
            pages: pages,
            isViewed: group.isViewed
        )
        
        state = .init(
            groups: groups,
            progressBar: state.progressBar,
            current: state.current,
            isPaused: state.isPaused
        )
    }
    
    private func switchToPage(_ page: StoriesPageModel?) {
        guard let page, let current = state.current else { return }
        
        let updatedGroup = state.groups.first(where: { $0.id == current.group.id }) ?? current.group
        
        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: page.duration
            ),
            current: .init(
                group: updatedGroup,
                page: page
            ),
            isPaused: false
        )
        startCurrentPageTimer()
    }
}
