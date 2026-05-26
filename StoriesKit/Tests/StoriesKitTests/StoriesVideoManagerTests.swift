@testable import StoriesKit
import Testing

@MainActor
struct StoriesVideoManagerTests {
    @Test func reset_incrementsGenerationAndClearsProgress() {
        let manager = StoriesVideoManager()
        manager.reportProgress(0.5, generation: 0)
        manager.reportDuration(10, generation: 0)
        manager.play()

        manager.reset()

        #expect(manager.generation == 1)
        #expect(manager.progress == 0)
        #expect(manager.contentDuration == nil)
        #expect(manager.state == .idle)
    }

    @Test func reportProgress_ignoresStaleGeneration() {
        let manager = StoriesVideoManager()

        manager.reportProgress(0.75, generation: 99)

        #expect(manager.progress == 0)
    }

    @Test func reportProgress_clampsToZeroAndOne() {
        let manager = StoriesVideoManager()

        manager.reportProgress(1.5, generation: 0)
        #expect(manager.progress == 1)

        manager.reportProgress(-0.2, generation: 0)
        #expect(manager.progress == 0)
    }

    @Test func reportEnded_setsProgressAndPublishesEvent() async {
        let manager = StoriesVideoManager()
        var didEnd = false
        let cancellable = manager.didEnd.sink {
            didEnd = true
        }

        manager.reportEnded(generation: 0)

        #expect(manager.progress == 1)
        #expect(didEnd)

        _ = cancellable
    }

    @Test func playPauseStop_updateState() {
        let manager = StoriesVideoManager()

        manager.play()
        #expect(manager.state == .playing)

        manager.pause()
        #expect(manager.state == .paused)

        manager.stop()
        #expect(manager.state == .idle)
    }
}
