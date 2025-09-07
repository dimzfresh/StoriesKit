import SwiftUI
import Combine

/// Protocol for Stories view model
protocol IStoriesViewModel: ObservableObject {
    var state: Stories.ViewState { get }

    func send(_ event: Stories.ViewEvent)
}

extension Stories {
    /// View model for managing Stories state and logic
    final class ViewModel: IStoriesViewModel {
        @Published var state: ViewState

        private let viewEvent = PassthroughSubject<ViewEvent, Never>()
        private var subscriptions = Set<AnyCancellable>()

        private var timer: CountDownTimer?
        private weak var delegate: IStoriesDelegate?

        init(
            groups: [StoriesGroupModel],
            delegate: IStoriesDelegate? = nil
        ) {
            self.state = .init(
                groups: groups,
                progressBar: .init(
                    progress: 0,
                    duration: groups.first?.stories.first?.duration ?? Constants.defaultStoryDuration
                ),
                groupIndex: 0,
                pageIndex: 0,
                isPaused: false
            )
            self.delegate = delegate
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
        case let .didSwitchGroup(groupIndex):
            switchToGroup(groupIndex)
        case let .didSwitchPage(pageIndex):
            switchToPage(pageIndex)
        case .didDismiss:
            delegate?.didClose()
        case let .didOpenStory(storyId):
            delegate?.didOpenStory(storyId: storyId)
        case .didPauseTimer:
            timer?.pause()
        case .didResumeTimer:
            resumeCurrentStoryTimer()
        case .didTapButtonClose:
            delegate?.didClose()
        case let .didTapButtonLink(url):
            delegate?.didOpenLink(url: url)
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
        guard let currentStory = getCurrentStory() else { return }

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: progress,
                duration: currentStory.duration
            ),
            groupIndex: state.groupIndex,
            pageIndex: state.pageIndex,
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
            switchToGroup(state.groupIndex + 1)
        } else {
            send(.didDismiss)
        }
    }

    func handlePreviousTap() {
        if canMoveToPreviousPage() {
            moveToPreviousPage()
        } else if canMoveToPreviousGroup() {
            switchToGroup(state.groupIndex - 1)
        }
    }

    func handleLongPress(_ pressing: Bool) {
        if pressing {
            timer?.pause()
        } else {
            resumeCurrentStoryTimer()
        }
    }

    func switchToGroup(_ groupIndex: Int) {
        guard isValidGroupIndex(groupIndex) else { return }

        timer?.stop()

        let firstPage = state.groups[groupIndex].stories.first

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: firstPage?.duration ?? Constants.defaultStoryDuration
            ),
            groupIndex: groupIndex,
            pageIndex: 0,
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    func switchToPage(_ pageIndex: Int) {
        guard pageIndex >= 0 && pageIndex < state.groups[state.groupIndex].stories.count else { return }
        
        let targetPage = state.groups[state.groupIndex].stories[pageIndex]
        
        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: targetPage.duration
            ),
            groupIndex: state.groupIndex,
            pageIndex: pageIndex,
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentStory() -> StoriesPageModel? {
        guard state.groupIndex < state.groups.count,
              state.pageIndex < state.groups[state.groupIndex].stories.count else {
            return nil
        }

        return state.groups[state.groupIndex].stories[state.pageIndex]
    }
    
    private func canMoveToNextPage() -> Bool {
        state.pageIndex < state.groups[state.groupIndex].stories.count - 1
    }
    
    private func canMoveToNextGroup() -> Bool {
        state.groupIndex < state.groups.count - 1
    }
    
    private func canMoveToPreviousPage() -> Bool {
        state.pageIndex > 0
    }
    
    private func canMoveToPreviousGroup() -> Bool {
        state.groupIndex > 0
    }
    
    private func isValidGroupIndex(_ groupIndex: Int) -> Bool {
        groupIndex >= 0 && groupIndex < state.groups.count
    }
    
    private func moveToNextPage() {
        let nextPageIndex = state.pageIndex + 1
        let nextPage = state.groups[state.groupIndex].stories[nextPageIndex]

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: nextPage.duration
            ),
            groupIndex: state.groupIndex,
            pageIndex: nextPageIndex,
            isPaused: false
        )
        startCurrentStoryTimer()
    }
    
    private func moveToPreviousPage() {
        let prevPageIndex = state.pageIndex - 1
        let prevPage = state.groups[state.groupIndex].stories[prevPageIndex]

        state = .init(
            groups: state.groups,
            progressBar: .init(
                progress: 0,
                duration: prevPage.duration
            ),
            groupIndex: state.groupIndex,
            pageIndex: prevPageIndex,
            isPaused: false
        )
        startCurrentStoryTimer()
    }
}

private enum Constants {
    static let defaultStoryDuration: Double = 4.0
}
