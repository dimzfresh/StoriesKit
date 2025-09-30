import SwiftUI

/// SwiftUI view for displaying story progress bar
struct ProgressBarView: View {
    let progress: CGFloat
    let duration: TimeInterval
    let height: CGFloat
    
    init(
        progress: CGFloat,
        duration: TimeInterval,
        height: CGFloat = 2
    ) {
        self.progress = progress
        self.duration = duration
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white.opacity(0.3))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: height)
    }
}
