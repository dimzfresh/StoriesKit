import Combine
import Foundation

/// Video playback for a single stories session.
@MainActor
public final class StoriesVideoManager: ObservableObject {
    @Published public private(set) var state: State = .idle
    @Published public private(set) var progress: CGFloat = 0
    @Published public private(set) var contentDuration: TimeInterval?
    @Published public private(set) var generation = 0

    let didEnd = PassthroughSubject<Void, Never>()

    public init() {}

    public func play() {
        state = .playing
    }

    public func pause() {
        state = .paused
    }

    public func stop() {
        state = .idle
    }

    public func reset() {
        generation += 1
        progress = 0
        contentDuration = nil
        state = .idle
    }

    public func reportProgress(
        _ value: CGFloat,
        generation session: Int
    ) {
        guard session == generation else { return }

        let clamped = min(max(value, 0), 1)
        progress = clamped
    }

    public func reportDuration(
        _ duration: TimeInterval,
        generation session: Int
    ) {
        guard session == generation, duration.isFinite, duration > 0 else { return }

        contentDuration = duration
    }

    public func reportEnded(generation session: Int) {
        guard session == generation else { return }

        progress = 1
        didEnd.send()
    }

    public enum State {
        case idle
        case playing
        case paused
    }
}
