# 📱 StoriesKit

![StoriesKit Demo](./StoriesKit/assets/demo.gif)

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**StoriesKit** is a modern Swift library for creating beautiful Instagram-style stories with support for both UIKit and SwiftUI. The library provides ready-to-use components for displaying stories with navigation, timers, and interactive elements.

> ⭐ **Like this project?** Give it a star on GitHub! Your support helps me continue development and add new features.  
> 🚀 **Want to see more?** Follow me for updates and new releases!

[![GitHub stars](https://img.shields.io/github/stars/dimzfresh/StoriesKit?style=social)](https://github.com/dimzfresh/StoriesKit)
[![GitHub forks](https://img.shields.io/github/forks/dimzfresh/StoriesKit?style=social)](https://github.com/dimzfresh/StoriesKit)

## ✨ Features

- 🎨 **Beautiful Design** — Modern UI in the style of popular social networks
- ⚡ **High Performance** — Optimized architecture using SwiftUI and Combine
- 🖼️ **Media Support** — Images and videos with smooth playback
- 🎥 **Video Playback** — Advanced video player with preloading and state management
- ⏱️ **Smart Timers** — Configurable story duration with video synchronization
- 🎯 **Interactivity** — Support for buttons, links, and gestures
- 📱 **Responsive** — Support for various screen sizes
- 🔄 **Navigation** — Smooth transitions between stories and groups
- 🎛️ **Flexible Customization** — Rich customization options
- 🏗️ **Dual Platform Support** — Works in both UIKit and SwiftUI
- 🎪 **Custom Content** — Support for custom SwiftUI views in stories
- 🎨 **Theming** — Centralized configuration with StoriesModel

## 🚀 Quick Start

### Installation

Add StoriesKit to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/dimzfresh/StoriesKit.git", from: "2.0.0")
]
```

### Basic Usage

#### UIKit with StoriesModel

```swift
import StoriesKit

// Create stories configuration
let storiesModel = StoriesModel(
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
                    mediaSource: StoriesMediaModel(
                        media: .image(.url(URL(string: "https://example.com/story.jpg")!))
                    ),
                    duration: 5.0
                )
            ]
        )
    ],
    backgroundColor: .black,
    progress: StoriesModel.Progress(
        lineSize: 3.0,
        gap: 2.0,
        viewedColor: .gray,
        unviewedColor: .green,
        interItemSpacing: 4.0,
        containerPadding: 16.0
    ),
    avatar: StoriesModel.Avatar(
        size: 60.0,
        padding: 8.0,
        progressPadding: 4.0
    ),
    userName: StoriesModel.Text(
        font: .systemFont(ofSize: 16, weight: .medium),
        color: .white,
        lineLimit: 1,
        padding: 8.0,
        spacingFromAvatar: 8.0,
        multilineTextAlignment: .center
    )
)

