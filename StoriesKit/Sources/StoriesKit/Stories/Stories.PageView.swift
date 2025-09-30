import Kingfisher
import SwiftUI

extension Stories {
    struct PageView: SwiftUI.View {
        let group: StoriesGroupModel
        let currentPage: StoriesPageModel?
        let verticalOffset: CGFloat
        let progressBars: [ViewState.ProgressBar]
        let onButtonAction: (StoriesPageModel.Button.ActionType) -> Void
        let isCurrentGroup: Bool
        let onTapPrevious: () -> Void
        let onTapNext: () -> Void
        let avatarNamespace: Namespace.ID
        let stateManager: StoriesStateManager

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
                        anchor: geometry.frame(in: .global).minX > 0 ? .leading : .trailing,
                        perspective: 2.0
                    )
                    .ignoresSafeArea()
                }
            }
        }

        private func storyPageView(_ model: StoriesPageModel) -> some SwiftUI.View {
            ZStack {
                Color.clear
                    .overlay {
                        StoriesMediaView(
                            mediaModel: model.mediaSource,
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
                    .clipShape(RoundedRectangle(cornerRadius: getAdaptiveCornerRadius(model.corners)))
                    .scaleEffect(getScaleEffect())
                    .padding(.top, safeAreaInsets.top)
                    .padding(.bottom, safeAreaInsets.bottom + 16)
            }
        }

        private func progressBarsView() -> some SwiftUI.View {
            HStack(spacing: stateManager.model.progress.interItemSpacing) {
                ForEach(progressBars, id: \.self) { data in
                    ProgressBarView(
                        progress: data.progress,
                        duration: data.duration,
                        height: stateManager.model.progress.lineSize
                    )
                }
            }
            .padding(stateManager.model.progress.containerPadding)
        }

        private func getAngle(geometry: GeometryProxy) -> Angle {
            let rotationAngle: CGFloat = Constants.rotationAngle
            let progress = geometry.frame(in: .global).minX / geometry.size.width
            let degrees = rotationAngle * progress
            return Angle(degrees: degrees)
        }

        private func getScaleEffect() -> CGFloat {
            guard isCurrentGroup && verticalOffset > 0 else { return 1.0 }

            let threshold = UIScreen.main.bounds.height * Constants.scaleThreshold
            let progress = min(verticalOffset / threshold, 1.0)

            return 1.0 - (progress * (1.0 - Constants.minScale))
        }

        private func getAdaptiveCornerRadius(
            _ corners: StoriesPageModel.Corners
        ) -> CGFloat {
            switch corners {
            case .none: 0
            case .circle: 50 * 0.5
            case let .radius(radius): radius
            }
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
                if let content = model.content {
                    content
                }
                
                VStack(alignment: .center, spacing: 0) {
                    progressBarsView()
                        .padding(.top, 12)
                        .padding(.horizontal, 10)

                    headerView()
                        .padding(.top, 8)
                        .padding(.horizontal, 16)

                    Spacer()

                    if let button = model.button {
                        buttonView(for: button)
                    }
                }
            }
        }

        private func headerView() -> some SwiftUI.View {
            HStack(spacing: 0) {
                avatarView(stateManager.model.avatar)

                VStack(alignment: .leading, spacing: 2) {
                    usernameView(stateManager.model.userName)
                    dateView(stateManager.model.date)
                }

                Spacer()

                Button {
                    onButtonAction(.close)
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

        private func buttonView(for button: StoriesPageModel.Button) -> some SwiftUI.View {
            Button {
                onButtonAction(button.actionType)
            } label: {
                Text(button.title)
                    .frame(width: 148, height: 50)
            }
            .background(button.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: getAdaptiveCornerRadius(button.corners)))
            .padding(.bottom, safeAreaInsets.bottom + 24)
            .onTapGesture {}
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
