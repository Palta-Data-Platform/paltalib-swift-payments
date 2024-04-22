// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PaltaPayments",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "PaltaPayments",
            targets: ["PaltaPayments"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.13.1"),
        .package(url: "https://github.com/Palta-Data-Platform/paltalib-swift-core.git", from: "3.2.2"),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.2")
    ],
    targets: [
        .target(
            name: "PaltaPayments",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "PaltaCore", package: "paltalib-swift-core")
            ]
        ),
        .testTarget(
            name: "PaltaPaymentsTests",
            dependencies: [
                "PaltaPayments",
                .product(name: "Difference", package: "Difference")
            ]
        ),
    ]
)
