import SwiftUI

/// A beautiful segmented circle view for showing progress through story segments
public struct SegmentedView: View {
    private let segments: [Segment]
    private let corners: StoriesCarouselConfiguration.Layout.CornerStyle
    private let lineWidth: CGFloat
    private let size: CGFloat
    private let gap: CGFloat

    public init(
        segments: [Segment],
        corners: StoriesCarouselConfiguration.Layout.CornerStyle,
        lineWidth: CGFloat,
        size: CGFloat,
        gap: CGFloat,
    ) {
        self.segments = segments
        self.corners = corners
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
                    gap: gap,
                    corners: corners
                )
            }
        }
    }

    public struct Segment: Hashable {
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
    }
}

private struct SegmentView: View {
    let index: Int
    let segment: SegmentedView.Segment
    let totalSegments: Int
    let lineWidth: CGFloat
    let size: CGFloat
    let gap: CGFloat
    let corners: StoriesCarouselConfiguration.Layout.CornerStyle

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
        switch corners {
        case .circle:
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

        case let .radius(cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius + lineWidth * 0.5)
                .stroke(
                    segment.color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .square,
                        lineJoin: .round
                    )
                )
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Factory Methods

public extension SegmentedView {
    static func createDefaultSegments(for group: StoriesGroupModel) -> [Segment] {
        if group.pages.allSatisfy(\.isViewed) {
            [.viewed]
        } else {
            (0..<group.pages.count).map { index in
                if index < group.pages.count {
                    let page = group.pages[index]
                    return page.isViewed ? .viewed : .active
                } else {
                    return .upcoming
                }
            }
        }
    }

    static func createCustomSegments(
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
