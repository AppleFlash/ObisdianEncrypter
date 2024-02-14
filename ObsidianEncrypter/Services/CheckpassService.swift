//
//  CheckpassService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 15.02.2024.
//

import Foundation

enum CheckpassService {
    enum CheckStatus {
        case fileNotExist
        case matched
        case notMatch
    }

    enum Constants {
        static let checkpassSuffix = ".pass"
        static let checkpassContent = "checkpass file content"
    }

    static func checkPass(
        _ pass: String,
        gitRepoPath: String,
        fileManager: FileManager = .default
    ) -> CheckStatus {
        let contents = (try? fileManager.contentsOfDirectory(atPath: gitRepoPath)) ?? []
        let existingCheckpass = contents.first { $0.hasSuffix(CheckpassFileConstants.checkpassSuffix) }
        guard let existingCheckpass else {
            return .fileNotExist
        }

        let path = URL(filePath: gitRepoPath)
        let outputFile = "checkpass.output"
        catchError {
            try EncryptService.dencrypt(
                existingCheckpass,
                output: outputFile,
                password: pass,
                baseDir: path
            )
        }

        let content = catchError { try String(contentsOf: path.appendingPathComponent(outputFile), encoding: .utf8) }
        catchError { try fileManager.removeItem(at: path.appendingPathComponent(outputFile)) }
        return content == Constants.checkpassContent ? .matched : .notMatch
    }
}
