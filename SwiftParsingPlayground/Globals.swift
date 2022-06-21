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

let mockInput = """
Nodename:  LAS1-vFW01-gen2-mmg4-10-92-100-101
[32;1m  version: 1.49.0 [0m
[32;1m  version: 1.49.0 [34;1mfoo:[0m bar
[36mINFO[0m[08:45:33] [33;1mci runs in Secret Filtering mode[0m
[33;1maaa[33;1mbbb[33;1mccc[33;1mddd
asdasdasd[33;1maaa[33;1mbbb[33;1mccc[33;1mddd
[08:45:33]asdasdasd[33;1maaa[0m bar
"""

let mockParser = """
import Foundation
import Parsing

public let mainParser = Many(1...) {
  textWithAttributes
}

// MARK: Parser Internal
let textWithAttributes = Parse(ParsedConsoleText.init(color:string:)) {
  Peek { Prefix<Substring>(1) }
  Optionally { terminalFontModifier }
  Optionally { PrefixUntil("[") { terminalFontModifier }.map(String.init) }
}

let terminalFontModifier = Parse(TerminalAttribute.init) {
  "["
  Int.parser()
  Optionally {
    ";"
    Int.parser()
  }
  "m"
}

public enum TerminalAttributeCode: Int, RawRepresentable, Codable {
  case bold                     = 1
  case dim                      = 2
  case italic                   = 3
  case underline                = 4
  case blink                    = 5
  case reverse                  = 7
  case hidden                   = 8
  case strikethrough            = 9
  
  // Resets
  case resetAll                 = 0
  case resetBold                = 21
  case resetDim                 = 22
  case resetUnderlined          = 24
  case resetBlink               = 25
  case resetReverse             = 27
  case resetHidden              = 28

  // 8/16 Colors
  case defaultForegroundColor   = 39
  case black                    = 30
  case red                      = 31
  case green                    = 32
  case yellow                   = 33
  case blue                     = 34
  case magenta                  = 35
  case cyan                     = 36
  case white                    = 97
  case lightGray                = 37
  case darkGray                 = 90
  case lightRed                 = 91
  case lightGreen               = 92
  case lightYellow              = 93
  case lightBlue                = 94
  case lightMagenta             = 95
  case lightCyan                = 96
  
  // BackgroundColor
  case bgDefaultBackgroundColor = 49
  case bgBlack                  = 40
  case bgRed                    = 41
  case bgGreen                  = 42
  case bgYellow                 = 43
  case bgBlue                   = 44
  case bgMagenta                = 45
  case bgCyan                   = 46
  case bgLightGray              = 47
  case bgDarkGray               = 100
  case bgLightRed               = 101
  case bgLightGreen             = 102
  case bgLightYellow            = 103
  case bgLightBlue              = 104
  case bgLightMagenta           = 105
  case bgLightCyan              = 106
  case bgWhite                  = 107
}

public struct TerminalAttribute: Codable {
  public let color: TerminalAttributeCode
  public let modifier: TerminalAttributeCode?
    
  public init(_ color: Int, _ modifier: Int?) {
    self.color = TerminalAttributeCode(rawValue: color)  ?? .resetAll
    if let validModifier = modifier, let modifier = TerminalAttributeCode(rawValue: validModifier) {
      self.modifier = modifier
    } else {
      self.modifier = nil
    }
  }
}

public struct ParsedConsoleText: Codable {
  var text: String
  var attribute: TerminalAttribute?
      
  public init?(color: TerminalAttribute? = nil, string: String?) {
    if color == nil && string == nil { return nil }
    self.text = string ?? ""
    self.attribute = color
  }
}
"""
