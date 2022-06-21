import SwiftUI

@main
struct SwiftParsingPlaygroundApp: App {
    var body: some Scene {
      DocumentGroup(newDocument: SwiftParsingPlaygroundDocument()) { file in
          PlaygroundView(document: file.$document)
      }
    }
}
