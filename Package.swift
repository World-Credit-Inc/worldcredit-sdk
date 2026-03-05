// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "WorldCreditBadge",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "WorldCreditBadge",
            targets: ["WorldCreditBadge"])
    ],
    targets: [
        .target(
            name: "WorldCreditBadge",
            dependencies: [],
            path: "ios/Sources/WorldCreditBadge")
    ]
)
