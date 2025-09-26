import SwiftUI
import StoriesKit

struct ContentView: View, IStoriesDelegate {
    @StateObject private var dataModel = StoriesDataModel()
    @State private var selectedGroup: StoriesGroupModel = .empty
    @Namespace private var avatarNamespace

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    storiesCarouselView
                    //randomImagesSection
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .overlay {
            if selectedGroup != .empty {
                Stories.build(
                    groups: dataModel.storiesGroups,
                    avatarNamespace: avatarNamespace,
                    delegate: self,
                    selectedGroup: selectedGroup
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }

    private var storiesCarouselView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "music.mic")
                    .foregroundColor(.blue)
                    .font(.title3)

                Text("Artist Stories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)

            StoriesCarouselView(
                storiesGroups: dataModel.storiesGroups,
                avatarNamespace: avatarNamespace,
                selectedGroup: $selectedGroup
            )
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private var randomImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.blue)
                        .font(.title3)

                    Text("Featured Images")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }

                Spacer()
            }
            .padding(.horizontal, 16)

            RandomImagesView(images: dataModel.randomImages)
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    func didClose() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedGroup = .empty
        }
    }

    func didOpenLink(url: URL) {}
    func didOpenStory(storyId: String) {}
}
