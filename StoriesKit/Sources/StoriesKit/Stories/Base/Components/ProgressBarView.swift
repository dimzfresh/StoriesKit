import SwiftUI

/// SwiftUI view for displaying story progress bar
struct ProgressBarView: View {
    @Binding var progress: CGFloat
    @Binding var duration: TimeInterval
    let height: CGFloat

    @State private var trackWidth: CGFloat = 0

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 1)
                .fill(.white.opacity(0.3))
                .frame(height: height)

            RoundedRectangle(cornerRadius: 1)
                .fill(.white)
                .frame(width: trackWidth * clampedProgress, height: height)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        trackWidth = geometry.size.width
                    }
                    .onChange(of: geometry.size.width) { width in
                        trackWidth = width
                    }
            }
        }
    }

    init(
        progress: Binding<CGFloat>,
        duration: Binding<TimeInterval>,
        height: CGFloat = 2
    ) {
        _progress = progress
        _duration = duration
        self.height = height
    }

    init(
        progress: CGFloat,
        duration: TimeInterval,
        height: CGFloat = 2
    ) {
        _progress = .constant(progress)
        _duration = .constant(duration)
        self.height = height
    }
}
