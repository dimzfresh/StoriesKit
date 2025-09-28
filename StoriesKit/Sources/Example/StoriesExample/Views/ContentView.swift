import Kingfisher
import SwiftUI
import StoriesKit

final class StoriesViewModel: ObservableObject {
    @Published var dataModel = StoriesDataModel()
}

struct ContentView: View {
    @StateObject private var storiesVM = StoriesViewModel()
    @StateObject private var stateManager = StoriesStateManager()

    @Namespace private var avatarNamespace

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                storiesCarouselView

                randomImagesSection
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if stateManager.state.isShown {
                Stories.build(
                    groups: storiesVM.dataModel.storiesGroups,
                    stateManager: stateManager,
                    avatarNamespace: avatarNamespace
                )
                .ignoresSafeArea()
            }
        }
        .onChange(of: stateManager.state.event) { event in
            if case let .didViewPage(groupId, pageId) = event {
                storiesVM.dataModel.markPageAsViewed(groupId: groupId, pageId: pageId)
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
                storiesVM: storiesVM,
                stateManager: stateManager,
                avatarNamespace: avatarNamespace
            )
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private var randomImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.blue)
                    .font(.title3)

                Text("Featured Images")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)

            ScrollView(.vertical, showsIndicators: false) {
                ForEach(storiesVM.dataModel.randomImages.prefix(5).indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                        .overlay {
                            KFImage(URL(string: storiesVM.dataModel.randomImages[index]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .clipped()
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}
