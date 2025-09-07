import SwiftUI

extension Stories {
    public struct ContainerView: View {
        @StateObject private var viewModel: ViewModel
        
        public init(
            groups: [StoriesGroupModel],
            delegate: IStoriesDelegate? = nil
        ) {
            _viewModel = .init(wrappedValue: .init(
                groups: groups,
                delegate: delegate
            ))
        }
        
        public var body: some View {
            ContentView(viewModel: viewModel)
                .ignoresSafeArea()
        }
    }
}
