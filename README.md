# 📱 StoriesKit

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
    @IBOutlet weak var storiesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStories()
    }
    
    private func setupStories() {
        // Create Stories controller
        let storiesViewController = Stories.build(
            groups: createStoriesGroups(),
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
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "User 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("First Story"),
                        subtitle: AttributedString("Story Description"),
                        backgroundColor: .systemBlue,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
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

### UIKit - Modal Presentation

```swift
import StoriesKit
import UIKit

class ViewController: UIViewController {
    
    @IBAction func showStoriesButtonTapped(_ sender: UIButton) {
        let storiesViewController = Stories.build(
            groups: createStoriesGroups(),
            delegate: self
        )
        
        // Setup modal presentation
        storiesViewController.modalPresentationStyle = .overFullScreen
        storiesViewController.modalTransitionStyle = .crossDissolve
        
        present(storiesViewController, animated: true)
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        // Your story groups
        return []
    }
}

extension ViewController: IStoriesDelegate {
    func didClose() {
        dismiss(animated: true)
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Opened story: \(storyId)")
    }
}
```

### SwiftUI - Embedding in Existing View

```swift
import StoriesKit
import SwiftUI

struct MainView: View {
    @State private var showStories = false
    
    var body: some View {
        VStack {
            Text("Main Screen")
                .font(.title)
            
            Button("Show Stories") {
                showStories = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $showStories) {
            StoriesView(
                groups: createStoriesGroups(),
                onClose: {
                    showStories = false
                }
            )
        }
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "User 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("First Story"),
                        subtitle: AttributedString("Story Description"),
                        backgroundColor: .blue,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

struct StoriesView: View {
    let groups: [StoriesGroupModel]
    let onClose: () -> Void
    
    var body: some View {
        Stories.build(
            groups: groups,
            delegate: StoriesDelegate(onClose: onClose)
        )
    }
}

class StoriesDelegate: IStoriesDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    func didClose() {
        onClose()
    }
    
    func didOpenLink(url: URL) {
        UIApplication.shared.open(url)
    }
    
    func didOpenStory(storyId: String) {
        print("Opened story: \(storyId)")
    }
}
```

### SwiftUI - Embedding in NavigationView

```swift
import StoriesKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome!")
                    .font(.title)
                
                NavigationLink(destination: StoriesScreenView()) {
                    Text("Go to Stories")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Home")
        }
    }
}

struct StoriesScreenView: View {
    var body: some View {
        Stories.build(
            groups: createStoriesGroups(),
            delegate: StoriesScreenDelegate()
        )
        .navigationBarHidden(true)
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "User 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("Story in Navigation"),
                        subtitle: AttributedString("This is a story inside NavigationView"),
                        backgroundColor: .purple,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

class StoriesScreenDelegate: IStoriesDelegate {
    func didClose() {
        // Can use NavigationLink for return
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

### SwiftUI - Embedding in TabView

```swift
import StoriesKit
import SwiftUI

struct TabContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            StoriesTabView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Stories")
                }
        }
    }
}

struct StoriesTabView: View {
    var body: some View {
        NavigationView {
            Stories.build(
                groups: createStoriesGroups(),
                delegate: StoriesTabDelegate()
            )
            .navigationBarHidden(true)
        }
    }
    
    private func createStoriesGroups() -> [StoriesGroupModel] {
        return [
            StoriesGroupModel(
                id: "user1",
                title: "User 1",
                avatarImage: .url(URL(string: "https://example.com/avatar1.jpg")!),
                stories: [
                    StoriesPageModel(
                        title: AttributedString("Stories in Tab"),
                        subtitle: AttributedString("This is Stories inside TabView"),
                        backgroundColor: .green,
                        backgroundImage: StoriesImageModel(
                            image: .url(URL(string: "https://example.com/story1.jpg")!)
                        )
                    )
                ]
            )
        ]
    }
}

class StoriesTabDelegate: IStoriesDelegate {
    func didClose() {
        print("Stories in tab closed")
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