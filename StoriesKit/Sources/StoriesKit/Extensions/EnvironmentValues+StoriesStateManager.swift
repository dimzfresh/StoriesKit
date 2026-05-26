import SwiftUI

private struct StoriesStateManagerKey: EnvironmentKey {
    static let defaultValue: StoriesStateManager? = nil
}

public extension EnvironmentValues {
    /// Shared stories coordinator for custom story content (e.g. link buttons).
    var storiesStateManager: StoriesStateManager? {
        get { self[StoriesStateManagerKey.self] }
        set { self[StoriesStateManagerKey.self] = newValue }
    }
}
