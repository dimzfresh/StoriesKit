// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "StoriesKit",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "StoriesKit",
      type: .dynamic,
      targets: ["StoriesKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/kean/Nuke.git", from: "12.0.0")
  ],
  targets: [
    .target(
      name: "StoriesKit",
      dependencies: [
        .product(name: "Nuke", package: "Nuke"),
        .product(name: "NukeUI", package: "Nuke")
      ]
    ),
    .testTarget(
      name: "StoriesKitTests",
      dependencies: ["StoriesKit"]
    )
  ]
)
