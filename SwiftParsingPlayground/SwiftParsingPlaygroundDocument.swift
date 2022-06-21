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
  
  init() {
    self.id = UUID()
    self.parser = ""
    self.input = ""
  }
  
  enum CodingKeys: CodingKey {
    case id
    case parser
    case input
  }
  
  static var readableContentTypes: [UTType] { [.swiftParsingPlayground] }
  
  init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents
    else { throw CocoaError(.fileReadCorruptFile) }
    
    let content = try JSONDecoder().decode(SwiftParsingPlaygroundDocument.self, from: data)
    
    self.id = content.id
    self.parser = content.parser
    self.input = content.input
  }
  
  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(self)
    return .init(regularFileWithContents: data)
  }
}
