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
        animatableModel: StoriesAnimatableModel,
        avatarNamespace: Namespace.ID,
        delegate: IStoriesDelegate? = nil,
        selectedGroup: StoriesGroupModel? = nil
    ) -> UIViewController {
        let viewModel = ViewModel(
            groups: groups,
            delegate: delegate,
            selectedGroup: selectedGroup
        )

        let viewController = ViewController(
            viewModel: viewModel,
            animatableModel: animatableModel,
            avatarNamespace: avatarNamespace
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
        animatableModel: StoriesAnimatableModel,
        avatarNamespace: Namespace.ID,
        delegate: IStoriesDelegate? = nil,
        selectedGroup: StoriesGroupModel? = nil
    ) -> some SwiftUI.View {
        let viewModel = ViewModel(
            groups: groups,
            delegate: delegate,
            selectedGroup: selectedGroup
        )

        return Stories.View(
            viewModel: viewModel,
            animatableModel: animatableModel,
            avatarNamespace: avatarNamespace
        )
    }
}
