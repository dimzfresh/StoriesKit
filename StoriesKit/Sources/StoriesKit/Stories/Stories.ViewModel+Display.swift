import Foundation

extension Stories.ViewModel {
    func currentPage(for group: StoriesGroupModel) -> StoriesPageModel? {
        StoriesViewStateMapper.currentPage(for: group, in: state.current)
    }

    func progressBars(for group: StoriesGroupModel) -> [Stories.ViewState.ProgressBar] {
        StoriesViewStateMapper.progressBars(for: group, in: state.current)
    }
}
