import SwiftUI
import AVFoundation
import AVKit
import Combine

// MARK: - Video Player State Manager

public class VideoPlayerStateManager: ObservableObject {
    public static let shared = VideoPlayerStateManager()
    
    @Published public private(set) var currentState: VideoPlayerState = .idle
    
    public let currentPlayer = AVPlayer()

    private init() {}
    
    public func setCurrentPlayerItem(_ playerItem: AVPlayerItem?) {
        currentPlayer.replaceCurrentItem(with: playerItem)
    }
    
    public func setState(_ state: VideoPlayerState) {
        DispatchQueue.main.async {
            self.currentState = state
        }
    }
    
    public func setPlaying() {
        setState(.playing)
        currentPlayer.play()
    }
    
    public func setPaused() {
        setState(.paused)
        currentPlayer.pause()
    }
    
    public func setIdle() {
        setState(.idle)
        currentPlayer.pause()
    }

    public enum VideoPlayerState {
        case idle
        case playing
        case paused
    }
}

public struct VideoPlayerRepresentable: UIViewControllerRepresentable {
    private let videoSource: StoriesMediaModel.MediaSource.VideoType
    private let isMuted: Bool
    private let shouldLoop: Bool
    private let onPlaybackEnd: (() -> Void)?
    private let stateManager: VideoPlayerStateManager
    private let playerBinding: Binding<AVPlayer?>?
    
    public init(
        videoSource: StoriesMediaModel.MediaSource.VideoType,
        isMuted: Bool = false,
        shouldLoop: Bool = true,
        onPlaybackEnd: (() -> Void)? = nil,
        stateManager: VideoPlayerStateManager = .shared,
        playerBinding: Binding<AVPlayer?>? = nil
    ) {
        self.videoSource = videoSource
        self.isMuted = isMuted
        self.shouldLoop = shouldLoop
        self.onPlaybackEnd = onPlaybackEnd
        self.stateManager = stateManager
        self.playerBinding = playerBinding
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.modalTransitionStyle = .crossDissolve
        
        let playerItem: AVPlayerItem
        switch videoSource {
        case let .local(asset):
            playerItem = .init(asset: asset)
        case let .remote(url):
            playerItem = .init(url: url)
        }
        
        playerItem.preferredForwardBufferDuration = 0.5
        
        let player = stateManager.currentPlayer
        player.isMuted = isMuted
        player.automaticallyWaitsToMinimizeStalling = false
        
        stateManager.setCurrentPlayerItem(playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = controller.view.bounds
        
        controller.view.layer.addSublayer(playerLayer)
        controller.view.backgroundColor = .clear
        
        context.coordinator.player = player
        context.coordinator.playerLayer = playerLayer
        
        DispatchQueue.main.async {
            playerBinding?.wrappedValue = player
        }
        
        player.play()
        stateManager.setPlaying()
        
        return controller
    }
    
    public func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        if let playerLayer = context.coordinator.playerLayer {
            playerLayer.frame = uiViewController.view.bounds
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(self)
    }
    
    public class Coordinator: NSObject {
        private let parent: VideoPlayerRepresentable
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        
        init(_ parent: VideoPlayerRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}

public struct VideoPlayerView: View {
    private let videoSource: StoriesMediaModel.MediaSource.VideoType
    private let isMuted: Bool
    private let shouldLoop: Bool
    private let onPlaybackEnd: (() -> Void)?
    private let stateManager: VideoPlayerStateManager
    
    @State private var player: AVPlayer?
    
    public init(
        videoSource: StoriesMediaModel.MediaSource.VideoType,
        isMuted: Bool = false,
        shouldLoop: Bool = true,
        onPlaybackEnd: (() -> Void)? = nil,
        stateManager: VideoPlayerStateManager = .shared
    ) {
        self.videoSource = videoSource
        self.isMuted = isMuted
        self.shouldLoop = shouldLoop
        self.onPlaybackEnd = onPlaybackEnd
        self.stateManager = stateManager
    }
    
    public var body: some View {
        VideoPlayerRepresentable(
            videoSource: videoSource,
            isMuted: isMuted,
            shouldLoop: shouldLoop,
            onPlaybackEnd: onPlaybackEnd,
            stateManager: stateManager,
            playerBinding: $player
        )
        .transition(.opacity.animation(.easeInOut(duration: 0.1)))
    }
}
