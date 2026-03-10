// swift-tools-version: 5.9

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
      name: "CompactEncoding"
    ),
    .testTarget(
      name: "CompactEncodingTests",
      dependencies: ["CompactEncoding"],
      path: "Tests"
    ),
  ]
)
