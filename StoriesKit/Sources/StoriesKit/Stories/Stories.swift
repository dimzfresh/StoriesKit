import SwiftUI
import UIKit
import Combine

public enum Stories {
    /// Creates UIKit version of Stories
    /// - Parameters:
    ///   - groups: Array of story groups
    ///   - delegate: Delegate for event handling
    /// - Returns: UIViewController for presentation
    public static func build(
        groups: [StoriesGroupModel],
        delegate: IStoriesDelegate? = nil
    ) -> UIViewController {
        let viewModel = ViewModel(
            groups: groups,
            delegate: delegate
        )
        let viewController = ViewController(
            viewModel: viewModel
        )
        return viewController
    }
    
    /// Creates pure SwiftUI version of Stories (without UIHostingController)
    /// - Parameters:
    ///   - groups: Array of story groups
    ///   - delegate: Delegate for event handling
    /// - Returns: Pure SwiftUI View for embedding in SwiftUI hierarchy
    public static func build(
        groups: [StoriesGroupModel],
        delegate: IStoriesDelegate? = nil
    ) -> some View {
        ContainerView(
            groups: groups,
            delegate: delegate
        )
    }
}
