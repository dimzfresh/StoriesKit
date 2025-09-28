import Foundation

extension Stories {
    /// Events that can be sent to the Stories view model
    enum ViewEvent: Hashable {
        case didAppear
        case didTapNext
        case didTapPrevious
        case didSwitchGroup(String) // Group ID
        case didSwitchPage(String) // Page ID
        case didDismiss
        case didPauseTimer
        case didResumeTimer
        case didTapButtonLink(URL)
    }
}
