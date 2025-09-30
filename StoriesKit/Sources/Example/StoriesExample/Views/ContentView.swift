import Kingfisher
import SwiftUI
import StoriesKit

struct ContentView: View {
    @StateObject private var stateManager: StoriesStateManager
    private let randomImages = StoriesFactory.makeRandomImages()
    @Namespace private var avatarNamespace

    init() {
        let model = StoriesModel(groups: StoriesFactory.makeStoriesGroups())
        _stateManager = .init(wrappedValue: .init(model: model))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                storiesCarouselView

                randomImagesSection

                Spacer()
            }
            .padding(.top, 20)
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .preferredColorScheme(.dark)
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
                    .foregroundColor(.white.opacity(0.8))
                    .font(.title3)

                Text("Artist Stories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))

                Spacer()
            }
            .padding(.horizontal, 16)

            StoriesCarouselView(
                stateManager: stateManager,
                avatarNamespace: avatarNamespace
            )
        }
        .padding(.vertical, 16)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var randomImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.title3)

                Text("Featured Images")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))

                Spacer()
            }
            .padding(.horizontal, 16)

            ScrollView(.vertical, showsIndicators: false) {
                ForEach(randomImages.prefix(5).indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .frame(height: 200)
                        .overlay {
                            KFImage(URL(string: randomImages[index]))
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .clipped()
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
