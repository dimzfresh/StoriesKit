import Foundation
import SwiftUI
import StoriesKit
import AVFoundation

final class StoriesDataModel: ObservableObject {
    @Published var storiesGroups: [StoriesGroupModel] = []
    @Published var randomImages: [String] = []
    
    init() {
        generateStoriesData()
        generateRandomImages()
    }
    
    private func generateStoriesData() {
        storiesGroups = [
            StoriesGroupModel(
                id: "taylor_swift",
                title: "Taylor Swift",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "New Album! 🎵",
                        subtitle: "Midnights is here!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Tour Life ✈️",
                        subtitle: "Eras Tour continues!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            ),
            StoriesGroupModel(
                id: "bad_bunny",
                title: "Bad Bunny",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Un Verano Sin Ti 🌴",
                        subtitle: "Summer vibes!",
                        backgroundColor: .systemBlue,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: true
            ),
            StoriesGroupModel(
                id: "the_weeknd",
                title: "The Weeknd",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "After Hours Til Dawn 🌅",
                        subtitle: "World tour continues",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            ),
            StoriesGroupModel(
                id: "drake",
                title: "Drake",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Her Loss 🎤",
                        subtitle: "New album out now!",
                        backgroundColor: .systemPurple,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "OVO Sound 🦉",
                        subtitle: "Label updates",
                        backgroundColor: .systemPurple,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: true
            ),
            StoriesGroupModel(
                id: "ariana_grande",
                title: "Ariana Grande",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Positions 💖",
                        subtitle: "Album anniversary!",
                        backgroundColor: .systemPink,
                        imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: false
            ),
            StoriesGroupModel(
                id: "billie_eilish",
                title: "Billie Eilish",
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Happier Than Ever 🌙",
                        subtitle: "New music coming soon",
                        backgroundColor: .systemGreen,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    ),
                    createStoryPage(
                        title: "Studio Session 🎧",
                        subtitle: "Working on new album",
                        backgroundColor: .systemGreen,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ],
                isViewed: true
            )
        ]
    }
    
    func generateRandomImages() {
        let imageUrls = [
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
        ]
        
        randomImages = imageUrls.shuffled()
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
        
        return StoriesPageModel(
            title: titleAttributed,
            subtitle: subtitleAttributed,
            backgroundColor: backgroundColor,
            mediaSource: StoriesMediaModel(
                media: .image(.remote(URL(string: imageUrl)!))
            ),
            duration: 4.0
        )
    }
}
