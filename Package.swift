// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirestoreSwift",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        .library(
            name: "FirestoreSwift",
            targets: ["FirestoreSwift"]),
        .library(
            name: "FunctionsSwift",
            targets: ["FunctionsSwift"]),
        .library(
            name: "AnalyticsSwift",
            targets: ["AnalyticsSwift"]),
    ],
    dependencies: [
        .package(url: "git@github.com:1amageek/DocumentID.git", .branch("main")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "9.1.0"))
    ],
    targets: [
        .target(
            name: "FirestoreSwift",
            dependencies: [
                .product(name: "DocumentID", package: "DocumentID"),
                .product(name: "FirestoreImitation", package: "DocumentID"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
            ],
            exclude: [
                "../../Sources/FirestoreSwift/FirestoreEncoder/LICENSE",
                "../../Sources/FirestoreSwift/FirestoreEncoder/METADATA"
            ]),
        .target(
            name: "FunctionsSwift",
            dependencies: [
                .product(name: "FunctionsImitation", package: "DocumentID"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk")
            ],
            exclude: [
                "../../Sources/FirestoreSwift/FirestoreEncoder/LICENSE",
                "../../Sources/FirestoreSwift/FirestoreEncoder/METADATA"
            ]),
        .target(
            name: "AnalyticsSwift",
            dependencies: [
                .product(name: "AnalyticsImitation", package: "DocumentID"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            exclude: [
                "../../Sources/FirestoreSwift/FirestoreEncoder/LICENSE",
                "../../Sources/FirestoreSwift/FirestoreEncoder/METADATA"
            ]),
        .testTarget(
            name: "FirestoreSwiftTests",
            dependencies: ["FirestoreSwift"]),
    ]
)
