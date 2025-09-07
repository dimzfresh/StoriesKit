import SwiftUI
import StoriesKit

struct StoriesView: View {
    let selectedGroup: StoriesGroupModel
    let groups: [StoriesGroupModel]
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Stories.build(
                groups: groups,
                delegate: SimpleStoriesDelegate(onClose: onClose)
            )
            .ignoresSafeArea()
        }
    }
    
    private func avatarURL(for group: StoriesGroupModel) -> URL? {
        if case .url(let url) = group.avatarImage {
            return url
        }
        return nil
    }
}

final class SimpleStoriesDelegate: IStoriesDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    func didClose() {
        onClose()
    }
    
    func didOpenLink(url: URL) {}
    
    func didOpenStory(storyId: String) {}
}
