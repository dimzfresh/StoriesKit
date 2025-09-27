import Foundation
import SwiftUI

public final class StoriesAnimatableModel: ObservableObject {
    @Published public var selectedGroupId = ""

    public init() {}
}
