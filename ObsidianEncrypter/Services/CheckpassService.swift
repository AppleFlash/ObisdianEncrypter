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

    static let encSuffix = Constants.checkpassSuffix + EncryptService.Constants.encSuffix

    static func checkPassfile(
        in repo: URL,
        pass: String,
        fileManager: FileManager = .default
    ) -> CheckStatus {
        let contents = catchError { try fileManager.contentsOfDirectory(atPath: repo.path(percentEncoded: false)) }
        let existingCheckpass = contents.first { $0.hasSuffix(encSuffix) }
        guard let existingCheckpass else {
            return .fileNotExist
        }

        let outputFile = "checkpass.output"
        catchError {
            try EncryptService.decrypt(
                existingCheckpass,
                output: outputFile,
                password: pass,
                baseDir: repo
            )
        }

        let outputUrl = repo.appendingPathComponent(outputFile)
        defer {
            catchError { try fileManager.removeItem(at: outputUrl) }
        }
        guard let content = try? String(contentsOf: outputUrl, encoding: .utf8) else {
            return .notMatch
        }
        return content == Constants.checkpassContent ? .matched : .notMatch
    }

    static func createPassfile(in repo: URL, name: String, pass: String, fileManager: FileManager) throws {
        try deleteExistingCheckpassFile(in: repo, fileManager: fileManager)

        let newFileName = name + CheckpassFileConstants.checkpassSuffix
        let newFilePath = repo.appendingPathComponent(newFileName)

        fileManager.createFile(
            atPath: newFilePath.path(percentEncoded: false),
            contents: CheckpassFileConstants.checkpassContent.data(using: .utf8)!
        )
        try EncryptService.encrypt(
            newFileName,
            password: pass,
            baseDir: repo
        )
        try fileManager.removeItem(at: newFilePath)
    }

    private static func deleteExistingCheckpassFile(in repo: URL, fileManager: FileManager) throws {
        let contents = try fileManager.contentsOfDirectory(atPath: repo.path(percentEncoded: false))
        let existingCheckpass = contents.first { $0.hasSuffix(CheckpassFileConstants.checkpassSuffix) }
        guard let existingCheckpass else {
            return
        }

        let deletePath = repo.appendingPathComponent(existingCheckpass)
        try fileManager.removeItem(atPath: deletePath.path())
    }
}
