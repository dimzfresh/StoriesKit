import Kingfisher
import SwiftUI
import StoriesKit

struct StoriesCarouselView: View {
    let storiesGroups: [StoriesGroupModel]
    let avatarNamespace: Namespace.ID
    @Binding var selectedGroup: StoriesGroupModel
    @State private var scrollViewProxy: ScrollViewProxy?

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(storiesGroups, id: \.id) { group in
                            StoryGroupView(
                                group: group,
                                avatarNamespace: avatarNamespace,
                                isSelected: selectedGroup.id == group.id,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        selectedGroup = group
                                    }
                                }
                            )
                            .id(group.id)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onAppear {
                    scrollViewProxy = proxy
                }
                .onChange(of: selectedGroup) { group in
                    guard group != .empty else { return }

                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(group.id, anchor: .center)
                    }
                }
            }
        }
    }
}

struct StoryGroupView: View {
    let group: StoriesGroupModel
    let avatarNamespace: Namespace.ID
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false

    private let avatarSize: CGFloat = 70
    private let titleHeight: CGFloat = 20

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(
                        group.isViewed ? .gray.opacity(0.5) : .blue,
                        lineWidth: 3
                    )
                    .frame(width: avatarSize + 6, height: avatarSize + 6)

                KFImage(avatarURL)
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
                    .matchedGeometryEffect(id: group.id, in: avatarNamespace)
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)

            Text(group.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: avatarSize + 6, height: titleHeight)
        }
        .frame(width: avatarSize + 6, height: titleHeight + 8 + avatarSize + 12)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.1), value: group.isViewed)
        .onTapGesture {
            onTap()
        }
    }

    private var avatarURL: URL? {
        if case let .remote(url) = group.avatarImage {
            return url
        }
        return nil
    }
}
