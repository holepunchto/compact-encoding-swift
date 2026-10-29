// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "CompactEncoding",
  platforms: [.macOS(.v13), .iOS(.v15)],
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
