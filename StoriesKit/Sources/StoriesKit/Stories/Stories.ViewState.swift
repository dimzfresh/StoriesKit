import Foundation
import SwiftUI

extension Stories {
    /// State model for Stories view
    struct ViewState: Identifiable, Hashable {
        let id = UUID()
        let groups: [StoriesGroupModel]
        let progressBar: ProgressBar
        let current: Current?
        let isPaused: Bool

        init(
            groups: [StoriesGroupModel],
            progressBar: ProgressBar,
            current: Current?,
            isPaused: Bool = false
        ) {
            self.groups = groups
            self.progressBar = progressBar
            self.current = current
            self.isPaused = isPaused
        }

        struct ProgressBar: Identifiable, Hashable {
            let id = UUID()
            let progress: CGFloat
            let duration: TimeInterval
        }

        struct Current: Identifiable, Hashable {
            let id = UUID()
            let selectedGroup: StoriesGroupModel
            let activePages: [String: StoriesPageModel]
        }

        static let `default` = Self(
            groups: [],
            progressBar: .init(
                progress: 0,
                duration: 5
            ),
            current: nil
        )
    }
}
