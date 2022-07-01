import Foundation
import Path
import SwiftCLI

final class SetupCommand: Command {
    let name: String = "setup"
    let shortDescription: String = "Setup a workspace, or directory if none is given"
    @Param var workspace: Workspace?
    @Key("-d", "--directory") var configDirectory: Path?

    @Flag("-a", "--all", description: "Update all casks, including those with auto-update enabled.")
    var updateAll: Bool
    
    @Flag("-r","--rm", description: "Remove bottles that are not in the Brewfile.")
    var removeNotPresent: Bool

    func execute() throws {
        let runner = try NidiRunner(
            configDirectory: self.configDirectory,
            workspace: self.workspace ?? [],
            verbose: self.verbose,
            removeNotPresent: self.removeNotPresent
        )
        try NidiRunner.update(verbose: self.verbose, updateAll: self.updateAll)
        try runner.workspaceDirectories.forEach(runner.setup)
    }
}

extension NidiRunner {
    /// Returns all directories matching the receiver's workspace, i.e. all
    /// parent and sibling shared directories and the named tail directory. For
    /// example, in the following directory structure:
    ///
    ///     - workspaces/
    ///       -> shared/
    ///       -> home/
    ///         => workspaces/
    ///           -> shared/
    ///           -> desktop/
    ///           -> laptop/
    ///           -> work/
    ///
    /// The workspace "home.laptop" will contain the directories
    /// "workspaces/shared", "workspaces/home/shared", and
    /// "workspaces/home/laptop".
    var workspaceDirectories: [Path] {
        guard !workspace.isEmpty else {
            return [configDirectory]
        }

        let possibleWorkspaceDirectories: [Path] = workspace.reduce(into: []) { result, name in
            let previous: Path = result.endIndex > 0 ? result[result.endIndex - 1] : configDirectory
            let containerDirectory = previous.join("workspaces")
            result.append(containerDirectory.join("shared"))
            result.append(containerDirectory.join(name))
        }

        return possibleWorkspaceDirectories.filter(\.isDirectory)
    }
}

private extension NidiRunner {
    /// Run setup commands in the given directory.
    func setup(directory: Path) throws {
        if directory != configDirectory {
            Term.stdout <<< TTY.boldMessage(
                "Setting up \(directory.relative(to: configDirectory))."
            )
        }

        try bundle(directory: directory)
        try runScripts(directory: directory, suffix: .before)
        try applyDefaults(directory: directory)
        try applySymlinks(directory: directory)
        try runScripts(directory: directory, suffix: .after)
    }
}
