import Combine
import Foundation

/// Isolated progress publisher so timer/video ticks don't re-render story pages.
@MainActor
final class StoriesProgressModel: ObservableObject {
    enum Mode: Equatable {
        case idle
        case timeline(
            sessionID: UUID,
            duration: TimeInterval,
            startedAt: Date,
            accumulatedPause: TimeInterval,
            pausedAt: Date?
        )
        case video
    }

    @Published private(set) var mode: Mode = .idle
    @Published private(set) var videoProgress: CGFloat = 0

    var value: CGFloat {
        switch mode {
        case .idle: 0
        case .timeline: progress(at: .now)
        case .video: videoProgress
        }
    }

    var isPaused: Bool {
        if case .timeline(_, _, _, _, let pausedAt) = mode {
            return pausedAt != nil
        }
        return false
    }

    var isVideoActive: Bool {
        if case .video = mode { return true }
        return false
    }

    var timelineSessionID: UUID? {
        if case .timeline(let sessionID, _, _, _, _) = mode {
            return sessionID
        }
        return nil
    }

    func reset() {
        mode = .idle
        videoProgress = 0
    }

    func startTimeline(duration: TimeInterval) {
        mode = .timeline(
            sessionID: UUID(),
            duration: duration,
            startedAt: .now,
            accumulatedPause: 0,
            pausedAt: nil
        )
    }

    func pauseTimeline() {
        guard case .timeline(let sessionID, let duration, let startedAt, let accumulatedPause, nil) = mode else {
            return
        }

        mode = .timeline(
            sessionID: sessionID,
            duration: duration,
            startedAt: startedAt,
            accumulatedPause: accumulatedPause,
            pausedAt: .now
        )
    }

    func resumeTimeline() {
        guard case .timeline(let sessionID, let duration, let startedAt, let accumulatedPause, let pausedAt?) = mode else {
            return
        }

        let additionalPause = Date().timeIntervalSince(pausedAt)
        mode = .timeline(
            sessionID: sessionID,
            duration: duration,
            startedAt: startedAt,
            accumulatedPause: accumulatedPause + additionalPause,
            pausedAt: nil
        )
    }

    func startVideo() {
        mode = .video
        videoProgress = 0
    }

    func setVideoProgress(_ progress: CGFloat) {
        guard case .video = mode else { return }
        videoProgress = min(max(progress, 0), 1)
    }

    func progress(at date: Date) -> CGFloat {
        guard case .timeline(_, let duration, let startedAt, let accumulatedPause, let pausedAt) = mode,
              duration > 0 else {
            return 0
        }

        var elapsed = date.timeIntervalSince(startedAt) - accumulatedPause
        if let pausedAt {
            elapsed -= date.timeIntervalSince(pausedAt)
        }

        return min(max(CGFloat(elapsed / duration), 0), 1)
    }
}
