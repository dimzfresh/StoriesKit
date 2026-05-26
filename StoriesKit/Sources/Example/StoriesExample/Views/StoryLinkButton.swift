import SwiftUI
import StoriesKit

struct StoryLinkButton: View {
    let title: String
    let url: URL

    @Environment(\.storiesStateManager) private var stateManager

    var body: some View {
        Button {
            stateManager?.send(.didOpenLink(url.absoluteString))
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 148, height: 50)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 24)
    }
}
