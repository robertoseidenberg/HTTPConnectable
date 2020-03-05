// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "HTTPConnectable",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "HTTPConnectable", targets: ["HTTPConnectable"]),
    ],
    targets: [
        .target(name: "HTTPConnectable"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)