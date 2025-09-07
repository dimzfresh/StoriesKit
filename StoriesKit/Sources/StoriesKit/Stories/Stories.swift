import SwiftUI
import UIKit
import Combine

public enum Stories {
    /// Создает UIKit версию Stories
    /// - Parameters:
    ///   - groups: Массив групп историй
    ///   - delegate: Делегат для обработки событий
    /// - Returns: UIViewController для презентации
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
    
    /// Создает чистую SwiftUI версию Stories (без UIHostingController)
    /// - Parameters:
    ///   - groups: Массив групп историй
    ///   - delegate: Делегат для обработки событий
    /// - Returns: Чистая SwiftUI View для встраивания в SwiftUI иерархию
    public static func buildSwiftUI(
        groups: [StoriesGroupModel],
        delegate: IStoriesDelegate? = nil
    ) -> some View {
        ContainerView(
            groups: groups,
            delegate: delegate
        )
    }
}
