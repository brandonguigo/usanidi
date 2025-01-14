import Foundation
import Path
import SwiftCLI

/// Name of workspace to parse, with children separated by ".".
typealias Workspace = [String]

enum NidiValidationError: LocalizedError {
    /// Found a `./workspaces` directory in configuration path, but `workspace`
    /// parameter was not passed.
    case missingWorkspace

    /// Attempted to setup a workspace container (i.e. a directory containing a
    /// `./workspaces` directory), which is invalid.
    case workspaceIsParent

    /// The given path does not exist or is not a directory.
    case invalidDirectory(Path)

    public var errorDescription: String? {
        switch self {
        case .missingWorkspace:
            return "Missing required parameter 'workspace'."
        case .workspaceIsParent:
            return "Cannot setup parent of a workspace."
        case let .invalidDirectory(directoryPath):
            return "Not a directory: \(directoryPath)."
        }
    }
}

struct NidiRunner {
    let configDirectory: Path
    let workspace: Workspace
    let verbose: Bool
    let removeNotPresent: Bool

    init(
        configDirectory: Path? = nil,
        workspace: Workspace,
        verbose: Bool,
        removeNotPresent: Bool = false
    ) throws {
        let fallbackDirectories: [Path] = [
            Path.XDG.configHome.join("usanidi").join("config"),
            Path.home.join(".usanidi"),
        ]
        self.configDirectory = configDirectory ?? fallbackDirectories.first { $0.isDirectory } ??
            fallbackDirectories.last!
        self.verbose = verbose
        self.workspace = workspace
        self.removeNotPresent = removeNotPresent
        try validate()
    }

    /// Run an executable synchronously and capture its output, printing the
    /// command before running.
    static func captureTask(
        _ executable: String,
        arguments: [String],
        tee: WritableStream? = nil,
        at directory: Path? = nil,
        env: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> CaptureResult {
        self.printCommand(executable, arguments)
        if let directory = directory, executable.hasPrefix(".") {
            return try Task.capture(
                directory.join(executable).string,
                arguments: arguments,
                directory: directory.string,
                tee: tee,
                env: env
            )
        }

        return try Task.capture(
            executable,
            arguments: arguments,
            directory: directory?.string,
            tee: tee,
            env: env
        )
    }

    /// Run a shell statement synchronously, printing the command before
    /// running.
    ///
    /// - Warning: Do not use this with unsanitized user input.
    static func spawnShell(_ command: String) throws {
        self.printCommand(command)
        let exitStatus: Int32 = try Task.spawn("/bin/sh", arguments: ["-c", command])
        guard exitStatus == 0 else {
            throw SpawnError(exitStatus: exitStatus)
        }
    }

    /// Run an executable with the given arguments, printing the command before
    /// running.
    static func runTask(
        _ executable: String,
        arguments: [String],
        at directory: Path? = nil
    ) throws {
        self.printCommand(executable, arguments)

        if let directory = directory, executable.hasPrefix(".") {
            // Process.launchPath doesn't seem to honor currentDirectoryPath
            // for relative executable paths.
            try Task.run(
                directory.join(executable).string,
                arguments: arguments,
                directory: directory.string
            )
        } else {
            try Task.run(executable, arguments: arguments, directory: directory?.string)
        }
    }

    /// Run an executable using `Task.spawn` with the given arguments, printing
    /// the command before running.
    static func spawnTask(
        _ executable: String,
        arguments: [String],
        at directory: Path? = nil
    ) throws {
        self.printCommand(executable, arguments)

        let fileManager = FileManager.default
        let previousWorkingDirectory = fileManager.currentDirectoryPath
        if let dir = directory?.string, !fileManager.changeCurrentDirectoryPath(dir) {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [:])
        }
        defer {
            fileManager.changeCurrentDirectoryPath(previousWorkingDirectory)
        }

        let exitStatus: Int32
        if let directory = directory, executable.hasPrefix(".") {
            exitStatus = try Task.spawn(directory.join(executable).string, arguments: arguments)
        } else if executable.hasPrefix("/") {
            exitStatus = try Task.spawn(executable, arguments: arguments)
        } else {
            exitStatus = try Task.spawn("/usr/bin/env", arguments: [executable] + arguments)
        }
        guard exitStatus == 0 else {
            throw SpawnError(exitStatus: exitStatus)
        }
    }

    static func runTask(
        _ executable: String,
        _ arguments: String...,
        at directory: Path? = nil
    ) throws {
        try self.runTask(executable, arguments: arguments, at: directory)
    }

    static func spawnTask(
        _ executable: String,
        _ arguments: String...,
        at directory: Path? = nil
    ) throws {
        try self.spawnTask(executable, arguments: arguments, at: directory)
    }
}

private extension NidiRunner {
    /// Validates runner before use. Ensures given configDirectory and
    /// workspace are valid and exist on disk.
    func validate() throws {
        if !self.configDirectory.isDirectory {
            throw NidiValidationError.invalidDirectory(self.configDirectory)
        }
        if self.workspace.isEmpty, self.configDirectory.join("workspaces").exists {
            throw NidiValidationError.missingWorkspace
        }

        // Absolute path to each component of the workspace. For example, the
        // workspace "home.laptop" will contain the following paths:
        // "workspaces/home", "workspaces/home/laptop".
        let componentDirectories: [Path] = self.workspace.reduce(into: []) { result, name in
            let previous: Path = result.endIndex > 0 ? result[result.endIndex - 1] : configDirectory
            result.append(previous.join("workspaces").join(name))
        }

        if let missingDirectory = componentDirectories.first(where: { !$0.isDirectory }) {
            throw NidiValidationError.invalidDirectory(missingDirectory)
        }
        // swiftformat:disable braces wrapMultilineStatementBraces
        if let lastDirectory = componentDirectories.last,
           lastDirectory.join("workspaces").isDirectory {
            throw NidiValidationError.workspaceIsParent
        }
    }

    static func printCommand(_ executable: String, _ arguments: [String] = []) {
        let escapedCommand: [String] = [executable] + arguments.map(Task.escapeArgument)
        Term.stdout <<< TTY.commandMessage(escapedCommand.joined(separator: " "))
    }
}

private extension Task {
    /// Returns a shell escaped version of the given string.
    static func escapeArgument(_ argument: String) -> String {
        guard argument.rangeOfCharacter(from: .unsafeShellCharacters) != nil else {
            return argument
        }

        return String(
            format: "'%@'",
            argument.replacingOccurrences(of: "'", with: "'\"'\"", options: .literal, range: nil)
        )
    }
}

private extension CharacterSet {
    static var unsafeShellCharacters: CharacterSet {
        var characters: CharacterSet = .alphanumerics
        characters.insert(charactersIn: ",._+=:@%/-")
        characters.invert()
        return characters
    }
}
