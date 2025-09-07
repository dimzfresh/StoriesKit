import Foundation
import Combine

/// Timer utility for managing story duration and progress
final class CountDownTimer {
    private var timer: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private var startTime: Date?
    private var pauseTime: Date?
    private var accumulatedPauseTime = 0.0
    private var isPaused = false
    
    private let onProgressUpdate: (CGFloat) -> Void
    private let onStoryComplete: () -> Void
    
    init(
        onProgressUpdate: @escaping (CGFloat) -> Void,
        onStoryComplete: @escaping () -> Void
    ) {
        self.onProgressUpdate = onProgressUpdate
        self.onStoryComplete = onStoryComplete
    }
    
    func start(duration: TimeInterval) {
        stop()
        
        startTime = .now
        accumulatedPauseTime = 0
        isPaused = false
        
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgress(duration: duration)
            }
        
        timer?.store(in: &subscriptions)
    }
    
    func pause() {
        guard !isPaused else { return }

        isPaused = true
        pauseTime = .now
        timer?.cancel()
        timer = nil
    }
    
    func resume(duration: TimeInterval) {
        guard isPaused else { return }

        if let pauseTime {
            accumulatedPauseTime += Date().timeIntervalSince(pauseTime)
        }
        
        isPaused = false
        self.pauseTime = nil
        
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateProgress(duration: duration)
            }
        
        timer?.store(in: &subscriptions)
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        isPaused = false
    }
    
    func reset() {
        stop()
        startTime = nil
        accumulatedPauseTime = 0
    }
    
    private func updateProgress(duration: TimeInterval) {
        guard let startTime, !isPaused else { return }
        
        let elapsed = Date().timeIntervalSince(startTime) - accumulatedPauseTime
        let progress = CGFloat(elapsed / duration)
        
        if progress >= 1.0 {
            onStoryComplete()
        } else {
            onProgressUpdate(progress)
        }
    }
}
