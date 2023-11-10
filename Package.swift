// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SumUpSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "SumUpSDK",
            targets: ["SumUpSDK"])
    ],
    dependencies: [
    ],
    targets: [
        // https://developer.apple.com/documentation/swift_packages/distributing_binary_frameworks_as_swift_packages
        .binaryTarget(
            name: "SumUpSDK",
            path: "SumUpSDK.xcframework")
    ]
)
