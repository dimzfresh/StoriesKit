import SwiftUI

extension Stories {
    struct PageView: View {
        let group: StoriesGroupModel
        let currentPage: StoriesPageModel?
        let verticalOffset: CGFloat
        let progressBars: [ViewState.ProgressBar]
        let onButtonAction: (StoriesPageModel.Button.ActionType) -> Void
        let isCurrentGroup: Bool
        let onTapPrevious: () -> Void
        let onTapNext: () -> Void

        @Environment(\.safeAreaInsets) private var safeAreaInsets

        private var isSmallScreen: Bool {
            UIScreen.main.bounds.width == 320
        }

        var body: some View {
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

        private func storyPageView(_ model: StoriesPageModel) -> some View {
            ZStack {
                Color(model.backgroundColor)
                    .overlay {
                        StoriesImageView(model: model.backgroundImage)
                    }
                    .overlay {
                        tapAreasOverlay()
                    }
                    .overlay {
                        contentOverlay(for: model)
                    }
                .scaleEffect(getScaleEffect())
            }
        }
        
        private func progressBarsView() -> some View {
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
            case .circle: (isSmallScreen ? 40 : 50) * 0.5
            case let .radius(radius): radius
            }
        }
        
        private func tapArea(isLeftSide: Bool) -> some View {
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
        
        private func tapAreasOverlay() -> some View {
            HStack(spacing: 0) {
                tapArea(isLeftSide: true)
                tapArea(isLeftSide: false)
            }
            .ignoresSafeArea()
        }
        
        private func contentOverlay(for model: StoriesPageModel) -> some View {
            VStack(alignment: .center, spacing: 0) {
                progressBarsView()
                    .padding(.top, safeAreaInsets.top + 12)
                    .padding(.horizontal, 10)

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
        
        private func buttonView(for button: StoriesPageModel.Button) -> some View {
            Button {
                onButtonAction(button.actionType)
            } label: {
                Text(button.title)
                    .frame(width: 148, height: isSmallScreen ? 40 : 50)
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
