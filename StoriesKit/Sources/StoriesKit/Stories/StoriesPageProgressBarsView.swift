import SwiftUI

struct StoriesLiveProgressBarsView: View {
    let progressModel: StoriesProgressModel
    let group: StoriesGroupModel
    let progressBars: [Stories.ViewState.ProgressBar]
    let currentPage: StoriesPageModel?
    let lineSize: CGFloat
    let interItemSpacing: CGFloat
    let containerPadding: EdgeInsets

    var body: some View {
        let currentPageIndex = currentPage.flatMap { page in
            group.pages.firstIndex(where: { $0.id == page.id })
        }

        HStack(spacing: interItemSpacing) {
            ForEach(Array(progressBars.enumerated()), id: \.offset) { index, data in
                if index == currentPageIndex {
                    StoriesLiveActiveProgressBar(
                        progressModel: progressModel,
                        duration: data.duration,
                        height: lineSize
                    )
                } else {
                    ProgressBarView(
                        progress: data.progress,
                        duration: data.duration,
                        height: lineSize
                    )
                }
            }
        }
        .padding(containerPadding)
    }
}

struct StoriesLiveActiveProgressBar: View {
    @ObservedObject var progressModel: StoriesProgressModel
    let duration: TimeInterval
    let height: CGFloat

    var body: some View {
        Group {
            if progressModel.isVideoActive {
                ProgressBarView(
                    progress: Binding(
                        get: { progressModel.videoProgress },
                        set: { progressModel.setVideoProgress($0) }
                    ),
                    duration: .constant(duration),
                    height: height
                )
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: progressModel.isPaused)) { context in
                    ProgressBarView(
                        progress: .constant(progressModel.progress(at: context.date)),
                        duration: .constant(duration),
                        height: height
                    )
                }
                .id(progressModel.timelineSessionID)
            }
        }
    }
}

struct StoriesStaticProgressBarsView: View {
    let progressBars: [Stories.ViewState.ProgressBar]
    let lineSize: CGFloat
    let interItemSpacing: CGFloat
    let containerPadding: EdgeInsets

    var body: some View {
        HStack(spacing: interItemSpacing) {
            ForEach(Array(progressBars.enumerated()), id: \.offset) { _, data in
                ProgressBarView(
                    progress: data.progress,
                    duration: data.duration,
                    height: lineSize
                )
            }
        }
        .padding(containerPadding)
    }
}
