import SwiftUI
import Kingfisher

struct AsyncImageView: View {
    let url: URL?
    let placeholder: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var isLoading = true
    @State private var hasError = false
    
    init(
        url: URL?,
        placeholder: String = "person.fill",
        width: CGFloat = 100,
        height: CGFloat = 100,
        cornerRadius: CGFloat = 50
    ) {
        self.url = url
        self.placeholder = placeholder
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        KFImage(url)
            .placeholder {
                placeholderView
            }
            .onSuccess { _ in
                isLoading = false
                hasError = false
            }
            .onFailure { _ in
                isLoading = false
                hasError = true
            }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .animation(.easeInOut(duration: 0.2), value: url)
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .overlay(
                VStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.blue)
                    } else if hasError {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.title2)
                    } else {
                        Image(systemName: placeholder)
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
            )
    }
}
