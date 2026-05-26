import UIKit
@testable import StoriesKit
import Testing

@MainActor
struct StoriesViewModelTests {
    @Test func init_selectsFirstUnviewedPageInSelectedGroup() {
        let page1 = StoriesTestFixtures.page(id: "p1")
        let page2 = StoriesTestFixtures.page(id: "p2", isViewed: true)
        let group = StoriesTestFixtures.group(id: "g1", pages: [page1, page2])
        let viewModel = makeViewModel(groups: [group], selectedGroupId: "g1")

        #expect(viewModel.getCurrentPage()?.id == "p1")
        #expect(viewModel.state.current?.selectedGroup.id == "g1")
    }

    @Test func didTapNext_advancesToNextPageInGroup() {
        let page1 = StoriesTestFixtures.page(id: "p1")
        let page2 = StoriesTestFixtures.page(id: "p2")
        let group = StoriesTestFixtures.group(id: "g1", pages: [page1, page2])
        let viewModel = makeViewModel(groups: [group], selectedGroupId: "g1")

        viewModel.send(.didTapNext)

        #expect(viewModel.getCurrentPage()?.id == "p2")
        #expect(viewModel.progressModel.value < 0.01)
    }

    @Test func didTapNext_onLastPage_switchesToNextGroup() {
        let group1 = StoriesTestFixtures.group(
            id: "g1",
            pages: [StoriesTestFixtures.page(id: "g1-p1")]
        )
        let group2 = StoriesTestFixtures.group(
            id: "g2",
            pages: [StoriesTestFixtures.page(id: "g2-p1")]
        )
        let viewModel = makeViewModel(groups: [group1, group2], selectedGroupId: "g1")

        viewModel.send(.didTapNext)

        #expect(viewModel.state.current?.selectedGroup.id == "g2")
        #expect(viewModel.getCurrentPage()?.id == "g2-p1")
    }

    @Test func didPauseTimer_setsPausedState() {
        let group = StoriesTestFixtures.group(
            id: "g1",
            pages: [StoriesTestFixtures.page(id: "p1")]
        )
        let viewModel = makeViewModel(groups: [group], selectedGroupId: "g1")

        viewModel.send(.didAppear)
        viewModel.send(.didPauseTimer)

        #expect(viewModel.state.isPaused)
    }

    @Test func didResumeTimer_clearsPausedState() {
        let group = StoriesTestFixtures.group(
            id: "g1",
            pages: [StoriesTestFixtures.page(id: "p1")]
        )
        let viewModel = makeViewModel(groups: [group], selectedGroupId: "g1")

        viewModel.send(.didAppear)
        viewModel.send(.didPauseTimer)
        viewModel.send(.didResumeTimer)

        #expect(!viewModel.state.isPaused)
    }

    @Test func didTapNext_onLastPageOfLastGroup_dismisses() async {
        let group = StoriesTestFixtures.group(
            id: "g1",
            pages: [StoriesTestFixtures.page(id: "p1")]
        )
        let viewModel = makeViewModel(groups: [group], selectedGroupId: "g1")

        viewModel.send(.didTapNext)

        try? await Task.sleep(nanoseconds: 400_000_000)

        #expect(viewModel.stateManager.state.selectedGroupId == nil)
        #expect(viewModel.stateManager.state.groups.first?.pages.first?.isViewed == true)
    }

    @Test func didTapNext_onLastPage_switchesToNextGroupInSessionOrder() {
        let group1 = StoriesTestFixtures.group(
            id: "g1",
            pages: [StoriesTestFixtures.page(id: "g1-p1")]
        )
        let group2 = StoriesTestFixtures.group(
            id: "g2",
            pages: [StoriesTestFixtures.page(id: "g2-p1")]
        )
        let group3 = StoriesTestFixtures.group(
            id: "g3",
            pages: [StoriesTestFixtures.page(id: "g3-p1")]
        )
        let viewModel = makeViewModel(groups: [group1, group2, group3], selectedGroupId: "g2")

        viewModel.send(.didTapPrevious)

        #expect(viewModel.state.current?.selectedGroup.id == "g1")

        viewModel.send(.didTapNext)

        #expect(viewModel.state.current?.selectedGroup.id == "g2")
    }

    @Test func didTapNext_afterFullyViewingGroup_keepsSessionOrder() {
        let group1 = StoriesTestFixtures.group(
            id: "a",
            pages: [StoriesTestFixtures.page(id: "a-p1")]
        )
        let group2 = StoriesTestFixtures.group(
            id: "b",
            pages: [StoriesTestFixtures.page(id: "b-p1")]
        )
        let group3 = StoriesTestFixtures.group(
            id: "c",
            pages: [StoriesTestFixtures.page(id: "c-p1")]
        )
        let viewModel = makeViewModel(groups: [group1, group2, group3], selectedGroupId: "a")

        viewModel.send(.didTapNext)

        #expect(viewModel.state.current?.selectedGroup.id == "b")

        viewModel.send(.didTapPrevious)

        #expect(viewModel.state.current?.selectedGroup.id == "a")
    }

    @Test func didViewPage_skipsAlreadyViewedPage() {
        let page = StoriesTestFixtures.page(id: "p1", isViewed: true)
        let group = StoriesTestFixtures.group(id: "g1", pages: [page])
        let stateManager = StoriesStateManager(model: StoriesModel(groups: [group]))

        stateManager.send(.didViewPage("g1", "p1"))

        #expect(stateManager.state.event == nil)
    }

    private func makeViewModel(
        groups: [StoriesGroupModel],
        selectedGroupId: String? = nil
    ) -> Stories.ViewModel {
        let stateManager = StoriesStateManager(model: StoriesModel(groups: groups))
        if let selectedGroupId {
            stateManager.send(.didSwitchGroup(selectedGroupId))
        }
        return Stories.ViewModel(stateManager: stateManager)
    }
}

private enum StoriesTestFixtures {
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
