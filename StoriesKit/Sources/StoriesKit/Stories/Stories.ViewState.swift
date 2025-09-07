import Foundation

extension Stories {
    struct ViewState: Identifiable, Hashable {
        let id = UUID()
        let groups: [StoriesGroupModel]
        let progressBar: ProgressBar
        let groupIndex: Int
        let pageIndex: Int
        let isPaused: Bool

        struct ProgressBar: Identifiable, Hashable {
            let id = UUID()
            let progress: CGFloat
            let duration: TimeInterval
        }
    }
}
