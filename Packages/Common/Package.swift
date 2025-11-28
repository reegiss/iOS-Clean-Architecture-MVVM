// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Common",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Common",
            targets: ["Common"])
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: [])
    ]
)
