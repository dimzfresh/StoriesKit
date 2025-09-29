import SwiftUI
import UIKit

extension Stories {
    /// Main content view for Stories with navigation and gesture handling
    struct `View`<ViewModel: ObservableObject>: SwiftUI.View where ViewModel: IStoriesViewModel {
        @StateObject private var viewModel: ViewModel

        @State private var verticalDragOffset: CGFloat = 0
        @State private var dragDirection: DragDirection?
        @State private var isFirstAppearance = true

        let avatarNamespace: Namespace.ID

        /// Direction of drag gesture
        enum DragDirection {
            case horizontal
            case vertical
        }

        /// Direction of swipe gesture
        enum SwipeDirection {
            case left
            case right
        }

        var body: some SwiftUI.View {
            ZStack {
                Color(viewModel.state.groups.first?.pages.first?.backgroundColor ?? .black)
                    .opacity(getBackgroundOpacity())
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    if isFirstAppearance, let group = viewModel.state.current?.selectedGroup {
                        PageView(
                            group: group,
                            currentPage: getCurrentPageForGroup(group),
                            verticalOffset: verticalDragOffset,
                            progressBars: getProgressBarsForGroup(group),
                            onButtonAction: handleButtonAction,
                            isCurrentGroup: viewModel.state.current?.selectedGroup.id == group.id,
                            onTapPrevious: {
                                viewModel.send(.didTapPrevious)
                            },
                            onTapNext: {
                                viewModel.send(.didTapNext)
                            },
                            avatarNamespace: avatarNamespace,
                            stateManager: viewModel.stateManager
                        )
                        .onFirstAppear {
                            isFirstAppearance = false
                        }
                    } else {
                        createScrollView(geometry: geometry)
                    }
                }
                .ignoresSafeArea()
            }
            .onFirstAppear {
                viewModel.send(.didAppear)
            }
        }

        public init(
            viewModel: ViewModel,
            avatarNamespace: Namespace.ID
        ) {
            _viewModel = .init(wrappedValue: viewModel)
            self.avatarNamespace = avatarNamespace
        }

