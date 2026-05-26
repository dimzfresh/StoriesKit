import Combine
import Foundation

extension Stories.ViewModel {
    func isCurrentPageVideo() -> Bool {
        guard let page = getCurrentPage() else { return false }

        if case .video = page.mediaSource.media { return true }

        return false
    }

    func effectiveDuration(for page: StoriesPageModel?) -> TimeInterval {
        guard let page else { return 5 }

        if case .video = page.mediaSource.media,
           let videoDuration = stateManager.videoManager.contentDuration {
            return videoDuration
        }

        return page.duration
    }

    func syncVideoForCurrentPage(play: Bool) {
        let playback = stateManager.videoManager
        if isCurrentPageVideo() {
            if play {
                playback.play()
            } else {
                playback.pause()
            }
        } else {
            playback.reset()
        }
    }
}
