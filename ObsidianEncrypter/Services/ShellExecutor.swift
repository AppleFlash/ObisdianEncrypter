//
//  ShellExecutor.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import Foundation

struct ShellExecutor {
    enum ShError: Error {
        case nonZeroCode
    }

    let execute: (_ command: String, _ dirURL: URL) async throws -> String
}

#if DEBUG
extension ShellExecutor: ClosureMockable {}
#endif

extension ShellExecutor {
    static func baseExecutor() -> Self {
        Self { command, dirURL in
            let task = Task {
                let process = Process()
                process.launchPath = "/bin/zsh"
                process.currentDirectoryURL = dirURL
                process.arguments = ["-c", "set -eu && " + command]

                let pipe = Pipe()
                process.standardOutput = pipe

                try process.run()
                process.waitUntilExit()

                let exitCode = process.terminationStatus
                guard exitCode == 0 else {
                    throw ShError.nonZeroCode
                }

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                guard let output = String(data: data, encoding: .utf8) else {
                    fatalError("ooops")
                }
                return output
            }

            return try await task.value
        }
    }
}
