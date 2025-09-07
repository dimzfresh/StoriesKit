# StoriesKit

![StoriesKit Demo](./assets/demo_small.gif)

A beautiful SwiftUI library for creating Instagram-style stories with smooth animations and match geometry effects.

## Features

- 🎨 Beautiful stories carousel with rounded avatars and borders
- ✨ Match geometry animation from avatar to full-screen stories
- 🖼️ Featured images section with vertical layout
- 🎵 Top world artists with real images from Unsplash
- 🔄 Smooth animations and transitions
- 📱 Modern SwiftUI design patterns

## Example App

The example app showcases all StoriesKit features:

- **Stories Carousel**: Horizontal scrollable carousel with artist avatars
- **Match Geometry**: Smooth transition from circular avatar to full-screen stories
- **Featured Images**: Vertical gallery of random images
- **Real Data**: 5 top world artists with authentic images

## Installation

Add StoriesKit to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/StoriesKit.git", from: "1.0.0")
]
```

## Usage

```swift
import StoriesKit

// Create your stories data
let storiesGroups = [
    StoriesGroupModel(
        id: "1",
        title: "Artist Name",
        avatarImage: .url(URL(string: "avatar-url")!),
        stories: [/* your stories */]
    )
]

// Display stories
Stories.build(
    groups: storiesGroups,
    delegate: yourDelegate
)
```

## Requirements

- iOS 14.0+
- Swift 5.0+
- Xcode 12.0+

## License

MIT License - see LICENSE file for details.
