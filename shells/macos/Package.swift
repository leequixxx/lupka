// swift-tools-version: 6.0

import Foundation
import PackageDescription

let packageDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .path
let rustTargetDirectory = "\(packageDirectory)/../../target/debug"

let package = Package(
    name: "Lupka",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "LupkaCore", targets: ["LupkaCore"]),
        .executable(name: "lupka", targets: ["Lupka"]),
    ],
    dependencies: [
        // Swift Testing 6.2.4; 6.3+ requires _TestingInterop, absent from Command Line Tools.
        .package(
            url: "https://github.com/swiftlang/swift-testing.git",
            revision: "5ee435b15ad40ec1f644b5eb9d247f263ccd2170"
        ),
    ],
    targets: [
        .systemLibrary(
            name: "LupkaCoreFFI",
            path: "Sources/LupkaCoreFFI"
        ),
        .target(
            name: "LupkaCore",
            dependencies: ["LupkaCoreFFI"],
            path: "Sources/LupkaCore",
            linkerSettings: [
                .linkedLibrary("lupka_core"),
                .unsafeFlags(["-L", rustTargetDirectory]),
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", rustTargetDirectory]),
            ]
        ),
        .executableTarget(
            name: "Lupka",
            dependencies: ["LupkaCore"],
            path: "Sources/Lupka"
        ),
        .testTarget(
            name: "LupkaTests",
            dependencies: [
                "Lupka",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests/LupkaTests"
        ),
        .testTarget(
            name: "LupkaCoreTests",
            dependencies: [
                "LupkaCore",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests/LupkaCoreTests"
        ),
    ]
)
