import Kingfisher
import SwiftUI
import StoriesKit

struct ContentView: View {
    @StateObject private var stateManager: StoriesStateManager
    private let randomImages = StoriesFactory.makeRandomImages()
    @Namespace private var avatarNamespace

    init() {
        let model = StoriesModel(
            groups: StoriesFactory.makeStoriesGroups(),
            backgroundColor: .black,
            progress: .init(
                lineSize: 3,
                gap: 2,
                viewedColor: .gray.opacity(0.6),
                unviewedColor: .green
            ),
            avatar: .init(
                size: 70,
                padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            ),
            userName: .init(
                font: .system(size: 12, weight: .bold),
                color: .white,
                numberOfLines: 1,
                alignment: .center
            )
        )
        
        _stateManager = .init(wrappedValue: .init(model: model))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                storiesCarouselView

                randomImagesSection

                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if stateManager.state.isShown {
                Stories.build(
                    stateManager: stateManager,
                    avatarNamespace: avatarNamespace
                )
                .ignoresSafeArea()
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
                ForEach(randomImages.prefix(5).indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 200)
                        .overlay {
                            KFImage(URL(string: randomImages[index]))
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
