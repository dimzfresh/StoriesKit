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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    storiesCarouselView
                    //randomImagesSection
                }
            }
            .background(Color(.systemGroupedBackground))
        }
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
        .onChange(of: stateManager.state.isShown) { isShown in
            print("🔄 Stories isShown changed: \(isShown)")
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
}
