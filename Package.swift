// swift-tools-version:5.1
import PackageDescription

let package = Package(name: "Usanidi")
package.platforms = [
    .macOS(.v10_13),
]
package.products = [
    .executable(name: "nidi", targets: ["main"]),
]
package.dependencies = [
    .package(url: "https://github.com/mxcl/Path.swift.git", .upToNextMajor(from: "1.2.0")),
    .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "3.2.0")),
    .package(url: "https://github.com/jakeheis/SwiftCLI.git", .upToNextMajor(from: "6.0.2")),
]
package.targets = [
    .target(name: "Nidi", dependencies: ["Path", "Rainbow", "SwiftCLI"]),
    .target(name: "main", dependencies: ["Nidi"]),
    .target(name: "generate-completions", dependencies: ["Nidi"]),
]
