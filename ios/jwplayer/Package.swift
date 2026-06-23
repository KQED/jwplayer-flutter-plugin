// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jwplayer",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "jwplayer", targets: ["jwplayer"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/jwplayer/JWPlayerKit-package.git", from: "4.25.0")
    ],
    targets: [
        .target(
            name: "jwplayer",
            dependencies: [
                .product(name: "JWPlayerKit", package: "JWPlayerKit-package")
            ]
        )
    ]
)
