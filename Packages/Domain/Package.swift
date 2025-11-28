// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"])
    ],
    dependencies: [
        .package(path: "../Common")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: ["Common"])
    ]
)
