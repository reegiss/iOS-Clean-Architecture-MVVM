// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Presentation",
            targets: ["Presentation"])
    ],
    dependencies: [
        .package(path: "../Common"),
        .package(path: "../Domain"),
        .package(path: "../Networking")
    ],
    targets: [
        .target(
            name: "Presentation",
            dependencies: ["Common", "Domain", "Networking"],
            path: "Sources/Presentation",
            resources: [
                .process("MoviesScene/MovieDetails/View/MovieDetailsViewController.storyboard"),
                .process("MoviesScene/MoviesList/View/MoviesListViewController.storyboard"),
                .process("MoviesScene/MoviesQueriesList/View/UIKit/MoviesQueriesTableViewController.storyboard")
            ]
        )
    ]
)
