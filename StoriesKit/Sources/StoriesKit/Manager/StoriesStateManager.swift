import Foundation
import Combine
import SwiftUI

/// State manager for Stories coordination and state management
public final class StoriesStateManager: ObservableObject {
    @Published public private(set) var state: State = .default

    public init() {}
    
    /// Send event to state manager
    public func send(_ event: Event) {
        switch event {
        case let .didToggleGroup(groupId):
            if let groupId {
                withAnimation(.easeInOut(duration: 0.25)) {
                    state.selectedGroupId = groupId
                    state.isShown = true
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    state.isShown = false
                }
            }

            state.event = event

            if groupId == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.state.selectedGroupId = nil
                }
            }
        case let .didSwitchGroup(groupId):
            state.selectedGroupId = groupId
            state.event = event
        case let .didOpenLink(url):
            state.event = event
        }
    }

    public enum Event: Hashable {
        case didToggleGroup(String?)
        case didSwitchGroup(String)
        case didOpenLink(String)
    }

    public struct State: Hashable {
        public var selectedGroupId: String?
        public var isShown = false
        public var event: Event?

        static let `default` = Self()
    }
}
