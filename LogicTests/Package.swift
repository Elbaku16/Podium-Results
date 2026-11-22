// swift-tools-version:5.9
import PackageDescription
let package = Package(
    name: "LogicTests",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "Logic", path: "Sources/Logic"),
        .testTarget(name: "LogicTests", dependencies: ["Logic"], path: "Tests/LogicTests")
    ]
)
