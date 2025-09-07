import SwiftUI

struct ProgressBarView: View {
    let progress: CGFloat
    let duration: TimeInterval
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white.opacity(0.3))
                    .frame(height: 2)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white)
                    .frame(width: geometry.size.width * progress, height: 2)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: 2)
    }
}