// Create stories for UIKit
let storiesViewController = Stories.build(
    model: storiesModel,
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
        // Create pure SwiftUI View with StoriesModel
        Stories.build(
            model: StoriesModel(
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
                                mediaSource: StoriesMediaModel(
                                    media: .image(.url(URL(string: "https://example.com/story.jpg")!))
                                ),
                                duration: 5.0
                            )
                        ]
                    )
                ],
                backgroundColor: .black
            )
        )
    }
}
```

## 📖 Detailed Documentation

### StoriesModel - Central Configuration

The new `StoriesModel` provides centralized configuration for all StoriesKit components:

```swift
let storiesModel = StoriesModel(
    groups: [/* StoriesGroupModel array */],
    backgroundColor: .black,
    progress: StoriesModel.Progress(
        lineSize: 3.0,           // Progress bar thickness
        gap: 2.0,                // Gap between segments
        viewedColor: .gray,       // Color for viewed segments
        unviewedColor: .green,    // Color for unviewed segments
        interItemSpacing: 4.0,    // Spacing between progress bars
        containerPadding: 16.0    // Container padding
    ),
    avatar: StoriesModel.Avatar(
        size: 60.0,              // Avatar size
        padding: 8.0,             // Internal padding
        progressPadding: 4.0      // Padding around progress circle
    ),
    userName: StoriesModel.Text(
        font: .systemFont(ofSize: 16, weight: .medium),
        color: .white,
        lineLimit: 1,
        padding: 8.0,
        spacingFromAvatar: 8.0,
        multilineTextAlignment: .center
    )
)
```

### Data Models

#### StoriesGroupModel
Represents a group of stories (e.g., stories from one user):

```swift
StoriesGroupModel(
    id: "unique_id",
    title: "Group Title",
    avatarImage: .url(URL(string: "avatar_url")!),
    stories: [/* array of stories */]
)
```

#### StoriesPageModel
Individual story page with support for images, videos, and custom content:

```swift
// Image story
StoriesPageModel(
    date: "Today",
    mediaSource: StoriesMediaModel(
        media: .image(.url(URL(string: "image_url")!))
    ),
    duration: 4.0,
    padding: EdgeInsets(top: 54, leading: 0, bottom: 44, trailing: 0),
    cornerRadius: 12,
    content: AnyView(
        VStack(spacing: 0) {
            Text("Story Title")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 32)
                .padding(.horizontal, 16)
            
            Text("Story Subtitle")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
                .padding(.horizontal, 16)
            
            // Custom buttons in content
            VStack(spacing: 12) {
                Button("Next") {
                    // Handle next action
                }
                .frame(width: 148, height: 50)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button("Learn More") {
                    // Handle link action
                }
                .frame(width: 148, height: 50)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 24)
        }
    )
)

// Video story
StoriesPageModel(
    date: "Yesterday",
    mediaSource: StoriesMediaModel(
        media: .video(.url(URL(string: "video_url")!))
    ),
    duration: 8.0,
    padding: EdgeInsets(top: 54, leading: 0, bottom: 44, trailing: 0),
    cornerRadius: 12
)
```

#### StoriesMediaModel
Model for media (images and videos) with support for various sources:

```swift
// Image media
StoriesMediaModel(
    media: .image(.url(URL(string: "image_url")!)) // or .image(UIImage)
)

// Video media
StoriesMediaModel(
    media: .video(.url(URL(string: "video_url")!)) // or .video(AVAsset)
)

// Local video
StoriesMediaModel(
    media: .video(.local(AVAsset(url: localVideoURL)))
)
```

#### Video Player Features

StoriesKit includes an advanced video player with:

- **Preloading** - Videos are preloaded to avoid black screen flickering
- **State Management** - Centralized video player state management
- **Timer Synchronization** - Video playback is synchronized with story timers
- **Smooth Transitions** - Seamless switching between videos
- **Memory Efficient** - Single player instance reused across all videos

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

### StoriesCarouselView Configuration

The carousel supports both circular and rounded rectangle corner styles:

```swift
let configuration = StoriesCarouselConfiguration(
    layout: StoriesCarouselConfiguration.Layout(
        itemSpacing: 16,
        horizontalPadding: 16,
        corners: .radius(12)  // Rounded rectangle with 12pt radius
    ),
    avatar: StoriesCarouselConfiguration.Avatar(
        size: 70,
        progressPadding: 6
    ),
    progress: StoriesCarouselConfiguration.Progress(
        lineWidth: 3,
        gap: 3,
        viewedColor: .gray.opacity(0.6),
        unviewedColor: .green.opacity(0.8)
    )
)

StoriesCarouselView(
    stateManager: stateManager,
    avatarNamespace: avatarNamespace,
    configuration: configuration
)
```

#### Corner Styles

```swift
// Circular carousel items (default)
corners: .circle

