import Foundation

extension Stories {
    /// State model for Stories view
    struct ViewState: Identifiable, Hashable {
        let id = UUID()
        let groups: [StoriesGroupModel]
        let progressBar: ProgressBar
        let current: Current?
        let isPaused: Bool

        struct ProgressBar: Identifiable, Hashable {
            let id = UUID()
            let progress: CGFloat
            let duration: TimeInterval
        }

        struct Current: Identifiable, Hashable {
            let id = UUID()
            let group: StoriesGroupModel
            let page: StoriesPageModel
        }
    }
}
