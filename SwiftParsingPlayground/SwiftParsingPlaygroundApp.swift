import SwiftUI

@main
struct SwiftParsingPlaygroundApp: App {
    var body: some Scene {
      DocumentGroup(newDocument: SwiftParsingPlaygroundDocument()) { file in
          ContentView(document: file.$document)
      }
    }
}