// Rounded rectangle with custom radius
corners: .radius(12)  // 12pt corner radius
corners: .radius(8)   // 8pt corner radius
```

The corner style applies to both the avatar images and their progress indicator rings, ensuring visual consistency across all carousel items.

### Custom Content with Buttons

Buttons are now integrated directly into custom content views:

```swift
StoriesPageModel(
    date: "Today",
    mediaSource: StoriesMediaModel(
        media: .image(.url(URL(string: "background_url")!))
    ),
    content: AnyView(
        VStack(spacing: 0) {
            Text("Welcome to Stories")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 32)
                .padding(.horizontal, 16)
            
            Text("Discover amazing content")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 8)
                .padding(.horizontal, 16)
            
            // Custom buttons with actions
            VStack(spacing: 12) {
                Button("Get Started") {
                    // Handle button action
                }
                .frame(width: 148, height: 50)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button("Learn More") {
                    // Handle link action
                }
                .frame(width: 148, height: 50)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 24)
        }
    ),
    duration: 6.0
)
```

## 🎥 Video Support Examples

### Video Stories with Custom Content

```swift
let videoStories = [
    StoriesPageModel(
        title: AttributedString("Amazing Video"),
        subtitle: AttributedString("Check out this cool content"),
        backgroundColor: .black,
        mediaSource: StoriesMediaModel(
            media: .video(.url(URL(string: "https://example.com/video.mp4")!))
        ),
        content: AnyView(
            VStack {
                Text("🎬 Video Story")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Tap to interact")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        ),
        duration: 10.0
    )
]
```

### Mixed Media Stories

```swift
let mixedStories = [
    // Image story
    StoriesPageModel(
        title: AttributedString("Photo Story"),
        mediaSource: StoriesMediaModel(
            media: .image(.url(URL(string: "https://example.com/photo.jpg")!))
        ),
        duration: 4.0
    ),
    // Video story
    StoriesPageModel(
        title: AttributedString("Video Story"),
        mediaSource: StoriesMediaModel(
            media: .video(.url(URL(string: "https://example.com/video.mp4")!))
        ),
        duration: 8.0
    )
]
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
- **AVFoundation** — for video playback

### Main Components

- `Stories` — main class for creating stories
- `StoriesModel` — centralized configuration model
- `StoriesStateManager` — centralized state management
- `VideoPlayerStateManager` — video player state management
- `ContainerView` — SwiftUI container for stories
- `ContentView` — main content with navigation
- `PageView` — individual story page
- `ViewModel` — state management and logic
- `ViewController` — UIKit presentation
- `ProgressBarView` — progress indicator
- `StoriesMediaView` — universal media display (images/videos)
- `VideoPlayerView` — advanced video player component

### Events and State

- `ViewEvent` — user events (taps, swipes, timers)
- `ViewState` — current state (groups, progress, indices)
- `IStoriesDelegate` — protocol for event handling
- `VideoPlayerState` — video player states (idle, playing, paused)

### State Management

- **Centralized State** — All state managed through `StoriesStateManager`
- **Video Synchronization** — Video playback synchronized with story timers
- **Memory Efficient** — Single video player instance reused across all videos
- **Reactive Updates** — UI updates automatically when state changes

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

## 🆕 What's New

### Version 2.0 Features

- **🎥 Video Support** — Full video playback with preloading and state management
- **🎨 StoriesModel** — Centralized configuration for all components
- **🎪 Custom Content** — Support for custom SwiftUI views in stories with embedded buttons
- **⚡ Performance** — Optimized video player with single instance reuse
- **🔄 State Management** — Centralized state management with StoriesStateManager
- **🎯 Timer Sync** — Video playback synchronized with story timers
- **🎨 Theming** — Rich customization options for all UI components
- **📱 Carousel Corners** — Support for both circular and rounded rectangle carousel items
- **🎛️ Custom Buttons** — Buttons now integrated into custom content views
- **📐 Flexible Layout** — Custom padding and corner radius for story pages

### Migration Guide

If you're upgrading from version 1.x:

1. **Replace `StoriesImageModel`** with `StoriesMediaModel`
2. **Use `StoriesModel`** for configuration instead of individual parameters
3. **Update to new `StoriesPageModel`** structure with `mediaSource`
4. **Add video support** using `.video()` media type
5. **Buttons in custom content** — Move buttons from `StoriesPageModel.button` to custom `content` views
6. **Carousel configuration** — Use `StoriesCarouselConfiguration` for carousel customization
7. **Corner styles** — Use `Layout.CornerStyle` for carousel item shapes

## 📞 Support

If you have questions or suggestions, create an [issue](https://github.com/dimzfresh/StoriesKit/issues) or contact us.

---

**Made with ❤️ for iOS developers**
