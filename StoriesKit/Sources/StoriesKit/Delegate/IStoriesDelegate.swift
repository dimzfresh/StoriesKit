import Foundation

public protocol IStoriesDelegate: AnyObject {
    func didClose()
    func didOpenLink(url: URL)
    func didOpenStory(storyId: String)
}
