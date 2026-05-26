import Foundation

extension Stories.ViewModel {
    func startCurrentPageTimer() {
        guard let currentPage = getCurrentPage() else { return }

        let playback = stateManager.videoManager

        if isCurrentPageVideo() {
            timer?.stop()
            playback.reset()
            progressModel.startVideo()
            if let current = state.current {
                updateState(
                    groups: sessionGroups,
                    progress: 0,
                    duration: effectiveDuration(for: currentPage),
                    selectedGroup: current.selectedGroup,
                    activePages: current.activePages,
                    isPaused: false
                )
            }
            playback.play()
        } else {
            playback.stop()
            playback.reset()
            progressModel.startTimeline(duration: currentPage.duration)
            timer?.start(duration: currentPage.duration)
        }

        markCurrentPageViewed()
    }

    func pauseCurrentPageTimer() {
        timer?.pause()
        progressModel.pauseTimeline()
        syncVideoForCurrentPage(play: false)

        guard let current = state.current else { return }

        updateState(
            groups: sessionGroups,
            progress: currentPlaybackProgress,
            duration: effectiveDuration(for: getCurrentPage()),
            selectedGroup: current.selectedGroup,
            activePages: current.activePages,
            isPaused: true
        )
    }

    func resumeCurrentPageTimer() {
        guard let currentPage = getCurrentPage(), let current = state.current else { return }

        if isCurrentPageVideo() {
            stateManager.videoManager.play()
        } else {
            progressModel.resumeTimeline()
            timer?.resume(duration: currentPage.duration)
            stateManager.videoManager.stop()
        }

        updateState(
            groups: sessionGroups,
            progress: currentPlaybackProgress,
            duration: effectiveDuration(for: currentPage),
            selectedGroup: current.selectedGroup,
            activePages: current.activePages,
            isPaused: false
        )
    }

    func handleStoryComplete() {
        handleNextTap()
    }

    func updateProgress(_ progress: CGFloat) {
        progressModel.setVideoProgress(progress)
    }
}
