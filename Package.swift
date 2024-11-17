// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZLSwipeableViewSwiftUI",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZLSwipeableViewSwiftUI",
            targets: ["ZLSwipeableViewSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/zhxnlai/ZLSwipeableViewSwift.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZLSwipeableViewSwiftUI",
            dependencies: ["ZLSwipeableViewSwift"],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        )
    ]
)
