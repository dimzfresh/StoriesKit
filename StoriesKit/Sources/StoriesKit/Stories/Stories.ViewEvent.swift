import Foundation

extension Stories {
    enum ViewEvent: Hashable {
        case didAppear
        case didTapNext
        case didTapPrevious
        case didSwitchGroup(Int)
        case didSwitchPage(Int)
        case didDismiss
        case didOpenStory(String)
        case didPauseTimer
        case didResumeTimer
        case didTapButtonClose
        case didTapButtonLink(URL)
    }
}
