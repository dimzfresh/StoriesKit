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
                Color(model.backgroundColor)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .modifier(MatchedGeometryModifier(
                        isCurrentGroup: isCurrentGroup,
                        selectedGroupId: stateManager.state.selectedGroupId,
                        avatarNamespace: avatarNamespace
                    ))
                    .scaleEffect(getScaleEffect())
                    .padding(.top, safeAreaInsets.top)
                    .padding(.bottom, safeAreaInsets.bottom + 16)
            }
        }

        private func progressBarsView() -> some SwiftUI.View {
            HStack(spacing: 4) {
                ForEach(progressBars, id: \.self) { data in
                    ProgressBarView(
                        progress: data.progress,
                        duration: data.duration
                    )
                }
            }
            .frame(height: 10)
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
            _ corners: StoriesPageModel.Button.Corners
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
            VStack(alignment: .center, spacing: 0) {
                VStack(spacing: 0) {
                    progressBarsView()
                        .padding(.top, 12)
                        .padding(.horizontal, 10)

                    headerView()
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }

                Text(model.title)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)

                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }

                Spacer()

                if let button = model.button {
                    buttonView(for: button)
                }
            }
        }

        private func headerView() -> some SwiftUI.View {
            HStack(spacing: 0) {
                HStack(spacing: 12) {
                    avatarView()
                    usernameView()
                }

                Spacer()

                closeButton()
            }
        }

        private func avatarView() -> some SwiftUI.View {
            Group {
                switch group.avatarImage {
                case let .local(image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                case let .remote(url):
                    KFImage(url)
                        .placeholder {
                            Circle()
                                .fill(.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                )
                        }
                        .cacheOriginalImage()
                        .diskCacheExpiration(.seconds(600))
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .scaledToFill()
                }
            }
        }

        private func usernameView() -> some SwiftUI.View {
            Text(group.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }

        private func closeButton() -> some SwiftUI.View {
            Button {
                onButtonAction(.close)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
        }

        private func buttonView(for button: StoriesPageModel.Button) -> some SwiftUI.View {
            Button {
                onButtonAction(button.actionType)
            } label: {
                Text(button.title)
                    .frame(width: 148, height: 50)
            }
            .background(Color(button.backgroundColor))
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
    let selectedGroupId: String?
    let avatarNamespace: Namespace.ID

    func body(content: Content) -> some View {
        if isCurrentGroup, let selectedGroupId {
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
