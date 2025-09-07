import UIKit
import SwiftUI

open class AnyHostingController: UIHostingController<AnyView> {
    public init<V: View>(rootView: V) {
        super.init(rootView: AnyView(rootView))
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
