# 📱 StoriesKit

![StoriesKit Demo](./StoriesKit/assets/demo.gif)

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
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

#### SwiftUI

```swift
import StoriesKit
import SwiftUI

struct ContentView: View {
    @StateObject private var stateManager: StoriesStateManager
    @Namespace private var avatarNamespace

    init() {
        let model = StoriesModel(
            groups: [
                StoriesGroupModel(
                    id: "user1",
                    title: "User 1",
                    avatarImage: .remote("https://example.com/avatar.jpg"),
                    pages: [
                        StoriesPageModel(
                            date: "Today",
                            mediaSource: StoriesMediaModel(
                                media: .image(.remote("https://example.com/story.jpg"))
                            ),
                            duration: 5.0
                        )
                    ]
                )
            ],
            backgroundColor: .black,
            user: .init()
        )
        _stateManager = .init(wrappedValue: .init(model: model))
    }

    var body: some View {
        StoriesCarouselView(
            stateManager: stateManager,
            avatarNamespace: avatarNamespace
        )
        .overlay {
            if stateManager.state.isShown {
                Stories.build(
                    stateManager: stateManager,
                    avatarNamespace: avatarNamespace
                )
            }
        }
    }
}
```

#### UIKit

Present stories from a SwiftUI wrapper (required for `Namespace` matched geometry with the carousel):

```swift
import StoriesKit
import SwiftUI

private struct StoriesPresentationView: View {
    @ObservedObject var stateManager: StoriesStateManager
    @Namespace private var avatarNamespace

    var body: some View {
        Stories.build(
            stateManager: stateManager,
            avatarNamespace: avatarNamespace
        )
    }
}

// Present from UIKit
let hostingController = UIHostingController(
    rootView: StoriesPresentationView(stateManager: stateManager)
)
hostingController.modalPresentationStyle = .overFullScreen
present(hostingController, animated: true)
```

## 📖 Detailed Documentation

### StoriesModel - Central Configuration

The new `StoriesModel` provides centralized configuration for all StoriesKit components:

```swift
let storiesModel = StoriesModel(
    groups: [/* StoriesGroupModel array */],
    backgroundColor: .black,
    progress: StoriesModel.Progress(
        lineSize: 3.0,
        interItemSpacing: 4.0,
        containerPadding: .init(top: 4, leading: 0, bottom: 0, trailing: 0),
        viewedColor: .gray.opacity(0.6),
        unviewedColor: .green
    ),
    user: StoriesModel.UserModel(
        avatar: StoriesModel.Avatar(size: 30),
        userName: StoriesModel.Text(font: .system(size: 12, weight: .bold)),
        date: StoriesModel.Text(
            font: .system(size: 10, weight: .semibold),
            color: .white.opacity(0.8)
        )
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
    avatarImage: .remote("https://example.com/avatar.jpg"),
    pages: [/* array of StoriesPageModel */]
)
```

#### StoriesPageModel
Individual story page with support for images, videos, and custom content:

```swift
// Image story
StoriesPageModel(
    date: "Today",
    mediaSource: StoriesMediaModel(
        media: .image(.remote("https://example.com/image.jpg"))
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
        media: .video(.remote("https://example.com/video.mp4"))
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
    media: .image(.remote("https://example.com/image.jpg")) // String?
    // media: .image(.remote(optionalURL))                  // URL?
    // media: .image(.local(UIImage))
)

// Video media
StoriesMediaModel(
    media: .video(.remote("https://example.com/video.mp4"))
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

### Events

Handle user actions via `StoriesStateManager.Event`:

```swift
.onChange(of: stateManager.state.event) { event in
    guard let event else { return }

    switch event {
    case let .didOpenLink(urlString):
        if let url = URL(string: urlString) {
            openURL(url)
        }
    case .didToggleGroup, .didSwitchGroup, .didViewPage:
        break
    }
}
```

Custom story content can emit link events via `@Environment(\.storiesStateManager)`:

```swift
@Environment(\.storiesStateManager) private var stateManager

Button("Learn More") {
    stateManager?.send(.didOpenLink("https://example.com"))
}
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
        media: .image(.remote("https://example.com/background.jpg"))
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
            media: .video(.remote("https://example.com/video.mp4"))
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
            media: .image(.remote("https://example.com/photo.jpg"))
        ),
        duration: 4.0
    ),
    // Video story
    StoriesPageModel(
        title: AttributedString("Video Story"),
        mediaSource: StoriesMediaModel(
            media: .video(.remote("https://example.com/video.mp4"))
        ),
        duration: 8.0
    )
]
```

## 🚀 Integration Examples

### UIKit + SwiftUI Carousel

Use `StoriesStateManager` as the single source of truth. Embed the carousel and present the viewer from SwiftUI (see [Quick Start](#-quick-start)). For UIKit hosts, wrap the SwiftUI presentation view in `UIHostingController` and observe `stateManager.state.event` for links and analytics.

See the included **StoriesExample** app for a full carousel + overlay integration.

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
- **Nuke / NukeUI** — for image loading and caching
- **AVFoundation** — for video playback

### Main Components

- `Stories` — main class for creating stories
- `StoriesModel` — centralized configuration model
- `StoriesStateManager` — centralized state management
- `StoriesVideoManager` — per-session video playback
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
- `StoriesStateManager.Event` — events for links, navigation, and viewed state
- `StoriesVideoManager.State` — video playback states (idle, playing, paused)

### State Management

- **Centralized State** — All state managed through `StoriesStateManager`
- **Video Synchronization** — Video playback synchronized with story timers
- **Memory Efficient** — Single video player instance reused across all videos
- **Reactive Updates** — UI updates automatically when state changes

## 📱 Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+

## 🔧 Dependencies

- [Nuke](https://github.com/kean/Nuke) — for image loading (`NukeUI`)

## 📄 License

StoriesKit is distributed under the MIT license. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions to StoriesKit! Please read our [contributing guidelines](CONTRIBUTING.md).

### Development

```bash
# Install git hooks (SwiftLint on commit)
./Scripts/install-git-hooks.sh

# Run unit tests (iOS Simulator)
./Scripts/run-tests.sh

# Lint
./Scripts/run-swiftlint.sh lint
```

CI runs tests and SwiftLint on every push to `main` via GitHub Actions.

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
