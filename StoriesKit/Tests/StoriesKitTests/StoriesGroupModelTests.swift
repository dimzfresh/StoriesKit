import SwiftUI
import UIKit
@testable import StoriesKit
import Testing

struct StoriesGroupModelTests {
    @Test func isFullyViewed_whenAllPagesViewed_returnsTrue() {
        let group = StoriesGroupModel(
            id: "1",
            title: "User",
            avatarImage: .local(UIImage()),
            pages: [
                .init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: true),
                .init(date: "yesterday", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: true)
            ]
        )

        #expect(group.isFullyViewed)
    }

    @Test func isFullyViewed_whenAnyPageUnviewed_returnsFalse() {
        let group = StoriesGroupModel(
            id: "1",
            title: "User",
            avatarImage: .local(UIImage()),
            pages: [
                .init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: true),
                .init(date: "yesterday", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: false)
            ]
        )

        #expect(!group.isFullyViewed)
    }

    @Test func sortedForDisplay_placesUnviewedGroupsFirst() {
        let unviewed = StoriesGroupModel(
            id: "2",
            title: "B",
            avatarImage: .local(UIImage()),
            pages: [.init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: false)]
        )
        let viewed = StoriesGroupModel(
            id: "1",
            title: "A",
            avatarImage: .local(UIImage()),
            pages: [.init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: true)]
        )

        let sorted = StoriesGroupModel.sortedForDisplay([viewed, unviewed])

        #expect(sorted.map(\.id) == ["2", "1"])
    }

    @Test func sortedForDisplay_sortsByIdWithinSameViewState() {
        let groupB = StoriesGroupModel(
            id: "2",
            title: "B",
            avatarImage: .local(UIImage()),
            pages: [.init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: false)]
        )
        let groupA = StoriesGroupModel(
            id: "1",
            title: "A",
            avatarImage: .local(UIImage()),
            pages: [.init(date: "today", mediaSource: .init(media: .image(.local(UIImage()))), isViewed: false)]
        )

        let sorted = StoriesGroupModel.sortedForDisplay([groupB, groupA])

        #expect(sorted.map(\.id) == ["1", "2"])
    }
}

struct StoriesPageModelTests {
    @Test func updateViewed_preservesLayoutFields() {
        let padding = EdgeInsets(top: 60, leading: 8, bottom: 40, trailing: 8)
        let page = StoriesPageModel(
            date: "today",
            mediaSource: .init(media: .image(.local(UIImage()))),
            isViewed: false,
            duration: 7,
            padding: padding,
            cornerRadius: 16
        )

        let updated = page.updateViewed(true)

        #expect(updated.isViewed)
        #expect(updated.padding == padding)
        #expect(updated.cornerRadius == 16)
        #expect(updated.duration == 7)
    }
}

struct StoriesMediaModelTests {
    @Test func remoteString_withInvalidURL_producesNilURL() {
        let image = StoriesMediaModel.MediaSource.ImageType.remote("")
        guard case let .remote(url) = image else {
            Issue.record("Expected remote case")
            return
        }
        #expect(url == nil)
    }

    @Test func remoteString_withValidURL_producesURL() {
        let image = StoriesMediaModel.MediaSource.ImageType.remote("https://example.com/a.jpg")
        guard case let .remote(url) = image else {
            Issue.record("Expected remote case")
            return
        }
        #expect(url?.absoluteString == "https://example.com/a.jpg")
    }
}
