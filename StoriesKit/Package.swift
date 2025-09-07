// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "StoriesKit",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "StoriesKit",
      targets: ["StoriesKit"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.11.0"))
  ],
  targets: [
    .target(
      name: "StoriesKit",
      dependencies: ["Kingfisher"]
    )
  ]
)
