import UIKit
import Testing
@testable import StoriesKit

struct StoriesViewStateMapperTests {
    @Test func currentPage_returnsActivePageForSelectedGroup() {
        let page1 = StoriesMapperFixtures.page(id: "p1")
        let page2 = StoriesMapperFixtures.page(id: "p2")
        let group = StoriesMapperFixtures.group(id: "g1", pages: [page1, page2])
        let session = Stories.ViewState.Current(
            selectedGroup: group,
            activePages: ["g1": page2]
        )

        let result = StoriesViewStateMapper.currentPage(for: group, in: session)

        #expect(result?.id == "p2")
    }

    @Test func currentPage_returnsFirstUnviewedForOtherGroup() {
        let page1 = StoriesMapperFixtures.page(id: "p1", isViewed: true)
        let page2 = StoriesMapperFixtures.page(id: "p2")
        let group = StoriesMapperFixtures.group(id: "g2", pages: [page1, page2])
        let selectedGroup = StoriesMapperFixtures.group(id: "g1", pages: [StoriesMapperFixtures.page(id: "g1-p1")])
        let session = Stories.ViewState.Current(
            selectedGroup: selectedGroup,
            activePages: ["g1": selectedGroup.pages[0]]
        )

        let result = StoriesViewStateMapper.currentPage(for: group, in: session)

        #expect(result?.id == "p2")
    }

    @Test func progressBars_marksCompletedPagesForSelectedGroup() {
        let page1 = StoriesMapperFixtures.page(id: "p1")
        let page2 = StoriesMapperFixtures.page(id: "p2")
        let group = StoriesMapperFixtures.group(id: "g1", pages: [page1, page2])
        let session = Stories.ViewState.Current(
            selectedGroup: group,
            activePages: ["g1": page2]
        )

        let bars = StoriesViewStateMapper.progressBars(for: group, in: session)

        #expect(bars.count == 2)
        #expect(bars[0].progress == 1.0)
        #expect(bars[1].progress == 0.0)
    }

    @Test func progressBars_returnsZeroProgressWithoutSession() {
        let page = StoriesMapperFixtures.page(id: "p1")
        let group = StoriesMapperFixtures.group(id: "g1", pages: [page])

        let bars = StoriesViewStateMapper.progressBars(for: group, in: nil)

        #expect(bars.count == 1)
        #expect(bars[0].progress == 0.0)
    }
}

private enum StoriesMapperFixtures {
    static func page(
        id: String,
        isViewed: Bool = false,
        duration: TimeInterval = 5
    ) -> StoriesPageModel {
        .init(
            id: id,
            date: "today",
            mediaSource: .init(media: .image(.local(UIImage()))),
            isViewed: isViewed,
            duration: duration
        )
    }

    static func group(id: String, pages: [StoriesPageModel]) -> StoriesGroupModel {
        .init(
            id: id,
            title: id,
            avatarImage: .local(UIImage()),
            pages: pages
        )
    }
}
