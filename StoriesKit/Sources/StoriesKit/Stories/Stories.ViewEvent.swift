import Foundation

extension Stories {
    /// Events that can be sent to the Stories view model
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
        case didTapButtonLink(URL)
    }
}
