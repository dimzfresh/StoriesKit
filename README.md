# 📱 StoriesKit

![StoriesKit Demo](.StoriesKit/assets/demo_medium.gif)

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**StoriesKit** is a modern Swift library for creating beautiful Instagram-style stories with support for both UIKit and SwiftUI. The library provides ready-to-use components for displaying stories with navigation, timers, and interactive elements.

## ✨ Features

- 🎨 **Beautiful Design** — Modern UI in the style of popular social networks
- ⚡ **High Performance** — Optimized architecture using SwiftUI and Combine
- 🖼️ **Image Support** — URL image loading with caching (Kingfisher)
- ⏱️ **Automatic Timers** — Configurable story duration
- 🎯 **Interactivity** — Support for buttons, links, and gestures
- 📱 **Responsive** — Support for various screen sizes
- 🔄 **Navigation** — Smooth transitions between stories and groups
- 🎛️ **Flexible Customization** — Rich customization options
- 🏗️ **Dual Platform Support** — Works in both UIKit and SwiftUI

## 🚀 Quick Start

### Installation

Add StoriesKit to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/StoriesKit.git", from: "1.0.0")
]
```

### Basic Usage

#### UIKit

```swift
import StoriesKit

// Create stories for UIKit
let storiesViewController = Stories.build(
    groups: [
        StoriesGroupModel(
            id: "user1",
            title: "User 1",
            avatarImage: .url(URL(string: "https://example.com/avatar.jpg")!),
            stories: [
                StoriesPageModel(
                    title: AttributedString("Story Title"),
                    subtitle: AttributedString("Story Subtitle"),
                    backgroundColor: .systemBlue,
                    backgroundImage: StoriesImageModel(
                        image: .url(URL(string: "https://example.com/story.jpg")!)
                    ),
                    duration: 5.0
                )
            ]
        )
    ],
    delegate: self
)

// Present
present(storiesViewController, animated: true)
```

#### SwiftUI

```swift
import StoriesKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        // Create pure SwiftUI View
        Stories.build(
            groups: [
                StoriesGroupModel(
                    id: "user1",
                    title: "User 1",
                    avatarImage: .url(URL(string: "https://example.com/avatar.jpg")!),
                    stories: [
                        StoriesPageModel(
                            title: AttributedString("Story Title"),
                            subtitle: AttributedString("Story Subtitle"),
                            backgroundColor: .blue,
                            backgroundImage: StoriesImageModel(
                                image: .url(URL(string: "https://example.com/story.jpg")!)
                            ),
                            duration: 5.0
                        )
                    ]
                )
            ],
            delegate: self
        )
    }
}
```

## 📖 Detailed Documentation

### Data Models

#### StoriesGroupModel
Represents a group of stories (e.g., stories from one user):

```swift
StoriesGroupModel(
    id: "unique_id",
    title: "Group Title",
    avatarImage: .url(URL(string: "avatar_url")!),
    stories: [/* array of stories */],
    isViewed: false
)
```

#### StoriesPageModel
Individual story page:

```swift
StoriesPageModel(
    title: AttributedString("Title"),
    subtitle: AttributedString("Subtitle"),
    backgroundColor: .systemBlue,
    button: StoriesPageModel.Button(
        title: AttributedString("Button"),
        backgroundColor: .white,
        corners: .radius(8),
        actionType: .link(URL(string: "https://example.com")!)
    ),
    backgroundImage: StoriesImageModel(
        image: .url(URL(string: "image_url")!)
    ),
    duration: 4.0
)
```

#### StoriesImageModel
Model for images with support for various sources:

```swift
StoriesImageModel(
    image: .url(URL(string: "image_url")!), // or .image(UIImage)
    placeholder: UIImage(named: "placeholder"),
    fadeInDuration: 0.25,
    isViewed: false
)
```

### Delegate

Implement the `IStoriesDelegate` protocol to handle events:

```swift
extension YourViewController: IStoriesDelegate {
    func didClose() {
        // Story closed
    }
    
    func didOpenLink(url: URL) {
        // Open link
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        // Open specific story
    }
}
```

### Button Types

```swift
// Next button
.actionType = .next

// Close button
.actionType = .close

// Link button
.actionType = .link(URL(string: "https://example.com")!)
```

### Button Corner Styles

```swift
// No rounding
.corners = .none

// Circular button
.corners = .circle

// Custom rounding
.corners = .radius(12)
```

## 🚀 Integration Examples

### UIKit - Embedding in Existing Controller

```swift
import StoriesKit
import UIKit

