// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BlueBridgeMac",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "BlueBridgeMac", targets: ["BlueBridgeMac"])],
    targets: [.executableTarget(name: "BlueBridgeMac")]
)
