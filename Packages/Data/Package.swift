// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Data",
            targets: ["Data"])
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Domain"),
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: ["Common", "Domain", "Networking"],
            resources: [
                .process("PersistentStorages/CoreDataStorage/CoreDataStorage.xcdatamodeld")
            ])
    ]
)
