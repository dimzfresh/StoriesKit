import UIKit
import SwiftUI

extension Stories {
    final class ViewController: AnyHostingController {
        init(viewModel: ViewModel) {
            super.init(rootView: ContentView(viewModel: viewModel))
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
