import SwiftUI

public extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }

    func animate(
        using animation: Animation = .easeInOut(duration: 0.25),
        _ action: @escaping () -> Void
    ) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

private struct OnFirstAppear: ViewModifier {
    let perform: () -> Void
    @State private var isFirstTimeAppeared = true

    func body(content: Content) -> some View {
        content.onAppear {
            guard isFirstTimeAppeared else { return }

            isFirstTimeAppeared = false
            perform()
        }
    }
}

private struct OnFirstDisappear: ViewModifier {
    let perform: () -> Void
    @State private var isFirstTimeDisappeared = true

    func body(content: Content) -> some View {
        content.onDisappear {
            guard isFirstTimeDisappeared else { return }

            isFirstTimeDisappeared = false
            perform()
        }
    }
}

public extension View {
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppear(perform: perform))
    }

    func onFirstDisappear(perform: @escaping () -> Void) -> some View {
        modifier(OnFirstDisappear(perform: perform))
    }
}
