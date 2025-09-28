import Kingfisher
import SwiftUI
import StoriesKit

struct StoriesCarouselView: View {
    @ObservedObject var storiesVM: StoriesViewModel
    @ObservedObject var stateManager: StoriesStateManager
    let avatarNamespace: Namespace.ID

    @State private var scrollViewProxy: ScrollViewProxy?

    private let avatarSize: CGFloat = 70
    private let titleHeight: CGFloat = 20

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(storiesVM.dataModel.storiesGroups) { group in
                            StoryGroupItemView(
                                group: group,
                                storiesVM: storiesVM,
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

                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(groupId, anchor: .center)
                    }
                }
            }
        }
    }
}

struct StoryGroupItemView: View {
    let group: StoriesGroupModel
    @ObservedObject var storiesVM: StoriesViewModel
    @ObservedObject var stateManager: StoriesStateManager
    let avatarNamespace: Namespace.ID
    let avatarSize: CGFloat
    let titleHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(
                        group.isViewed ? .gray.opacity(0.5) : .blue,
                        lineWidth: 3
                    )
                    .frame(width: avatarSize + 6, height: avatarSize + 6)

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
