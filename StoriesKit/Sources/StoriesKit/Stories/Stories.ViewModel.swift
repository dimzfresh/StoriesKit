import SwiftUI
import Combine

/// Protocol for Stories view model
@MainActor
protocol IStoriesViewModel: ObservableObject {
    var state: Stories.ViewState { get }
    var stateManager: StoriesStateManager { get }
    var progressModel: StoriesProgressModel { get }

    func send(_ event: Stories.ViewEvent)
    func currentPage(for group: StoriesGroupModel) -> StoriesPageModel?
    func progressBars(for group: StoriesGroupModel) -> [Stories.ViewState.ProgressBar]

    init(stateManager: StoriesStateManager)
}

extension Stories {
    /// View model for managing Stories state and logic
    @MainActor
    final class ViewModel: IStoriesViewModel {
        @Published private(set) var state: ViewState
        @Published private(set) var stateManager: StoriesStateManager
        let progressModel = StoriesProgressModel()

        private let viewEvent = PassthroughSubject<ViewEvent, Never>()
        private var subscriptions = Set<AnyCancellable>()

        var timer: CountDownTimer?
        let sessionGroupIDs: [String]

        init(stateManager: StoriesStateManager) {
            let groups = StoriesGroupModel.sortedForDisplay(stateManager.state.groups)
            self.sessionGroupIDs = groups.map(\.id)
            self.stateManager = stateManager

            guard let initialGroup = Self.resolveInitialGroup(
                in: groups,
                selectedGroupId: stateManager.state.selectedGroupId
            ) else {
                self.state = .init(
                    groups: groups,
                    progressBar: .init(
                        progress: 0,
                        duration: 5
                    ),
                    current: nil,
                    isPaused: false
                )
                self.timer = nil
                setupBindings()
                return
            }

            let initialPage = initialGroup.pages.first { !$0.isViewed } ?? initialGroup.pages.first
            let activePages = Self.makeActivePages(for: groups)

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

            self.timer = .init(
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

extension Stories.ViewModel {
    func getCurrentPage() -> StoriesPageModel? {
        guard let current = state.current else { return nil }

        return current.activePages[current.selectedGroup.id]
    }

    func updateState(
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

            let newGroups = Self.groups(
                inOrder: sessionGroupIDs,
                from: managerState.groups
            )

            guard newGroups != state.groups, let current = state.current else { return }

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
                duration: effectiveDuration(for: getCurrentPage()),
                selectedGroup: updatedSelectedGroup,
                activePages: updatedActivePages,
                isPaused: state.isPaused
            )
        }
        .store(in: &subscriptions)

        setupPlaybackBindings()
    }

    func setupPlaybackBindings() {
        let playback = stateManager.videoManager

        playback.$progress
            .sink { [weak self] progress in
                guard let self, isCurrentPageVideo(), !state.isPaused else { return }

                updateProgress(progress)
            }
            .store(in: &subscriptions)

        playback.$contentDuration
            .compactMap { $0 }
            .sink { [weak self] duration in
                guard let self, isCurrentPageVideo(), let current = state.current else { return }

                updateState(
                    groups: state.groups,
                    progress: state.progressBar.progress,
                    duration: duration,
                    selectedGroup: current.selectedGroup,
                    activePages: current.activePages,
                    isPaused: state.isPaused
                )
            }
            .store(in: &subscriptions)

        playback.didEnd
            .sink { [weak self] in
                guard let self, isCurrentPageVideo() else { return }
                handleStoryComplete()
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
            stopActivePlayback()
            stateManager.send(.didToggleGroup(nil))
        case .didPauseTimer:
            pauseCurrentPageTimer()
        case .didResumeTimer:
            resumeCurrentPageTimer()
        case let .didTapButtonLink(url):
            stateManager.send(.didOpenLink(url.absoluteString))
        }
    }

    private static func resolveInitialGroup(
        in groups: [StoriesGroupModel],
        selectedGroupId: String?
    ) -> StoriesGroupModel? {
        guard !groups.isEmpty else { return nil }

        if let selectedGroupId,
           let selected = groups.first(where: { $0.id == selectedGroupId }) {
            return selected
        }

        return groups.first
    }

    private static func makeActivePages(for groups: [StoriesGroupModel]) -> [String: StoriesPageModel] {
        groups.reduce(into: [:]) { result, group in
            guard let page = group.pages.first(where: { !$0.isViewed }) ?? group.pages.first else { return }
            result[group.id] = page
        }
    }
}
