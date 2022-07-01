import Foundation
import SwiftCLI

public enum Nidi {
    public static let cli: CLI = {
        let cli = CLI(
            name: "nidi",
            version: "0.1.0",
            description: "MaaC (Mac as a Code) configuration tool for MacOS.",
            commands: [
                SetupCommand(),
                UpdateCommand(),
                BundleCommand(),
                ApplyDefaultsCommand(),
                ApplySymlinksCommand(),
                RunScriptsCommand(),
            ]
        )
        cli.globalOptions.append(verboseFlag)
        cli.helpMessageGenerator = NidiHelpMessageGenerator()
        return cli
    }()
}

struct NidiHelpMessageGenerator: HelpMessageGenerator {
    func writeErrorLine(for message: String, to out: WritableStream) {
        out <<< TTY.errorMessage(message)
    }
}

extension Command {
    var verbose: Bool {
        verboseFlag.value
    }
}

private let verboseFlag = Flag(
    "-v",
    "--verbose",
    description: "Enable verbose output for nidi and subcommands."
)
