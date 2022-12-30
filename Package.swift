// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JsonRPC",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "JsonRPC",
            targets: ["JsonRPC"]),
        .library(
            name: "JsonRPCSerializable",
            targets: ["JsonRPCSerializable"]),
    ],
    dependencies: [
        .package(name: "Serializable", url: "https://github.com/tesseract-one/Serializable.swift.git", from: "0.2.3")
    ],
    targets: [
        .target(
            name: "JsonRPC",
            dependencies: [],
            path: "Sources/RPC"),
        .target(
            name: "JsonRPCSerializable",
            dependencies: ["JsonRPC", "Serializable"],
            path: "Sources/Serializable"),
        .testTarget(
            name: "JsonRPCTests",
            dependencies: ["JsonRPCSerializable"]),
    ]
)
