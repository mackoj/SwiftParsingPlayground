import SwiftUI
import UniformTypeIdentifiers

extension UTType {
  static var swiftParsingPlayground: UTType {
    UTType(importedAs: "com.swift-parsing.playground")
  }
}

struct SwiftParsingPlaygroundDocument: FileDocument, Identifiable, Codable {
  var id: UUID
  var parser: String
  var input: String
  var lastTmpFolder: URL?

  init() {
    self.id = UUID()
    self.parser = ""
    self.input = ""
    self.lastTmpFolder = nil
  }
  
  // Coding du fichier
  enum CodingKeys: CodingKey {
    case id
    case parser
    case input
    case lastTmpFolder
  }
  
  static var readableContentTypes: [UTType] { [.swiftParsingPlayground] }
  
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents
    else { throw CocoaError(.fileReadCorruptFile) }
    
    let content = try JSONDecoder().decode(SwiftParsingPlaygroundDocument.self, from: data)
    
    self.id = content.id
    self.parser = content.parser
    self.input = content.input
    self.lastTmpFolder = content.lastTmpFolder
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(self)
    return .init(regularFileWithContents: data)
  }
}