class MainViewController: UIViewController {
    private let storiesContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupStories()
    }
    
    private func setupUI() {
        view.addSubview(storiesContainerView)
        storiesContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storiesContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            storiesContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            storiesContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            storiesContainerView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupStories() {
        let stories: [StoriesPageModel] = [
            .init(
                title: pageTitle("Welcome to Stories"),
                subtitle: pageSubtitle("Discover amazing content\nand share your moments\nwith the world!"),
                backgroundColor: .systemBlue,
                button: .init(
                    title: actionButtonTitle("Next"),
                    backgroundColor: .white,
                    corners: .radius(12),
                    actionType: .next
                ),
                backgroundImage: .init(image: .image(UIImage(named: "story1")))
            ),
            .init(
                title: pageTitle("Interactive Features"),
                subtitle: pageSubtitle("Tap to navigate, swipe to change\nstories, and enjoy smooth\ntransitions between content."),
                backgroundColor: .systemPurple,
                button: .init(
                    title: actionButtonTitle("Got it"),
                    backgroundColor: .white,
                    corners: .radius(12),
                    actionType: .close
                ),
                backgroundImage: .init(image: .image(UIImage(named: "story2")))
            )
        ]

        let storiesViewController = Stories.build(
            groups: [
                .init(
                    id: UUID().uuidString,
                    title: "",
                    avatarImage: .image(nil),
                    stories: stories
                )
            ],
            delegate: self
        )
        
        // Add as child controller
        addChild(storiesViewController)
        storiesContainerView.addSubview(storiesViewController.view)
        
        // Setup Auto Layout
        storiesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storiesViewController.view.topAnchor.constraint(equalTo: storiesContainerView.topAnchor),
            storiesViewController.view.leadingAnchor.constraint(equalTo: storiesContainerView.leadingAnchor),
            storiesViewController.view.trailingAnchor.constraint(equalTo: storiesContainerView.trailingAnchor),
            storiesViewController.view.bottomAnchor.constraint(equalTo: storiesContainerView.bottomAnchor)
        ])
        
        storiesViewController.didMove(toParent: self)
    }
    
    // MARK: - Helper Methods
    
    private func pageTitle(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        attributedString.font = .systemFont(ofSize: 24, weight: .bold)
        attributedString.foregroundColor = .white
        return attributedString
    }
    
    private func pageSubtitle(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        attributedString.font = .systemFont(ofSize: 16, weight: .medium)
        attributedString.foregroundColor = .white.opacity(0.9)
        return attributedString
    }
    
    private func actionButtonTitle(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        attributedString.font = .systemFont(ofSize: 16, weight: .semibold)
        attributedString.foregroundColor = .black
        return attributedString
    }
}

// MARK: - IStoriesDelegate
extension MainViewController: IStoriesDelegate {
    func didClose() {
        print("Stories closed")
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Opened story: \(storyId)")
    }
}
```

## 🎨 Customization

### Colors and Styles
- Configure `backgroundColor` for story backgrounds
- Use `AttributedString` for rich text formatting
- Customize button colors and corner rounding

### Timers
- Set `duration` for each story (default 4 seconds)
- Timer automatically pauses on tap and resumes on release

### Images
- URL loading support with automatic caching
- Placeholder images for better UX
- Smooth transitions between images

## 🏗️ Architecture

StoriesKit is built on modern architecture using:

- **SwiftUI** — for UI components
- **Combine** — for reactive programming
- **MVVM** — architectural pattern
- **Kingfisher** — for image loading and caching

### Main Components

- `Stories` — main class for creating stories
- `ContainerView` — SwiftUI container for stories
- `ContentView` — main content with navigation
- `PageView` — individual story page
- `ViewModel` — state management and logic
- `ViewController` — UIKit presentation
- `ProgressBarView` — progress indicator
- `StoriesImageView` — image display

### Events and State

- `ViewEvent` — user events (taps, swipes, timers)
- `ViewState` — current state (groups, progress, indices)
- `IStoriesDelegate` — protocol for event handling

## 📱 Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## 🔧 Dependencies

- [Kingfisher](https://github.com/onevcat/Kingfisher) — for image loading

## 📄 License

StoriesKit is distributed under the MIT license. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions to StoriesKit! Please read our [contributing guidelines](CONTRIBUTING.md).

## 📞 Support

If you have questions or suggestions, create an [issue](https://github.com/yourusername/StoriesKit/issues) or contact us.

---

**Made with ❤️ for iOS developers**
