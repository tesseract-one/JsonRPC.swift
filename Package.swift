// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JsonRPC",
    platforms: [.macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)],
    products: [
        .library(
            name: "JsonRPC",
            targets: ["JsonRPC"]),
    ],
    dependencies: [
        .package(name: "WebSocket", url: "https://github.com/tesseract-one/WebSocket.swift.git", from: "0.1.0"),
        .package(name: "Serializable", url: "https://github.com/tesseract-one/Serializable.swift.git", from: "0.2.3")
    ],
    targets: [
        .target(
            name: "JsonRPC",
            dependencies: ["WebSocket"],
            path: "Sources"),
        .testTarget(
            name: "JsonRPCTests",
            dependencies: ["JsonRPC", "Serializable"]),
    ]
)
