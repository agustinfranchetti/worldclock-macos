// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WorldClock",
    platforms: [.macOS("26.0")],
    targets: [
        .executableTarget(
            name: "WorldClock",
            path: "Sources/WorldClock"
        ),
    ]
)
