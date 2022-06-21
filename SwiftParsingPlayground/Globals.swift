let packageContent = """
// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "parser-playground",
    platforms: [ .macOS(.v12) ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/mackoj/swift-parsing.git", branch: "feat/prefixuntil"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "parser-playground",
            dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser"),
              .product(name: "Parsing", package: "swift-parsing"),
          ]),
        .testTarget(
            name: "parser-playgroundTests",
            dependencies: ["parser-playground"]),
    ]
)
"""

let mainScriptContent = """
import ArgumentParser
import Foundation
import Parsing

@main
struct ParserPlayground: AsyncParsableCommand {
  
  @Argument var inputFileURL: URL
  @Argument var outputFileURL: URL

  @Flag var verbose: Bool = false
  
  mutating func run() async throws {

    // Clean output
    if FileManager.default.fileExists(atPath: outputFileURL.path) {
      try FileManager.default.removeItem(at: outputFileURL)
    }
        
    FileManager.default.createFile(atPath: outputFileURL.path, contents: nil)
    let handle = try FileHandle(forWritingTo: outputFileURL)
    defer { handle.closeFile() }
    let newLineData = String(" ").data(using: .utf8)!

    for try await line in inputFileURL.resourceBytes.lines {
      let parsedOutput = try mainParser.parse(line[...]).compactMap { $0 }
      let data = try JSONEncoder().encode(parsedOutput)
      handle.write(data)
      handle.write(newLineData)
    }
  }
}

extension URL: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(fileURLWithPath: argument)
  }
}
"""
