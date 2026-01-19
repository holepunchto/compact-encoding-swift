// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "CompactEncoding",
  platforms: [.macOS(.v11), .iOS(.v14)],
  products: [
    .library(
      name: "CompactEncoding",
      targets: ["CompactEncoding"]
    )
  ],
  targets: [
    .target(
      name: "CompactEncoding",
    ),
    .testTarget(
      name: "CompactEncodingTests",
      dependencies: ["CompactEncoding"],
      path: "Tests"
    ),
  ]
)
