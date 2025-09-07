import UIKit
import SwiftUI

/// Base hosting controller for SwiftUI views
open class AnyHostingController: UIHostingController<AnyView> {
    public init<V: View>(rootView: V) {
        super.init(rootView: AnyView(rootView))
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
