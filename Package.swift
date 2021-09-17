// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirestoreSwift",
    platforms: [.iOS(.v14), .macOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FirestoreSwift",
            targets: ["FirestoreSwift"]),
    ],
    dependencies: [
        .package(name: "DocumentID", url: "git@github.com:1amageek/DocumentID.git", .branch("main")),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.7.0"))
    ],
    targets: [
        .target(
            name: "FirestoreSwift",
            dependencies: [
                "DocumentID",
                .product(name: "FirebaseFirestore", package: "Firebase")
            ]),
        .testTarget(
            name: "FirestoreSwiftTests",
            dependencies: ["FirestoreSwift"]),
    ]
)
