import Foundation

extension Stories {
    /// State model for Stories view
    struct ViewState: Identifiable, Hashable {
        let id = UUID()
        let groups: [StoriesGroupModel]
        let progressBar: ProgressBar
        let groupIndex: Int
        let pageIndex: Int
        let isPaused: Bool

        /// Progress bar state for individual stories
        struct ProgressBar: Identifiable, Hashable {
            let id = UUID()
            let progress: CGFloat
            let duration: TimeInterval
        }
    }
}
