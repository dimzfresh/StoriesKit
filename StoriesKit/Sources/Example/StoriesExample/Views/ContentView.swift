import SwiftUI
import StoriesKit

struct ContentView: View {
    @StateObject private var stateManager: StoriesStateManager
    @Environment(\.openURL) private var openURL

    private let randomImages = StoriesFactory.makeRandomImages()
    @Namespace private var avatarNamespace

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                storiesCarouselView

                randomImagesSection

                Spacer()
            }
            .padding(.top, 20)
        }
        .background(DemoTheme.background)
        .preferredColorScheme(.dark)
        .onChange(of: stateManager.state.event) { event in
            handleStoriesEvent(event)
        }
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

    init() {
        _stateManager = .init(wrappedValue: .init(model: StoriesFactory.makeStoriesModel()))
    }

    private var storiesCarouselView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "music.mic")
                    .foregroundColor(DemoTheme.sectionIcon)
                    .font(.title3)

                Text("Artist Stories")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DemoTheme.sectionTitle)

                Spacer()
            }
            .padding(.horizontal, 16)

            StoriesCarouselView(
                stateManager: stateManager,
                avatarNamespace: avatarNamespace,
                configuration: StoriesCarouselConfiguration(
                    layout: StoriesCarouselConfiguration.Layout(
                        corners: .radius(12)
                    )
                )
            )
        }
        .padding(.vertical, 16)
        .background(DemoTheme.background)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var randomImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(DemoTheme.sectionIcon)
                    .font(.title3)

                Text("Featured Images")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DemoTheme.sectionTitle)

                Spacer()
            }
            .padding(.horizontal, 16)

            ScrollView(.vertical, showsIndicators: false) {
                ForEach(randomImages.prefix(5).indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .frame(height: 200)
                        .overlay {
                            StoriesMediaView(
                                mediaModel: .init(media: .image(.remote(randomImages[index]))),
                                placeholder: { DemoTheme.imagePlaceholder },
                                failure: { DemoTheme.imagePlaceholder }
                            )
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .clipped()
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(DemoTheme.background)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private func handleStoriesEvent(_ event: StoriesStateManager.Event?) {
        guard let event else { return }

        switch event {
        case let .didOpenLink(urlString):
            guard let url = URL(string: urlString) else { return }
            openURL(url)
        case .didToggleGroup, .didSwitchGroup, .didViewPage:
            break
        }
    }
}
