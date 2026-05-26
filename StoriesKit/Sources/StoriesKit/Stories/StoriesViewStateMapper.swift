import Foundation

enum StoriesViewStateMapper {
    static func currentPage(
        for group: StoriesGroupModel,
        in session: Stories.ViewState.Current?
    ) -> StoriesPageModel? {
        guard let session else {
            return group.pages.first { !$0.isViewed } ?? group.pages.first
        }

        if session.selectedGroup.id == group.id {
            return session.activePages[group.id]
        }

        if let activePage = session.activePages[group.id] {
            return activePage
        }

        return group.pages.first { !$0.isViewed } ?? group.pages.first
    }

    static func progressBars(
        for group: StoriesGroupModel,
        in session: Stories.ViewState.Current?
    ) -> [Stories.ViewState.ProgressBar] {
        guard let session else {
            return group.pages.map {
                .init(progress: 0, duration: $0.duration)
            }
        }

        if group.id == session.selectedGroup.id {
            return group.pages.map { page in
                let isCurrent = page.id == session.activePages[group.id]?.id
                let isViewed = isPageCompleted(page, in: group, session: session)
                return .init(
                    progress: isCurrent ? 0 : isViewed ? 1.0 : 0.0,
                    duration: page.duration
                )
            }
        }

        let currentPageId = session.activePages[group.id]?.id
        let currentPageIndex = group.pages.firstIndex(where: { $0.id == currentPageId }) ?? -1

        return group.pages.enumerated().map { index, page in
            let isCurrent = page.id == currentPageId
            let progress = isCurrent ? 0.0 : (index < currentPageIndex ? (page.isViewed ? 1.0 : 0.0) : 0.0)

            return .init(
                progress: progress,
                duration: page.duration
            )
        }
    }

    private static func isPageCompleted(
        _ page: StoriesPageModel,
        in group: StoriesGroupModel,
        session: Stories.ViewState.Current
    ) -> Bool {
        guard let activePage = session.activePages[group.id],
              let currentPageIndex = group.pages.firstIndex(where: { $0.id == activePage.id }),
              let pageIndex = group.pages.firstIndex(where: { $0.id == page.id }) else {
            return false
        }

        return pageIndex < currentPageIndex
    }
}
