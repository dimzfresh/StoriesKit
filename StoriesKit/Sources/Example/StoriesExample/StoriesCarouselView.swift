import SwiftUI
import StoriesKit

struct StoriesCarouselView: View {
    let storiesGroups: [StoriesGroupModel]
    let avatarNamespace: Namespace.ID
    let onStoryGroupTap: (StoriesGroupModel) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(storiesGroups, id: \.id) { group in
                    StoryGroupView(
                        group: group,
                        avatarNamespace: avatarNamespace,
                        onTap: {
                            onStoryGroupTap(group)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct StoryGroupView: View {
    let group: StoriesGroupModel
    let avatarNamespace: Namespace.ID
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private let avatarSize: CGFloat = 70
    private let titleHeight: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: group.isViewed ? 
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)] :
                                [Color.blue, Color.purple, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: avatarSize + 6, height: avatarSize + 6)
                    .shadow(
                        color: group.isViewed ? Color.clear : Color.blue.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )

                // Avatar image
                AsyncImageView(
                    url: avatarURL,
                    placeholder: "music.mic",
                    width: avatarSize,
                    height: avatarSize,
                    cornerRadius: avatarSize / 2
                )
                .overlay(
                    Circle()
                        .stroke(
                            group.isViewed ? Color.clear : Color.white,
                            lineWidth: 3
                        )
                )
                .matchedGeometryEffect(id: "avatar_\(group.id)", in: avatarNamespace)
                
                // Unviewed indicator
                if !group.isViewed {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.red, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: avatarSize/2 - 6, y: -avatarSize/2 + 6)
                        .shadow(color: Color.red.opacity(0.5), radius: 2, x: 0, y: 1)
                }
            }
            
            // Title
            Text(group.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: avatarSize + 6, height: titleHeight)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.1), value: group.isViewed)
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var avatarURL: URL? {
        if case .url(let url) = group.avatarImage {
            return url
        }
        return nil
    }
}
