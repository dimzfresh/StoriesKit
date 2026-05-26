import SwiftUI

extension Stories {
    struct PageView: SwiftUI.View {
        let group: StoriesGroupModel
        let currentPage: StoriesPageModel?
        let verticalOffset: CGFloat
        let progressBars: [ViewState.ProgressBar]
        let progressModel: StoriesProgressModel
        let isCurrentGroup: Bool
        let avatarNamespace: Namespace.ID
        let stateManager: StoriesStateManager
        let onCloseAction: () -> Void
        let onTapPrevious: () -> Void
        let onTapNext: () -> Void

        @Environment(\.safeAreaInsets) private var safeAreaInsets

        var body: some SwiftUI.View {
            ZStack {
                GeometryReader { geometry in
                    ZStack {
                        if let currentPage {
                            storyPageView(currentPage)
                                .modifier(MatchedGeometryModifier(
                                    isCurrentGroup: isCurrentGroup,
                                    selectedGroupId: stateManager.state.selectedGroupId ?? group.id,
                                    avatarNamespace: avatarNamespace
                                ))
                        }
                    }
                    .scaleEffect(getScaleEffect())
                    .rotation3DEffect(
                        getAngle(geometry: geometry),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: rotationAnchor(geometry: geometry),
                        perspective: 2.0
                    )
                }
            }
            .ignoresSafeArea()
        }

        private func storyPageView(_ model: StoriesPageModel) -> some SwiftUI.View {
            ZStack {
                Color.clear
                    .overlay {
                        StoriesMediaView(
                            mediaModel: model.mediaSource,
                            videoManager: stateManager.videoManager,
                            isVideoActive: isCurrentGroup,
                            placeholder: {
                                if let placeholder = model.mediaSource.placeholder {
                                    Image(uiImage: placeholder)
                                        .resizable()
                                        .scaledToFill()
                                }
                            },
                            failure: {
                                if let placeholder = model.mediaSource.placeholder {
                                    Image(uiImage: placeholder)
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                        )
                    }
                    .overlay {
                        tapAreasOverlay()
                    }
                    .overlay {
                        contentOverlay(for: model)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: model.cornerRadius))
                    .scaleEffect(getScaleEffect())
                    .padding(model.padding)
            }
        }

        private func progressBarsView() -> some SwiftUI.View {
            Group {
                if isCurrentGroup {
                    StoriesLiveProgressBarsView(
                        progressModel: progressModel,
                        group: group,
                        progressBars: progressBars,
                        currentPage: currentPage,
                        lineSize: stateManager.model.progress.lineSize,
                        interItemSpacing: stateManager.model.progress.interItemSpacing,
                        containerPadding: stateManager.model.progress.containerPadding
                    )
                } else {
                    StoriesStaticProgressBarsView(
                        progressBars: progressBars,
                        lineSize: stateManager.model.progress.lineSize,
                        interItemSpacing: stateManager.model.progress.interItemSpacing,
                        containerPadding: stateManager.model.progress.containerPadding
                    )
                }
            }
        }

        private func getAngle(geometry: GeometryProxy) -> Angle {
            let width = max(geometry.size.width, 1)
            let rawProgress = geometry.frame(in: .global).minX / width
            let progress = min(max(rawProgress, -1), 1)
            return Angle(degrees: Constants.rotationAngle * progress)
        }

        private func rotationAnchor(geometry: GeometryProxy) -> UnitPoint {
            geometry.frame(in: .global).minX > 0 ? .leading : .trailing
        }

        private func getScaleEffect() -> CGFloat {
            guard isCurrentGroup && verticalOffset > 0 else { return 1.0 }

            let threshold = UIScreen.main.bounds.height * Constants.scaleThreshold
            let progress = min(verticalOffset / threshold, 1.0)

            return 1.0 - (progress * (1.0 - Constants.minScale))
        }

        private func tapArea(isLeftSide: Bool) -> some SwiftUI.View {
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            handleTapAreaAction(isLeftSide: isLeftSide)
                        }
                )
        }

        // MARK: - Helper Methods

        private func tapAreasOverlay() -> some SwiftUI.View {
            HStack(spacing: 0) {
                tapArea(isLeftSide: true)
                tapArea(isLeftSide: false)
            }
            .ignoresSafeArea()
        }

        private func contentOverlay(for model: StoriesPageModel) -> some SwiftUI.View {
            ZStack {
                VStack(alignment: .center, spacing: 0) {
                    progressBarsView()
                        .padding(.top, 12)
                        .padding(.horizontal, 10)

                    headerView()
                        .padding(.top, 10)
                        .padding(.horizontal, 10)

                    Spacer()
                }

                if let content = model.content {
                    content
                }
            }
        }

        private func headerView() -> some SwiftUI.View {
            HStack(spacing: 0) {
                if let user = stateManager.model.user {
                    avatarView(user.avatar)

                    VStack(alignment: .leading, spacing: 2) {
                        usernameView(user.userName)
                        dateView(user.date)
                    }
                }

                Spacer()

                Button {
                    onCloseAction()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFill()
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                }
                .onTapGesture {}
            }
        }

        private func avatarView(_ model: StoriesModel.Avatar) -> some SwiftUI.View {
            StoriesMediaView(
                mediaModel: .init(media: .image(group.avatarImage)),
                placeholder: {
                    if let placeholder = group.placeholder {
                        Image(uiImage: placeholder)
                            .resizable()
                            .scaledToFill()
                            .frame(width: model.size, height: model.size)
                            .clipShape(Circle())
                    }
                }
            )
            .frame(width: model.size, height: model.size)
            .clipShape(Circle())
            .padding(model.padding)
        }

        private func usernameView(_ model: StoriesModel.Text) -> some SwiftUI.View {
            Text(group.title)
                .lineLimit(model.numberOfLines)
                .font(model.font)
                .foregroundColor(model.color)
                .multilineTextAlignment(model.alignment)
                .padding(model.padding)
        }

        private func dateView(_ model: StoriesModel.Text) -> some SwiftUI.View {
            Text(currentPage?.date ?? "")
                .lineLimit(model.numberOfLines)
                .font(model.font)
                .foregroundColor(model.color)
                .multilineTextAlignment(model.alignment)
                .padding(model.padding)
        }

        private func handleTapAreaAction(isLeftSide: Bool) {
            if isLeftSide {
                onTapPrevious()
            } else {
                onTapNext()
            }
        }
    }

    private enum Constants {
        static let rotationAngle: CGFloat = 45
        static let scaleThreshold: CGFloat = 0.3
        static let minScale: CGFloat = 0.85
    }
}

private struct MatchedGeometryModifier: ViewModifier {
    let isCurrentGroup: Bool
    let selectedGroupId: String
    let avatarNamespace: Namespace.ID

    func body(content: Content) -> some View {
        if isCurrentGroup {
            content
                .matchedGeometryEffect(
                    id: selectedGroupId,
                    in: avatarNamespace
                )
        } else {
            content
        }
    }
}
