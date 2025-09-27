import SwiftUI
import StoriesKit

final class StoriesViewModel: ObservableObject {
    @Published var dataModel = StoriesDataModel()
    @Published var selectedGroup: StoriesGroupModel = .empty
    @Published var isExpanded = false

    @Published var animatableModel = StoriesAnimatableModel()
}

struct ContentView: View, IStoriesDelegate {
    @ObservedObject private var storiesVM = StoriesViewModel()

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
            if storiesVM.isExpanded {
                Stories.build(
                    groups: storiesVM.dataModel.storiesGroups,
                    animatableModel: storiesVM.animatableModel,
                    avatarNamespace: avatarNamespace,
                    delegate: self,
                    selectedGroup: storiesVM.selectedGroup
                )
                .ignoresSafeArea()
            }
        }
    }

    init() {
        _avatarNamespace = .init()
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
                storiesVM: storiesVM,
                avatarNamespace: avatarNamespace
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

            RandomImagesView(images: storiesVM.dataModel.randomImages)
        }
        .padding(.top, 8)
        .background(Color(.systemBackground))
    }

    private func dismissStories() {
        withAnimation(.easeInOut(duration: 0.3)) {
            storiesVM.isExpanded = false
            storiesVM.selectedGroup = .empty
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            storiesVM.animatableModel.selectedGroupId = ""
        }
    }
    
    func didClose() {
        dismissStories()
    }

    func didOpenLink(url: URL) {}
    func didOpenStory(storyId: String) {}
}
