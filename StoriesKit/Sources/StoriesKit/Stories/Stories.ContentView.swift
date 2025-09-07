import SwiftUI
import UIKit

extension Stories {
    struct ContentView<ViewModel: ObservableObject>: View where ViewModel: IStoriesViewModel {
        @StateObject private var viewModel: ViewModel

        @State private var verticalDragOffset: CGFloat = 0
        @State private var dragDirection: DragDirection?
        @State private var isScrolling = false
        @State private var scrollViewProxy: ScrollViewProxy?

        enum DragDirection {
            case horizontal
            case vertical
        }
        
        enum SwipeDirection {
            case left
            case right
        }

        var body: some View {
                ZStack {
                Color(viewModel.state.groups.first?.stories.first?.backgroundColor ?? .black)
                    .opacity(getBackgroundOpacity())
                    .ignoresSafeArea()

                GeometryReader { geometry in
                    createScrollView(geometry: geometry)
                }
                .ignoresSafeArea()
            }
            .onAppear {
                viewModel.send(.didAppear)
            }
        }

        init(viewModel: ViewModel) {
            _viewModel = .init(wrappedValue: viewModel)
        }

        private func createScrollView(geometry: GeometryProxy) -> some View {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(Array(viewModel.state.groups.enumerated()), id: \.element.id) { index, group in
                                groupView(
                                    group: group,
                                    index: index
                                )
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )
                                .id(index)
                            }
                        }
                    }
                    .onAppear {
                        handleScrollViewAppear(proxy: proxy)
                    }
                    .onChange(of: viewModel.state.groupIndex) { newIndex in
                        handleGroupIndexChange(proxy: proxy, newIndex: newIndex)
                    }
                    .disabled(dragDirection == .vertical)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .offset(y: verticalDragOffset)
                    .simultaneousGesture(createDragGesture())
                    .onLongPressGesture(
                        minimumDuration: Constants.longPressDuration,
                        perform: {},
                        onPressingChanged: handleLongPressChange
                    )
                }
            }
        }

        private func groupView(
            group: StoriesGroupModel,
            index: Int
        ) -> some View {
            PageView(
                group: group,
                currentPage: getCurrentPageForGroup(
                    group,
                    at: index
                ),
                verticalOffset: verticalDragOffset,
                progressBars: getProgressBarsForGroup(
                    group,
                    at: index
                ),
                onButtonAction: handleButtonAction,
                isCurrentGroup: index == viewModel.state.groupIndex,
                onTapPrevious: {
                    viewModel.send(.didTapPrevious)
                },
                onTapNext: {
                    viewModel.send(.didTapNext)
                }
            )
        }

        // MARK: - Button Actions
        
        private func handleButtonAction(_ actionType: StoriesPageModel.Button.ActionType) {
            switch actionType {
            case .next:
                viewModel.send(.didTapNext)
            case .close:
                viewModel.send(.didTapButtonClose)
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
                withAnimation(.easeInOut(duration: animationDuration)) {
                    verticalDragOffset = UIScreen.main.bounds.height
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    viewModel.send(.didDismiss)
                }
            } else {
                withAnimation(.easeInOut(duration: Constants.returnAnimationDuration)) {
                    verticalDragOffset = 0
                }
            }
        }

        private func getCurrentPageForGroup(
            _ group: StoriesGroupModel,
            at index: Int
        ) -> StoriesPageModel? {
            if index == viewModel.state.groupIndex {
                guard viewModel.state.pageIndex < group.stories.count else { return nil }

                return group.stories[viewModel.state.pageIndex]
            }

            return group.stories.first
        }

        private func getProgressBarsForGroup(
            _ group: StoriesGroupModel,
            at index: Int
        ) -> [Stories.ViewState.ProgressBar] {
            if index == viewModel.state.groupIndex {
                group.stories.enumerated().map { storyIndex, story in
                        .init(
                            progress: storyIndex < viewModel.state.pageIndex ? 1.0 :
                            storyIndex == viewModel.state.pageIndex ? viewModel.state.progressBar.progress : 0.0,
                            duration: story.duration
                        )
                }
            } else {
                group.stories.map { story in
                        .init(
                            progress: 0.0,
                            duration: story.duration
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

        // MARK: - Gesture Creation

        private func createDragGesture() -> some Gesture {
            DragGesture(minimumDistance: Constants.dragThreshold)
                .onChanged(handleDragChanged)
                .onEnded(handleDragEnded)
        }

        // MARK: - Event Handlers

        private func handleScrollViewAppear(proxy: ScrollViewProxy) {
            scrollViewProxy = proxy
            proxy.scrollTo(viewModel.state.groupIndex, anchor: .center)
        }

        private func handleGroupIndexChange(
            proxy: ScrollViewProxy,
            newIndex: Int
        ) {
            isScrolling = true
            scrollViewProxy = proxy
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                proxy.scrollTo(newIndex, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
                isScrolling = false
            }
        }

        private func handleLongPressChange(_ isPressing: Bool) {
            if isPressing {
                viewModel.send(.didPauseTimer)
            } else {
                viewModel.send(.didResumeTimer)
            }
        }

        private func handleDragChanged(_ value: DragGesture.Value) {
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

        private func handleDragEnded(_ value: DragGesture.Value) {
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
                    velocity: value.velocity.width
                )
            }

            viewModel.send(.didResumeTimer)
            self.dragDirection = nil
        }

        private func handleHorizontalSwipe(
            translation: CGFloat,
            velocity: CGFloat
        ) {
            guard dragDirection == .horizontal else { return }

            let shouldSwitch = abs(translation) > Constants.swipeThreshold
                || abs(velocity) > Constants.velocityThreshold

            let currentIndex = viewModel.state.groupIndex
            let totalGroups = viewModel.state.groups.count

            if shouldSwitch {
                performGroupSwitch(
                    translation: translation,
                    currentIndex: currentIndex,
                    totalGroups: totalGroups
                )
            } else {
                scrollToCurrentGroup(swipeDirection: translation > 0 ? .right : .left)
            }
        }

        private func scrollToCurrentGroup(swipeDirection: SwipeDirection) {
            guard let scrollViewProxy else { return }
            
            isScrolling = true

            Task {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    scrollViewProxy.scrollTo(viewModel.state.groupIndex, anchor: .center)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isScrolling = false
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
        
        private func performGroupSwitch(
            translation: CGFloat,
            currentIndex: Int,
            totalGroups: Int
        ) {
            if translation > 0 && currentIndex > 0 {
                viewModel.send(.didSwitchGroup(currentIndex - 1))
            } else if translation < 0 && currentIndex < totalGroups - 1 {
                viewModel.send(.didSwitchGroup(currentIndex + 1))
            } else {
                scrollToCurrentGroup(swipeDirection: translation > 0 ? .right : .left)
            }
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
