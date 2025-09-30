import Kingfisher
import SwiftUI
import StoriesKit

struct StoriesCarouselView: View {
    @ObservedObject var stateManager: StoriesStateManager
    let avatarNamespace: Namespace.ID

    @State private var scrollViewProxy: ScrollViewProxy?

    private let avatarSize: CGFloat = 70
    private let titleHeight: CGFloat = 20

    private var groups: [StoriesGroupModel] {
        let firstGroups = stateManager.state.groups.filter { $0.pages.contains(where: { !$0.isViewed }) }.sorted { $0.id < $1.id }
        let viewedGroups = stateManager.state.groups.filter { $0.pages.allSatisfy(\.isViewed) }.sorted { $0.id < $1.id }
        return firstGroups + viewedGroups
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(groups) { group in
                            StoryGroupItemView(
                                group: group,
                                stateManager: stateManager,
                                avatarNamespace: avatarNamespace,
                                avatarSize: avatarSize,
                                titleHeight: titleHeight
                            )
                            .id(group.id)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: stateManager.state.selectedGroupId) { groupId in
                    guard let groupId else { return }

                    Task {
                        proxy.scrollTo(groupId, anchor: .center)
                    }
                }
            }
        }
    }
}

struct StoryGroupItemView: View {
    let group: StoriesGroupModel
    @ObservedObject var stateManager: StoriesStateManager
    let avatarNamespace: Namespace.ID
    let avatarSize: CGFloat
    let titleHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                SegmentedCircleView(
                    segments: SegmentedCircleView.createSegments(
                        for: group
                    ),
                    size: avatarSize + 6,
                )

                if group.id != stateManager.state.selectedGroupId {
                    avatarImageView
                        .matchedGeometryEffect(
                            id: group.id,
                            in: avatarNamespace
                        )
                }
            }

            Text(group.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: avatarSize + 6, height: titleHeight)
        }
        .frame(width: avatarSize + 6, height: titleHeight + 8 + avatarSize + 12)
        .onTapGesture {
            handleTap()
        }
    }
    
    @ViewBuilder
    private var avatarImageView: some View {
        switch group.avatarImage {
        case let .local(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
        case let .remote(url):
            KFImage(url)
                .placeholder {
                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: avatarSize, height: avatarSize)
                        .overlay(
                            Image(systemName: "music.mic")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .scaledToFill()
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
        }
    }
    
    private func handleTap() {
        stateManager.send(.didToggleGroup(group.id))
    }
}
