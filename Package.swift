// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIRouting",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "UIRouting",
            targets: ["UIRouting"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "UIRouting",
            dependencies: []
        ),
        .testTarget(
            name: "UIRoutingTests",
            dependencies: ["UIRouting"]
        ),
        // Stands in for a downstream consumer: a plain `import UIRouting` with the
        // Swift 6 language mode pinned, so an isolated default implementation that
        // cannot satisfy a nonisolated requirement fails the build here first.
        .testTarget(
            name: "ConsumerConformanceTests",
            dependencies: ["UIRouting"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
