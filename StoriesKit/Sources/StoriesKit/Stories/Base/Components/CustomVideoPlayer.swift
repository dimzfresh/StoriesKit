import SwiftUI
import AVFoundation
import AVKit
import Combine

struct VideoPlayerRepresentable: UIViewControllerRepresentable {
    let videoSource: StoriesMediaModel.MediaSource.VideoType
    let videoManager: StoriesVideoManager
    let isMuted: Bool
    let shouldLoop: Bool
    let isActive: Bool
    let playbackState: StoriesVideoManager.State
    let managerGeneration: Int
    let onPlaybackEnd: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear

        guard let playerItem = makePlayerItem(for: videoSource) else { return controller }

        playerItem.preferredForwardBufferDuration = 0.5

        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = isMuted
        player.automaticallyWaitsToMinimizeStalling = false

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = controller.view.bounds
        controller.view.layer.addSublayer(playerLayer)

        context.coordinator.configure(
            player: player,
            playerItem: playerItem,
            playerLayer: playerLayer,
            generation: managerGeneration,
            videoManager: videoManager
        )

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        context.coordinator.playerLayer?.frame = uiViewController.view.bounds
        context.coordinator.updatePlayback(
            isActive: isActive,
            playbackState: playbackState,
            managerGeneration: managerGeneration
        )
    }

    static func dismantleUIViewController(
        _ uiViewController: UIViewController,
        coordinator: Coordinator
    ) {
        coordinator.teardown()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(shouldLoop: shouldLoop, onPlaybackEnd: onPlaybackEnd)
    }

    private func makePlayerItem(for source: StoriesMediaModel.MediaSource.VideoType) -> AVPlayerItem? {
        switch source {
        case let .local(asset):
            return AVPlayerItem(asset: asset)
        case let .remote(url):
            guard let url else { return nil }
            return AVPlayerItem(url: url)
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        private let shouldLoop: Bool
        private let onPlaybackEnd: (() -> Void)?

        private var videoManager: StoriesVideoManager?
        private var player: AVPlayer?
        private var playerItem: AVPlayerItem?
        fileprivate var playerLayer: AVPlayerLayer?
        private var timeObserver: Any?
        private var statusObservation: NSKeyValueObservation?
        private var subscriptions = Set<AnyCancellable>()
        private var generation = 0
        private var isActive = false

        init(
            shouldLoop: Bool,
            onPlaybackEnd: (() -> Void)?
        ) {
            self.shouldLoop = shouldLoop
            self.onPlaybackEnd = onPlaybackEnd
            super.init()
        }

        func configure(
            player: AVPlayer,
            playerItem: AVPlayerItem,
            playerLayer: AVPlayerLayer,
            generation: Int,
            videoManager: StoriesVideoManager
        ) {
            teardown()

            self.player = player
            self.playerItem = playerItem
            self.playerLayer = playerLayer
            self.generation = generation
            self.videoManager = videoManager

            observeDuration(playerItem: playerItem)
            observeProgress(player: player, playerItem: playerItem)
            observePlaybackEnd(player: player, playerItem: playerItem)
        }

        func updatePlayback(
            isActive: Bool,
            playbackState: StoriesVideoManager.State,
            managerGeneration: Int
        ) {
            self.isActive = isActive
            applyPlayback(playbackState: playbackState, managerGeneration: managerGeneration)
        }

        func teardown() {
            subscriptions.removeAll()

            if let timeObserver, let player {
                player.removeTimeObserver(timeObserver)
            }
            timeObserver = nil

            statusObservation?.invalidate()
            statusObservation = nil

            player?.pause()
            player?.replaceCurrentItem(with: nil)
            player = nil
            playerItem = nil
            playerLayer = nil
            videoManager = nil
        }

        private func applyPlayback(
            playbackState: StoriesVideoManager.State,
            managerGeneration: Int
        ) {
            guard let player else { return }

            guard isActive, generation == managerGeneration else {
                player.pause()
                return
            }

            switch playbackState {
            case .playing:
                player.play()
            case .paused, .idle:
                player.pause()
            }
        }

        private func observeDuration(playerItem: AVPlayerItem) {
            let report = { [weak self] in
                let seconds = playerItem.duration.seconds
                Task { @MainActor [weak self] in
                    guard let self, let videoManager else { return }
                    videoManager.reportDuration(seconds, generation: generation)
                }
            }

            if playerItem.status == .readyToPlay {
                report()
            }

            statusObservation = playerItem.observe(\.status, options: [.new]) { item, _ in
                guard item.status == .readyToPlay else { return }
                report()
            }
        }

        private func observeProgress(player: AVPlayer, playerItem: AVPlayerItem) {
            let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                let duration = playerItem.duration.seconds
                guard duration.isFinite, duration > 0 else { return }

                let progress = CGFloat(time.seconds / duration)
                Task { @MainActor [weak self] in
                    guard let self, let videoManager else { return }
                    videoManager.reportProgress(progress, generation: generation)
                }
            }
        }

        private func observePlaybackEnd(player: AVPlayer, playerItem: AVPlayerItem) {
            NotificationCenter.default.publisher(
                for: .AVPlayerItemDidPlayToEndTime,
                object: playerItem
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, let videoManager, let player = self.player else { return }

                    if shouldLoop {
                        player.seek(to: .zero)
                        player.play()
                        videoManager.reportProgress(0, generation: generation)
                    } else {
                        videoManager.reportEnded(generation: generation)
                        onPlaybackEnd?()
                    }
                }
            }
            .store(in: &subscriptions)
        }
    }
}

struct VideoPlayerView: View {
    @ObservedObject var videoManager: StoriesVideoManager

    let videoSource: StoriesMediaModel.MediaSource.VideoType
    let isMuted: Bool
    let shouldLoop: Bool
    let isActive: Bool
    let onPlaybackEnd: (() -> Void)?

    var body: some View {
        VideoPlayerRepresentable(
            videoSource: videoSource,
            videoManager: videoManager,
            isMuted: isMuted,
            shouldLoop: shouldLoop,
            isActive: isActive,
            playbackState: videoManager.state,
            managerGeneration: videoManager.generation,
            onPlaybackEnd: onPlaybackEnd
        )
        .transition(.opacity.animation(.easeInOut(duration: 0.2)))
    }
}
