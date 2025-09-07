import Foundation

/// Delegate protocol for handling Stories events
public protocol IStoriesDelegate: AnyObject {
    func didClose()
    func didOpenLink(url: URL)
    func didOpenStory(storyId: String)
}
