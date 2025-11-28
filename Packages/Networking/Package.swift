// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"])
    ],
    dependencies: [
        .package(path: "../Common")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: ["Common"])
    ]
)