        private func createScrollView(geometry: GeometryProxy) -> some SwiftUI.View {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(viewModel.state.groups, id: \.id) { group in
                                groupView(group: group)
                                    .frame(
                                        width: geometry.size.width,
                                        height: geometry.size.height
                                    )
                                    .id(group.id)
                            }
                        }
                    }
                    .onFirstAppear {
                        handleScrollViewAppear(proxy: proxy)
                    }
                    .onChange(of: viewModel.state.current) { current in
                        guard let groupId = current?.selectedGroup.id else { return }

                        handleCurrentChange(proxy: proxy, groupId: groupId)
                    }
                    .disabled(dragDirection == .vertical)
                    .ignoresSafeArea()
                    .offset(y: verticalDragOffset)
                    .simultaneousGesture(createDragGesture(proxy: proxy))
                    .onLongPressGesture(
                        minimumDuration: Constants.longPressDuration,
                        perform: {},
                        onPressingChanged: handleLongPressChange
                    )
                }
            }
        }

        private func groupView(group: StoriesGroupModel) -> some SwiftUI.View {
            PageView(
                group: group,
                currentPage: getCurrentPageForGroup(group),
                verticalOffset: verticalDragOffset,
                progressBars: getProgressBarsForGroup(group),
                onButtonAction: handleButtonAction,
                isCurrentGroup: viewModel.state.current?.selectedGroup.id == group.id,
                onTapPrevious: {
                    viewModel.send(.didTapPrevious)
                },
                onTapNext: {
                    viewModel.send(.didTapNext)
                },
                avatarNamespace: avatarNamespace,
                stateManager: viewModel.stateManager
            )
        }

        // MARK: - Button Actions

        private func handleButtonAction(_ actionType: StoriesPageModel.Button.ActionType) {
            switch actionType {
            case .next:
                viewModel.send(.didTapNext)
            case .close:
                Task {
                    withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                        verticalDragOffset = UIScreen.main.bounds.height * 0.3
                    }

                    viewModel.send(.didDismiss)
                }
            case let .link(url):
                viewModel.send(.didTapButtonLink(url))
            }
        }

        // MARK: - Vertical Swipe Handlers

        private func handleVerticalSwipeStart(
            translation: CGFloat,
            velocity: CGFloat
        ) {
            let limitedTranslation = max(translation, 0)
            verticalDragOffset = limitedTranslation
        }

        private func handleVerticalSwipeEnd(
            translation: CGFloat,
            velocity: CGFloat
        ) {
            let threshold = UIScreen.main.bounds.height * Constants.verticalSwipeThreshold
            let dismissVelocity = Constants.dismissVelocity
            let animationDuration = Constants.animationDuration

            if translation > threshold || velocity > dismissVelocity {
                viewModel.send(.didDismiss)
            } else {
                Task {
                    withAnimation(.easeInOut(duration: Constants.returnAnimationDuration)) {
                        verticalDragOffset = 0
                    }
                }
            }
        }

        private func getCurrentPageForGroup(_ group: StoriesGroupModel) -> StoriesPageModel? {
            if viewModel.state.current?.selectedGroup.id == group.id {
                return viewModel.state.current?.activePages[group.id]
            } else {
                if let activePage = viewModel.state.current?.activePages[group.id] {
                    return activePage
                }
                return group.pages.first { !$0.isViewed } ?? group.pages.first
            }
        }

        private func getProgressBarsForGroup(_ group: StoriesGroupModel) -> [Stories.ViewState.ProgressBar] {
            if group.id == viewModel.state.current?.selectedGroup.id {
                group.pages.map { page in
                    let isCurrent = page.id == viewModel.state.current?.activePages[group.id]?.id
                    let isViewed = isPageCompleted(page, in: group)

                    return .init(
                        progress: isViewed ? 1.0 : (isCurrent ? viewModel.state.progressBar.progress : 0.0),
                        duration: page.duration
                    )
                }
            } else {
                group.pages.map { page in
                    .init(
                        progress: page.isViewed ? 1.0 : 0.0,
                        duration: page.duration
                    )
                }
            }
        }

        private func getBackgroundOpacity() -> Double {
            guard verticalDragOffset > 0 else { return 1.0 }

            let threshold = UIScreen.main.bounds.height * 0.3
            let progress = min(verticalDragOffset / threshold, 1.0)

            let minOpacity = 0.2

            return 1.0 - (progress * (1.0 - minOpacity))
        }
        
        // MARK: - Helper Methods for New ViewState
        
        private func isPageCompleted(_ page: StoriesPageModel, in group: StoriesGroupModel) -> Bool {
            guard let current = viewModel.state.current,
                  let activePage = current.activePages[group.id],
                  let currentPageIndex = group.pages.firstIndex(where: { $0.id == activePage.id }),
                  let pageIndex = group.pages.firstIndex(where: { $0.id == page.id }) else {
                return false
            }

            return pageIndex < currentPageIndex
        }

        // MARK: - Gesture Creation

        private func createDragGesture(proxy: ScrollViewProxy) -> some Gesture {
            DragGesture(minimumDistance: Constants.dragThreshold)
                .onChanged { value in
                    handleDragChanged(value, proxy: proxy)
                }
                .onEnded { value in
                    handleDragEnded(value, proxy: proxy)
                }
        }

        // MARK: - Event Handlers

        private func handleScrollViewAppear(proxy: ScrollViewProxy) {
            guard let current = viewModel.state.current else { return }

            proxy.scrollTo(current.selectedGroup.id, anchor: .center)
        }

        private func handleCurrentChange(
            proxy: ScrollViewProxy,
            groupId: String
        ) {
            Task {
                withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                    proxy.scrollTo(groupId, anchor: .center)
                }
            }
        }

        private func handleLongPressChange(_ isPressing: Bool) {
            if isPressing {
                viewModel.send(.didPauseTimer)
            } else {
                viewModel.send(.didResumeTimer)
            }
        }

        private func handleDragChanged(
            _ value: DragGesture.Value,
            proxy: ScrollViewProxy
        ) {
            viewModel.send(.didPauseTimer)

            if let dragDirection {
                handleDragWithDirection(
                    dragDirection,
                    translation: value.translation,
                    velocity: value.velocity
                )
            } else {
                let newDirection = determineDragDirection(value.translation)
                dragDirection = newDirection

                if let newDirection {
                    handleDragWithDirection(
                        newDirection,
                        translation: value.translation,
                        velocity: value.velocity
                    )
                }
            }
        }

        private func handleDragEnded(
            _ value: DragGesture.Value,
            proxy: ScrollViewProxy
        ) {
            guard let dragDirection else { return }

            switch dragDirection {
            case .vertical:
                handleVerticalSwipeEnd(
                    translation: value.translation.height,
                    velocity: value.velocity.height
                )
            case .horizontal:
                handleHorizontalSwipe(
                    translation: value.translation.width,
                    velocity: value.velocity.width,
                    proxy: proxy
                )
            }

            viewModel.send(.didResumeTimer)
            self.dragDirection = nil
        }

        private func handleHorizontalSwipe(
            translation: CGFloat,
            velocity: CGFloat,
            proxy: ScrollViewProxy
        ) {
            guard dragDirection == .horizontal else { return }

            let shouldSwitch = abs(translation) > Constants.swipeThreshold
            || abs(velocity) > Constants.velocityThreshold

            if shouldSwitch {
                performGroupSwitch(translation: translation)
            } else {
                scrollToCurrentGroup(
                    swipeDirection: translation > 0 ? .right : .left,
                    proxy: proxy
                )
            }
        }

        private func scrollToCurrentGroup(
            swipeDirection: SwipeDirection,
            proxy: ScrollViewProxy
        ) {
            guard let current = viewModel.state.current else { return }

            Task {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    proxy.scrollTo(current.selectedGroup.id, anchor: .center)
                }
            }
        }

        // MARK: - Helper Methods

        private func handleDragWithDirection(
            _ direction: DragDirection,
            translation: CGSize,
            velocity: CGSize
        ) {
            switch direction {
            case .vertical:
                handleVerticalSwipeStart(
                    translation: translation.height,
                    velocity: velocity.height
                )
            case .horizontal:
                break
            }
        }

        private func performGroupSwitch(translation: CGFloat) {
            viewModel.send(.didSwitchGroup(translation > 0 ? .previous : .next))
        }

        private func determineDragDirection(_ translation: CGSize) -> DragDirection? {
            let horizontalDistance = abs(translation.width)
            let verticalDistance = abs(translation.height)

            if horizontalDistance < Constants.dragThreshold && verticalDistance < Constants.dragThreshold {
                return nil
            }

            let angle = atan2(verticalDistance, horizontalDistance)
            let angleInDegrees = angle * 180 / .pi

            return angleInDegrees > Constants.angleThreshold ? .vertical : .horizontal
        }
    }

    private enum Constants {
        static let dragThreshold: CGFloat = 10
        static let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.3
        static let velocityThreshold: CGFloat = 500
        static let animationDuration: Double = 0.25
        static let returnAnimationDuration: Double = 0.15
        static let longPressDuration: Double = 0.1
        static let angleThreshold: Double = 45.0
        static let verticalSwipeThreshold: CGFloat = 0.3
        static let dismissVelocity: CGFloat = 300
    }
}
