import Foundation
import SwiftUI
import StoriesKit
import Kingfisher

final class StoriesDataModel: ObservableObject {
    @Published var storiesGroups: [StoriesGroupModel] = []
    @Published var randomImages: [String] = []
    
    init() {
        generateStoriesData()
        generateRandomImages()
        preloadImages()
    }
    
    private func generateStoriesData() {
        let topArtists = [
            StoriesGroupModel(
                id: "taylor_swift",
                title: "Taylor Swift",
                avatarImage: .url(URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face")!),
                stories: [
                    createStoryPage(
                        title: "New Album! 🎵",
                        subtitle: "Midnights is here!",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Tour Life ✈️",
                        subtitle: "Eras Tour continues!",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Studio Time 🎤",
                        subtitle: "Working on new music",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            ),
            StoriesGroupModel(
                id: "bad_bunny",
                title: "Bad Bunny",
                avatarImage: .url(URL(string: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=100&h=100&fit=crop&crop=face")!),
                stories: [
                    createStoryPage(
                        title: "Un Verano Sin Ti 🌴",
                        subtitle: "Album of the year!",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Puerto Rico 🇵🇷",
                        subtitle: "Back home for the holidays",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: true
            ),
            StoriesGroupModel(
                id: "drake",
                title: "Drake",
                avatarImage: .url(URL(string: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=100&h=100&fit=crop&crop=face")!),
                stories: [
                    createStoryPage(
                        title: "Her Loss 💎",
                        subtitle: "New album with 21 Savage",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "OVO Sound 🦉",
                        subtitle: "Label showcase tonight",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Toronto 🍁",
                        subtitle: "Home sweet home",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            ),
            StoriesGroupModel(
                id: "the_weeknd",
                title: "The Weeknd",
                avatarImage: .url(URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face")!),
                stories: [
                    createStoryPage(
                        title: "After Hours Til Dawn 🌅",
                        subtitle: "World tour continues",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Dawn FM 🎧",
                        subtitle: "New album out now",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: true
            ),
            StoriesGroupModel(
                id: "harry_styles",
                title: "Harry Styles",
                avatarImage: .url(URL(string: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=100&h=100&fit=crop&crop=face")!),
                stories: [
                    createStoryPage(
                        title: "Harry's House 🏠",
                        subtitle: "Album of the year nominee",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Love On Tour 💕",
                        subtitle: "Selling out stadiums worldwide",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "As It Was 🎵",
                        subtitle: "Number 1 hit single",
                        backgroundColor: .systemGray,
                        imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            )
        ]
        
        storiesGroups = topArtists
    }
    
    private func createStoryPage(
        title: String,
        subtitle: String,
        backgroundColor: UIColor,
        imageUrl: String
    ) -> StoriesPageModel {
        var titleAttributed = AttributedString(title)
        titleAttributed.font = .system(size: 24, weight: .bold)
        titleAttributed.foregroundColor = .white
        
        var subtitleAttributed = AttributedString(subtitle)
        subtitleAttributed.font = .system(size: 16, weight: .medium)
        subtitleAttributed.foregroundColor = .white.opacity(0.9)
        
        let page = StoriesPageModel(
            title: titleAttributed,
            subtitle: subtitleAttributed,
            backgroundColor: backgroundColor,
            backgroundImage: StoriesImageModel(
                image: .url(URL(string: imageUrl)!)
            ),
            duration: 4.0
        )
        
        return page
    }
    
    func generateRandomImages() {        
        randomImages =  [
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=300&h=300&fit=crop",
            "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=300&h=300&fit=crop"
        ]
    }
    
    private func preloadImages() {
        for group in storiesGroups {
            if case .url(let url) = group.avatarImage {
                KingfisherManager.shared.retrieveImage(with: url) { _ in }
            }
            
            for story in group.stories {
                if case .url(let url) = story.backgroundImage.image {
                    KingfisherManager.shared.retrieveImage(with: url) { _ in }
                }
            }
        }
        
        for imageUrl in randomImages.prefix(10) {
            if let url = URL(string: imageUrl) {
                KingfisherManager.shared.retrieveImage(with: url) { _ in }
            }
        }
    }
    
    func markStoryAsViewed(groupId: String) {
        if let index = storiesGroups.firstIndex(where: { $0.id == groupId }) {
            let group = storiesGroups[index]
            let updatedGroup = StoriesGroupModel(
                id: group.id,
                title: group.title,
                avatarImage: group.avatarImage,
                stories: group.stories,
                isViewed: true
            )
            storiesGroups[index] = updatedGroup
        }
    }
}
