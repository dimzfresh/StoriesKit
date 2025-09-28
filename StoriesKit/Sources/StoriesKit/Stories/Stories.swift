import SwiftUI
import UIKit
import Combine

public enum Stories {
    /// Creates UIKit version of Stories
    /// - Parameters:
    ///   - groups: Array of story groups
    ///   - stateManager: StoriesStateManager for state management
    ///   - avatarNamespace: Namespace for matched geometry effect
    /// - Returns: UIViewController for presentation
    public static func build(
        groups: [StoriesGroupModel],
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID
    ) -> UIViewController {
        ViewController(
            viewModel: ViewModel(
                groups: groups,
                stateManager: stateManager
            ),
            avatarNamespace: avatarNamespace
        )
    }
    
    /// Creates pure SwiftUI version of Stories (without UIHostingController)
    /// - Parameters:
    ///   - groups: Array of story groups
    ///   - stateManager: StoriesStateManager for state management
    ///   - avatarNamespace: Namespace for matched geometry effect
    /// - Returns: Pure SwiftUI View for embedding in SwiftUI hierarchy
    public static func build(
        groups: [StoriesGroupModel],
        stateManager: StoriesStateManager,
        avatarNamespace: Namespace.ID
    ) -> some SwiftUI.View {
        Stories.View(
            viewModel: ViewModel(
                groups: groups,
                stateManager: stateManager
            ),
            avatarNamespace: avatarNamespace
        )
    }
}
