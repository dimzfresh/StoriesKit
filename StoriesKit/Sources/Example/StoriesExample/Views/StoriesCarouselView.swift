import Kingfisher
import SwiftUI
import StoriesKit

struct StoriesCarouselView: View {
    @ObservedObject var storiesVM: StoriesViewModel
    let avatarNamespace: Namespace.ID
    @State private var scrollViewProxy: ScrollViewProxy?

    private let avatarSize: CGFloat = 70
    private let titleHeight: CGFloat = 20

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(storiesVM.dataModel.storiesGroups, id: \.id) { group in
                            StoryGroupItemView(
                                group: group,
                                storiesVM: storiesVM,
                                avatarNamespace: avatarNamespace,
                                avatarSize: avatarSize,
                                titleHeight: titleHeight
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: storiesVM.animatableModel.selectedGroupId) { groupId in
                    guard !groupId.isEmpty else { return }

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
    let avatarNamespace: Namespace.ID
    let avatarSize: CGFloat
    let titleHeight: CGFloat
    
    var body: some View {
        Group {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(
                            group.isViewed ? .gray.opacity(0.5) : .blue,
                            lineWidth: 3
                        )
                        .frame(width: avatarSize + 6, height: avatarSize + 6)

                    avatarImageView
                        .matchedGeometryEffect(
                            id: group.id,
                            in: avatarNamespace
                        )
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
        .id(group.id)
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
        if storiesVM.selectedGroup == .empty {
            storiesVM.selectedGroup = group
            withAnimation(.easeInOut(duration: 0.25)) {
                storiesVM.animatableModel.selectedGroupId = group.id
                storiesVM.isExpanded = true
            }
        }
    }
}
