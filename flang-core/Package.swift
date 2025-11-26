// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlangCore",
    platforms: [.iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "FlangCore", targets: ["FlangModel", "FlangOnline", "FlangOnlineUI", "FlangUI"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "FlangModel"),
        .testTarget(name: "FlangModelTests", dependencies: ["FlangModel"]),
        .target(name: "FlangOnline"),
        .target(name: "FlangOnlineUI", dependencies: ["FlangOnline", "FlangUI"]),
        .target(name: "FlangUI", dependencies: ["FlangModel"], resources: [.process("Resources")]),
    ]
)
