import Combine
import Foundation

public class VideoPlayerStateManager: ObservableObject {
    public static let shared = VideoPlayerStateManager()
    
    @Published public private(set) var currentState: VideoPlayerState = .idle

    private init() {}
    
    public func setState(_ state: VideoPlayerState) {
        Task { @MainActor in
            self.currentState = state
        }
    }
    
    public func setPlaying() {
        setState(.playing)
    }
    
    public func setPaused() {
        setState(.paused)
    }
    
    public func setIdle() {
        setState(.idle)
    }

    public enum VideoPlayerState {
        case idle
        case playing
        case paused
    }
}
