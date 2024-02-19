//
//  ShellExecutor.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import Foundation

enum ShellExecutor {
    enum ShError: Error {
        case nonZeroCode
    }

    @discardableResult
    static func execute(_ command: String, dirURL: URL) throws -> String {
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
}
