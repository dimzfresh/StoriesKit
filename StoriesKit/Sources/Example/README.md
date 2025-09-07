# StoriesKit Example

A beautiful example app demonstrating StoriesKit with match geometry animations and music-themed content.

## 🎬 Demo

![Demo GIF](./assets/demo.gif)

## ✨ Features

- **Match Geometry Animation**: Smooth avatar transitions from carousel to stories view
- **Music-Themed Content**: Stories featuring top world artists (Taylor Swift, Bad Bunny, Drake, The Weeknd, Harry Styles)
- **Beautiful UI**: Gradient borders, smooth animations, and modern design
- **Image Gallery**: Vertical scrolling gallery with music-themed images
- **Kingfisher Integration**: Optimized image loading and caching
- **SwiftUI**: Built entirely with SwiftUI and modern iOS patterns

## 🏗️ Architecture

- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data management
- **AsyncImage**: Efficient image loading with Kingfisher
- **Match Geometry**: Seamless transitions between views

## 📱 Screenshots

### Main Screen
- Header with gradient background
- Horizontal stories carousel with artist avatars
- Vertical image gallery below

### Stories View
- Full-screen stories experience
- Match geometry animation from avatar to full screen
- Smooth transitions between story pages

## 🚀 Getting Started

1. Open `StoriesExample.xcodeproj` in Xcode
2. Build and run the project
3. Tap on any artist avatar to see the match geometry animation
4. Swipe through stories and enjoy the smooth experience

## 🛠️ Technical Details

### Key Components

- **ContentView**: Main app container with overlay for stories
- **StoriesCarouselView**: Horizontal scrolling avatar carousel
- **StoriesView**: Full-screen stories with match geometry
- **AsyncImageView**: Optimized image loading component
- **StoriesDataModel**: Data management and image preloading

### Match Geometry Implementation

```swift
.matchedGeometryEffect(id: "avatar_\(group.id)", in: avatarNamespace)
```

### Image Optimization

- Preloading with Kingfisher
- Optimized URL parameters for consistent aspect ratios
- Smooth animations and transitions

## 🎨 Design Features

- **Gradient Borders**: Dynamic borders for unviewed stories
- **Smooth Animations**: Spring-based transitions
- **Modern Typography**: Bold, readable text
- **Consistent Spacing**: Well-balanced layout
- **Dark/Light Mode**: Adaptive color schemes

## 📦 Dependencies

- **StoriesKit**: Core stories functionality
- **Kingfisher**: Image loading and caching
- **SwiftUI**: Modern UI framework

## 🔧 Customization

The example is highly customizable:

- **Artists**: Modify `StoriesDataModel` to add/remove artists
- **Images**: Update URLs in the data model
- **Colors**: Adjust gradients and color schemes
- **Animations**: Modify transition durations and styles

## 📄 License

This example project is part of StoriesKit and follows the same license terms.