import AVFoundation
import Foundation
import SwiftUI
import StoriesKit

enum StoriesFactory {
    static func makeStoriesModel() -> StoriesModel {
        StoriesModel(
            groups: makeStoriesGroups(),
            backgroundColor: DemoTheme.background,
            user: .init()
        )
    }

    static func makeStoriesGroups() -> [StoriesGroupModel] {
        StoriesGroupModel.sortedForDisplay([
            makeDrakeGroup(),
            makeJustinBieberGroup(),
            makeRihannaGroup(),
            makeTaylorSwiftGroup(),
            makeBadBunnyGroup(),
            makeTheWeekndGroup(),
            makeArianaGrandeGroup(),
            makeBillieEilishGroup()
        ])
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

    private static func makeDrakeGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "1",
            title: "Drake",
            avatarImage: .local(UIImage(resource: .drake1)),
            pages: [
                createStoryPage(
                    title: "Started From The Bottom 🔥",
                    subtitle: "Now we're here! Toronto vibes only",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .drake1)))),
                    date: "2 hours ago",
                    isViewed: false,
                    linkURL: URL(string: "https://www.octobersveryown.com")
                ),
                createStoryPage(
                    title: "OVO Sound Radio 🦉",
                    subtitle: "New episode dropping tonight. Tune in!",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .drake2)))),
                    date: "4 hours ago",
                    isViewed: false
                ),
                createStoryPage(
                    title: "Studio Session 🎧",
                    subtitle: "Late night creativity. New music coming soon...",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .drake3)))),
                    date: "6 hours ago",
                    isViewed: false
                )
            ]
        )
    }

    private static func makeJustinBieberGroup() -> StoriesGroupModel {
        var pages: [StoriesPageModel] = [
            createStoryPage(
                title: "Justice Tour 🌍",
                subtitle: "Selling out stadiums worldwide! Thank you Beliebers ❤️",
                mediaSource: .init(media: .image(.local(UIImage(resource: .jb1)))),
                date: "1 hour ago",
                isViewed: false
            ),
            createStoryPage(
                title: "Purpose Era 🎵",
                subtitle: "Working on something special. Can't wait to share!",
                mediaSource: .init(media: .image(.local(UIImage(resource: .jb2)))),
                date: "3 hours ago",
                isViewed: false
            ),
            createStoryPage(
                title: "Behind the Scenes 📸",
                subtitle: "Studio vibes with the team. Magic happens here ✨",
                mediaSource: .init(media: .image(.local(UIImage(resource: .jb3)))),
                date: "5 hours ago",
                isViewed: false
            ),
            createStoryPage(
                title: "Grateful 🙏",
                subtitle: "Blessed to do what I love. Love you all!",
                mediaSource: .init(media: .image(.local(UIImage(resource: .jb4)))),
                date: "1 day ago",
                isViewed: false
            )
        ]

        if let videoPage = makeVideoPage() {
            pages.append(videoPage)
        }

        return StoriesGroupModel(
            id: "2",
            title: "Justin Bieber",
            avatarImage: .local(UIImage(resource: .jb1)),
            pages: pages
        )
    }

    private static func makeRihannaGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "3",
            title: "Rihanna",
            avatarImage: .local(UIImage(resource: .r1)),
            pages: [
                createStoryPage(
                    title: "Fenty Beauty 💄",
                    subtitle: "Inclusive beauty for everyone! New shades dropping soon ✨",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .r1)))),
                    date: "3 hours ago",
                    isViewed: false
                ),
                createStoryPage(
                    title: "Savage X Fenty 👗",
                    subtitle: "Body positivity is everything! New collection coming 🔥",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .r2)))),
                    date: "6 hours ago",
                    isViewed: false
                ),
                createStoryPage(
                    title: "Music Comeback 🎵",
                    subtitle: "R9 is coming... when it's ready! Patience is a virtue 😉",
                    mediaSource: .init(media: .image(.local(UIImage(resource: .r3)))),
                    date: "1 day ago",
                    isViewed: false
                )
            ]
        )
    }

    private static func makeTaylorSwiftGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "4",
            title: "Taylor Swift",
            avatarImage: .remote("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face"),
            pages: [
                createStoryPage(
                    title: "Tour Life ✈️",
                    subtitle: "Eras Tour continues!",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "4 hours ago",
                    isViewed: true
                ),
                createStoryPage(
                    title: "Tour Life 🎶",
                    subtitle: "Eras Tour continues!",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "1 day ago",
                    isViewed: true
                )
            ]
        )
    }

    private static func makeBadBunnyGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "5",
            title: "Bad Bunny",
            avatarImage: .remote("https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face"),
            pages: [
                createStoryPage(
                    title: "Un Verano Sin Ti 🌴",
                    subtitle: "Summer vibes!",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "2 days ago",
                    isViewed: true
                )
            ]
        )
    }

    private static func makeTheWeekndGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "6",
            title: "The Weeknd",
            avatarImage: .remote("https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=100&h=100&fit=crop&crop=face"),
            pages: [
                createStoryPage(
                    title: "After Hours Til Dawn 🌅",
                    subtitle: "World tour continues",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "3 days ago",
                    isViewed: true
                )
            ]
        )
    }

    private static func makeArianaGrandeGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "7",
            title: "Ariana Grande",
            avatarImage: .remote("https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=100&h=100&fit=crop&crop=face"),
            pages: [
                createStoryPage(
                    title: "Positions 💖",
                    subtitle: "Album anniversary!",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "4 days ago",
                    isViewed: true
                )
            ]
        )
    }

    private static func makeBillieEilishGroup() -> StoriesGroupModel {
        StoriesGroupModel(
            id: "8",
            title: "Billie Eilish",
            avatarImage: .remote("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=100&h=100&fit=crop&crop=face"),
            pages: [
                createStoryPage(
                    title: "Happier Than Ever 🌙",
                    subtitle: "New music coming soon",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "5 days ago",
                    isViewed: true
                ),
                createStoryPage(
                    title: "Studio Session 🎧",
                    subtitle: "Working on new album",
                    mediaSource: .init(media: .image(.remote("https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=600&fit=crop&crop=center&auto=format&q=80"))),
                    date: "1 week ago",
                    isViewed: true
                )
            ]
        )
    }

    private static func makeVideoPage() -> StoriesPageModel? {
        guard let url = Bundle.main.url(forResource: "jb", withExtension: "mov") else { return nil }

        return createStoryPage(
            title: "Tour Highlights 🎬",
            subtitle: "Swipe up energy — raw footage from the road",
            mediaSource: .init(media: .video(.local(.init(url: url)))),
            date: "2 days ago",
            isViewed: false,
            duration: 10
        )
    }

    private static func createStoryPage(
        title: String,
        subtitle: String,
        mediaSource: StoriesMediaModel,
        date: String,
        isViewed: Bool,
        duration: TimeInterval = 5,
        linkURL: URL? = nil
    ) -> StoriesPageModel {
        var titleAttributed = AttributedString(title)
        titleAttributed.font = .system(size: 24, weight: .bold)
        titleAttributed.foregroundColor = .white

        var subtitleAttributed = AttributedString(subtitle)
        subtitleAttributed.font = .system(size: 16, weight: .medium)
        subtitleAttributed.foregroundColor = .white.opacity(0.9)

        let content = VStack(spacing: 0) {
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

            if let linkURL {
                StoryLinkButton(title: "Learn More", url: linkURL)
            }
        }
        .eraseToAnyView()

        return .init(
            date: date,
            mediaSource: mediaSource,
            isViewed: isViewed,
            duration: duration,
            content: content
        )
    }
}
