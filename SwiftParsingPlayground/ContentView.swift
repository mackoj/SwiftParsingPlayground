import SwiftUI
import Shell

struct ContentView: View {
  @Binding var document: SwiftParsingPlaygroundDocument
  @State private var output: String = ""
  @State private var buildingOutput: String = ""
  
  var baseURL: URL
  var codeSourceURL: URL
  
  init(document: Binding<SwiftParsingPlaygroundDocument>) {
    self._document = document
    let baseURL = URL(fileURLWithPath: /*NSTemporaryDirectory()*/ NSHomeDirectory(), isDirectory: true)
      .appendingPathComponent("SwiftParsingPlayground")
      .appendingPathComponent(document.id.uuidString)
      .appendingPathComponent("parser-playground")
    self.baseURL = baseURL
    self.codeSourceURL = baseURL.appendingPathComponent("Sources")
      .appendingPathComponent("parser-playground")
    do {
      print("baseURL:", baseURL.path)
      try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    } catch {
      buildingOutput = "\(dump(error))"
    }
  }
  
  func createSPM() {
    
  }
  
  var body: some View {
    VStack {
      HStack {
        VStack {
          Text("Parser").font(.title)
          TextEditor(text: $document.parser)
            .foregroundColor(Color(.systemGray))
            .border(Color.red)
            .padding()
            .fixedSize(horizontal: false, vertical: false)
          
        }
        VStack {
          Text("Input").font(.title)
          TextEditor(text: $document.input)
            .foregroundColor(Color(.systemGray))
            .border(Color.red)
            .padding()
            .fixedSize(horizontal: false, vertical: false)
          
        }
      }.frame(height: 300)
      
      HStack {
        Text("Console: \(buildingOutput)").border(Color.red).font(.body)
          .fixedSize(horizontal: false, vertical: false)
        Button {
          buildingOutput = ""
          do {
            if FileManager.default.fileExists(atPath: codeSourceURL.appendingPathComponent("playground.swift").path) {
              try document.input.write(to: baseURL.appendingPathComponent("input.txt"), atomically: true, encoding: .utf8)
              try document.parser.write(to: codeSourceURL.appendingPathComponent("parser.swift"), atomically: true, encoding: .utf8)
              buildingOutput += try shell("cd \(baseURL.path) && swift run parser-playground input.txt output.txt")
              output = try String(contentsOfFile: baseURL.appendingPathComponent("output.txt").path)
            } else {
              buildingOutput += try shell("cd \(baseURL.path) && swift package init --type executable")
              try FileManager.default.removeItem(at: codeSourceURL.appendingPathComponent("main.swift"))
              try packageContent.write(to: baseURL.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
              try document.input.write(to: baseURL.appendingPathComponent("input.txt"), atomically: true, encoding: .utf8)
              try mainScriptContent.write(to: codeSourceURL.appendingPathComponent("playground.swift"), atomically: true, encoding: .utf8)
              try document.parser.write(to: codeSourceURL.appendingPathComponent("parser.swift"), atomically: true, encoding: .utf8)
              buildingOutput += try shell("cd \(baseURL.path) && swift run parser-playground input.txt output.txt")
              output = try String(contentsOfFile: baseURL.appendingPathComponent("output.txt").path)
            }
          } catch {
            fatalError("\(dump(error))")
          }
        } label: {
          Text("Execute")
        }
      }
      VStack {
        Text("Output").font(.title)
        Text(output)
          .foregroundColor(Color(.systemGray))
          .textSelection(.enabled)
          .padding()
          .border(Color.red)
          .fixedSize(horizontal: false, vertical: false)
      }.frame(height: 300)
    }
    .frame(width: 1280, height: 720)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(document: .constant(SwiftParsingPlaygroundDocument()))
  }
}
