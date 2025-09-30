import SwiftUI

struct CarouselItemView: View {
    private let group: StoriesGroupModel
    @ObservedObject private var stateManager: StoriesStateManager
    private let avatarNamespace: Namespace.ID
    private let configuration: StoriesCarouselConfiguration

    var body: some View {
        VStack(spacing: 0) {
            SegmentedCircleView(
                segments: createCustomSegments(for: group),
                lineWidth: configuration.progress.lineWidth,
                size: configuration.avatar.size + configuration.avatar.progressPadding,
                gap: configuration.progress.gap
            )
            .overlay {
                if group.id != stateManager.state.selectedGroupId {
                    avatarImageView()
                        .matchedGeometryEffect(
                            id: group.id,
                            in: avatarNamespace
                        )
                        .padding(configuration.avatar.padding)
                }
            }

            Text(group.title)
                .font(configuration.title.font)
                .foregroundColor(configuration.title.color)
                .lineLimit(configuration.title.numberOfLines)
                .lineSpacing(configuration.title.lineSpacing)
                .truncationMode(configuration.title.truncationMode)
                .multilineTextAlignment(configuration.title.multilineTextAlignment)
                .padding(configuration.title.padding)
        }
        .padding(.vertical, configuration.avatar.progressPadding)
        .onTapGesture {
            handleTap()
        }
    }

    init(
        group: StoriesGroupModel,
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID,
        configuration: StoriesCarouselConfiguration
    ) {
        self.group = group
        self.stateManager = stateManager
        self.avatarNamespace = avatarNamespace
        self.configuration = configuration
    }

    private func avatarImageView() -> some View {
        StoriesMediaView(
            mediaModel: .init(media: .image(group.avatarImage)),
            placeholder: {
                if let placeholder = group.placeholder {
                    Image(uiImage: placeholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: configuration.avatar.size, height: configuration.avatar.size)
                        .clipShape(Circle())
                }
            }
        )
        .frame(width: configuration.avatar.size, height: configuration.avatar.size)
        .clipShape(Circle())
    }

    private func createCustomSegments(for group: StoriesGroupModel) -> [SegmentedCircleView.Segment] {
        if group.pages.allSatisfy(\.isViewed) {
            [
                .init(
                    color: configuration.progress.viewedColor,
                    isActive: false
                )
            ]
        } else {
            group.pages.map { page in
                if page.isViewed {
                    .init(
                        color: configuration.progress.viewedColor,
                        isActive: false
                    )
                } else {
                    .init(
                        color: configuration.progress.unviewedColor,
                        isActive: true
                    )
                }
            }
        }
    }
    
    private func handleTap() {
        stateManager.send(.didToggleGroup(group.id))
    }
}
