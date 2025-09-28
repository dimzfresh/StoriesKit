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
            let initialPage = initialGroup.pages.first

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
            startCurrentStoryTimer()
        case .didTapNext:
            handleNextTap()
        case .didTapPrevious:
            handlePreviousTap()
        case let .didSwitchGroup(groupId):
            switchToGroup(groupId)
        case let .didSwitchPage(pageId):
            switchToPage(pageId)
        case .didDismiss:
            stateManager.send(.didToggleGroup(nil))
        case .didPauseTimer:
            timer?.pause()
        case .didResumeTimer:
            resumeCurrentStoryTimer()
        case let .didTapButtonLink(url):
            stateManager.send(.didOpenLink(url.absoluteString))
        }
    }

    // MARK: - Timer Management

    private func startCurrentStoryTimer() {
        guard let currentStory = getCurrentStory() else { return }

        timer?.start(duration: currentStory.duration)
    }

    private func resumeCurrentStoryTimer() {
        guard let currentStory = getCurrentStory() else { return }

        timer?.resume(duration: currentStory.duration)
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
            guard let current = state.current else { return }

            let currentGroupIndex = state.groups.firstIndex(where: { $0 == current.group }) ?? 0
            let nextGroup = state.groups[currentGroupIndex + 1]
            switchToGroup(nextGroup.id)
        } else {
            send(.didDismiss)
        }
    }

    func handlePreviousTap() {
        if canMoveToPreviousPage() {
            moveToPreviousPage()
        } else if canMoveToPreviousGroup() {
            guard let current = state.current else { return }

            let currentGroupIndex = state.groups.firstIndex(where: { $0 == current.group }) ?? 0
            let previousGroup = state.groups[currentGroupIndex - 1]
            switchToGroup(previousGroup.id)
        }
    }

    func handleLongPress(_ pressing: Bool) {
        if pressing {
            timer?.pause()
        } else {
            resumeCurrentStoryTimer()
        }
    }

    func switchToGroup(_ groupId: String) {
        guard let group = state.groups.first(where: { $0.id == groupId }) else { return }

        timer?.stop()

        let firstPage = group.pages.first

        stateManager.send(.didSwitchGroup(groupId))

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: firstPage?.duration ?? 5
            ),
            current: firstPage.map { .init(group: group, page: $0) },
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    func switchToPage(_ pageId: String) {
        guard let current = state.current,
              let targetPage = current.group.pages.first(where: { $0.id == pageId }) else { return }

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: targetPage.duration
            ),
            current: .init(
                group: current.group,
                page: targetPage
            ),
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentStory() -> StoriesPageModel? {
        state.current?.page
    }
    
    private func canMoveToNextPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0 == current.page }) ?? 0
        return currentPageIndex < current.group.pages.count - 1
    }
    
    private func canMoveToNextGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0 == current.group }) ?? 0
        return currentGroupIndex < state.groups.count - 1
    }
    
    private func canMoveToPreviousPage() -> Bool {
        guard let current = state.current else { return false }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0 == current.page }) ?? 0
        return currentPageIndex > 0
    }
    
    private func canMoveToPreviousGroup() -> Bool {
        guard let current = state.current else { return false }

        let currentGroupIndex = state.groups.firstIndex(where: { $0 == current.group }) ?? 0
        return currentGroupIndex > 0
    }
    
    private func isValidGroupIndex(_ groupIndex: Int) -> Bool {
        groupIndex >= 0 && groupIndex < state.groups.count
    }
    
    private func moveToNextPage() {
        guard let current = state.current else { return }

        let currentPageIndex = current.group.pages.firstIndex(where: { $0 == current.page }) ?? 0
        let nextPageIndex = currentPageIndex + 1
        let nextPage = current.group.pages[nextPageIndex]

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: nextPage.duration
            ),
            current: .init(
                group: current.group,
                page: nextPage
            ),
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    private func moveToPreviousPage() {
        guard let current = state.current else { return }
        let currentPageIndex = current.group.pages.firstIndex(where: { $0 == current.page }) ?? 0
        let prevPageIndex = currentPageIndex - 1
        let prevPage = current.group.pages[prevPageIndex]

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: prevPage.duration
            ),
            current: .init(
                group: current.group,
                page: prevPage
            ),
            isPaused: false
        )
        startCurrentStoryTimer()
    }
}
