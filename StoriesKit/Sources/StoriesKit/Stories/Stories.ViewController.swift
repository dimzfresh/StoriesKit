import UIKit
import SwiftUI

extension Stories {
    /// UIKit view controller for presenting Stories
    final class ViewController: AnyHostingController {
        init(
            viewModel: ViewModel,
            animatableModel: StoriesAnimatableModel,
            avatarNamespace: Namespace.ID
        ) {
            super.init(rootView: Stories.View(
                viewModel: viewModel,
                animatableModel: animatableModel,
                avatarNamespace: avatarNamespace
            ))
            setupView()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

private extension Stories.ViewController {
    func setupView() {
        view.backgroundColor = .clear

        modalPresentationStyle = .overFullScreen
        isModalInPresentation = true
    }
}
