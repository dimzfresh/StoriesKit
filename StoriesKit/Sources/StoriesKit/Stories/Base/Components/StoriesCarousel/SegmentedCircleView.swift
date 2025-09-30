import SwiftUI

/// A beautiful segmented circle view for showing progress through story segments
public struct SegmentedCircleView: View {
    private let segments: [Segment]
    private let lineWidth: CGFloat
    private let size: CGFloat
    private let gap: CGFloat

    public init(
        segments: [Segment],
        lineWidth: CGFloat = 3,
        size: CGFloat,
        gap: CGFloat = 2
    ) {
        self.segments = segments
        self.lineWidth = lineWidth
        self.size = size
        self.gap = gap
    }

    public var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                SegmentView(
                    index: index,
                    segment: segment,
                    totalSegments: segments.count,
                    lineWidth: lineWidth,
                    size: size,
                    gap: gap
                )
            }
        }
    }
}

public extension SegmentedCircleView {
    struct Segment: Hashable {
        public let color: Color
        public let isActive: Bool

        public init(
            color: Color,
            isActive: Bool = true
        ) {
            self.color = color
            self.isActive = isActive
        }

        public static var active: Self { .init(color: .green, isActive: true) }
        public static var viewed: Self { .init(color: .black.opacity(0.35), isActive: false) }
        public static var upcoming: Self { .init(color: .green, isActive: true) }
        public static var error: Self { .init(color: .red, isActive: false) }
    }
}

private struct SegmentView: View {
    let index: Int
    let segment: SegmentedCircleView.Segment
    let totalSegments: Int
    let lineWidth: CGFloat
    let size: CGFloat
    let gap: CGFloat

    private var segmentAngle: Double {
        1.0 / Double(totalSegments)
    }
    private var gapAngle: Double {
        gap / (size * .pi)
    }
    private var rotationAngle: Double {
        Double(index) * 360.0 / Double(totalSegments) - 90
    }

    private var effectiveGap: Double {
        totalSegments > 1 ? gapAngle : 0
    }

    var body: some View {
        Circle()
            .trim(from: effectiveGap, to: segmentAngle - effectiveGap)
            .rotation(.degrees(rotationAngle))
            .stroke(
                segment.color,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .square,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
            .shadow(
                color: segment.isActive ? segment.color.opacity(0.3) : .clear,
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

// MARK: - Factory Methods
public extension SegmentedCircleView {
    /// Creates segments for a story group with beautiful visual states
    static func createSegments(for group: StoriesGroupModel) -> [Segment] {
        guard !group.pages.allSatisfy(\.isViewed) else { return [.viewed] }

        return (0..<group.pages.count).map { index in
            if index < group.pages.count {
                let page = group.pages[index]
                return page.isViewed ? .viewed : .active
            } else {
                return .upcoming
            }
        }
    }

    /// Creates progress-based segments
    static func createProgressSegments(
        progress: Double,
        totalSegments: Int,
        activeColor: Color = .green,
        inactiveColor: Color = .gray.opacity(0.3)
    ) -> [Segment] {
        let activeSegments = Int(progress * Double(totalSegments))

        return (0..<totalSegments).map { index in
            if index < activeSegments {
                .init(
                    color: activeColor,
                    isActive: true
                )
            } else {
                .init(
                    color: inactiveColor,
                    isActive: false
                )
            }
        }
    }
}

extension SegmentedCircleView.Segment {
    public static func custom(_ color: Color, isActive: Bool = true) -> Self {
        Self(
            color: color,
            isActive: isActive
        )
    }
}
