import Foundation
import SwiftUI
import StoriesKit
import AVFoundation

enum StoriesFactory {
    static func makeStoriesGroups() -> [StoriesGroupModel] {
        let storiesGroups = [
            StoriesGroupModel(
                id: "taylor_swift",
                title: createAttributedTitle("Taylor Swift"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "New Album! 🎵",
                        subtitle: "Midnights is here!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: true
                    ),
                    createStoryPage(
                        title: "Tour Life ✈️",
                        subtitle: "Eras Tour continues!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: false
                    ),
                    createStoryPage(
                        title: "Tour Life 🎶",
                        subtitle: "Eras Tour continues!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: false
                    )
                ]
            ),
            StoriesGroupModel(
                id: "bad_bunny",
                title: createAttributedTitle("Bad Bunny"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Un Verano Sin Ti 🌴",
                        subtitle: "Summer vibes!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: true
                    )
                ]
            ),
            StoriesGroupModel(
                id: "the_weeknd",
                title: createAttributedTitle("The Weeknd"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "After Hours Til Dawn 🌅",
                        subtitle: "World tour continues",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ]
            ),
            StoriesGroupModel(
                id: "drake",
                title: createAttributedTitle("Drake"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Her Loss 🎤",
                        subtitle: "New album out now!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: true
                    ),
                    createStoryPage(
                        title: "OVO Sound 🦉",
                        subtitle: "Label updates",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: true
                    )
                ]
            ),
            StoriesGroupModel(
                id: "ariana_grande",
                title: createAttributedTitle("Ariana Grande"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Positions 💖",
                        subtitle: "Album anniversary!",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
                    )
                ]
            ),
            StoriesGroupModel(
                id: "billie_eilish",
                title: createAttributedTitle("Billie Eilish"),
                avatarImage: .remote(URL(string: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face")!),
                pages: [
                    createStoryPage(
                        title: "Happier Than Ever 🌙",
                        subtitle: "New music coming soon",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: true
                    ),
                    createStoryPage(
                        title: "Studio Session 🎧",
                        subtitle: "Working on new album",
                        backgroundColor: .black,
                        imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
                        isViewed: false
                    )
                ]
            )
        ]

        let firstGroups = storiesGroups.filter { $0.pages.contains(where: { !$0.isViewed }) }.sorted { $0.id < $1.id }
        let viewedGroups = storiesGroups.filter { $0.pages.allSatisfy(\.isViewed) }.sorted { $0.id < $1.id }

        return firstGroups + viewedGroups
    }
    
    private static func createAttributedTitle(_ text: String) -> String {
        return text
    }
    
    static func makeRandomImages() -> [String] {
        let imageUrls = [
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80",
            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"
        ]
        
        return imageUrls.shuffled()
    }

    private static func createStoryPage(
        title: String,
        subtitle: String,
        backgroundColor: UIColor,
        imageUrl: String,
        isViewed: Bool = false
    ) -> StoriesPageModel {
        var titleAttributed = AttributedString(title)
        titleAttributed.font = .system(size: 24, weight: .bold)
        titleAttributed.foregroundColor = .white
        
        var subtitleAttributed = AttributedString(subtitle)
        subtitleAttributed.font = .system(size: 16, weight: .medium)
        subtitleAttributed.foregroundColor = .white.opacity(0.9)

        let content = AnyView(
            VStack {
                Text(titleAttributed)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)

                Text(subtitleAttributed)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
            }
        )

        return .init(
            mediaSource: .init(
                media: .image(.remote(URL(string: imageUrl)!))
            ),
            isViewed: isViewed,
            content: content
        )
    }
}
