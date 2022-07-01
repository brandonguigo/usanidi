//
// Build script to generate shell completions.
//

import Foundation
import Nidi
import Path
import SwiftCLI

guard let outDirectoryParameter = ProcessInfo.processInfo.environment["OUT_DIR"] else {
    Term.stderr <<< "OUT_DIR environment variable not set; aborting."
    exit(1)
}

let outDirectory = Path(outDirectoryParameter) ?? Path.cwd.join(outDirectoryParameter)
let completionsPath = outDirectory.join("_zero")
guard let outStream = WriteStream.for(path: completionsPath.string, appending: false) else {
    Term.stderr <<< "Error: cannot write to file \(completionsPath)."
    exit(1)
}

let generator = ZshCompletionGenerator(cli: Nidi.cli)
generator.writeCompletions(into: outStream)
Term.stdout <<< "Successfully generated zsh completions."
