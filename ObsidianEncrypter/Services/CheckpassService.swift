//
//  CheckpassService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 15.02.2024.
//

import Foundation

struct CheckpassService {
    enum CheckStatus {
        case fileNotExist
        case matched
        case notMatch
    }

    enum Constants {
        static let checkpassSuffix = ".pass"
        static let checkpassContent = "checkpass file content"
        static let encSuffix = CheckpassService.Constants.checkpassSuffix + EncryptService.Constants.encSuffix
    }

    enum CheckPassfile {
        struct Payload {
            let repo: URL
            let pass: String
        }

        struct Dependencies {
            let fileManager: FileManagerService
            let encryptService: EncryptService
            let shellExecutor: ShellExecutor
        }
    }

    let checkPassfile: (CheckPassfile.Payload, CheckPassfile.Dependencies) async throws -> CheckStatus

    enum CreatePassfile {
        struct Payload {
            let repo: URL
            let name: String
            let pass: String
        }

        struct Dependencies {
            let fileManager: FileManagerService
            let shellExecutor: ShellExecutor
            let encryptService: EncryptService
        }
    }

    let createPassfile: (CreatePassfile.Payload, CreatePassfile.Dependencies) async throws -> Void
}

extension CheckpassService {
    static func defaultService() -> CheckpassService {
        Self(
            checkPassfile: CheckpassServiceImp.checkPassfile(payload:dependencies:),
            createPassfile: CheckpassServiceImp.createPassfile(payload:dependencies:)
        )
    }
}

// MARK: - Implementation

private enum CheckpassServiceImp {
    static func checkPassfile(
        payload: CheckpassService.CheckPassfile.Payload,
        dependencies: CheckpassService.CheckPassfile.Dependencies
    ) async throws -> CheckpassService.CheckStatus {
        let task = Task.detached(priority: .userInitiated) {
            let contents = try dependencies.fileManager.contentsOfDirectory(payload.repo.path(percentEncoded: false))
            let existingCheckpass = contents.first { $0.hasSuffix(CheckpassService.Constants.encSuffix) }
            guard let existingCheckpass else {
                return CheckpassService.CheckStatus.fileNotExist
            }

            let outputFile = "checkpass.output"
            let decryptPayload = EncryptService.Decrypt.Payload(
                file: existingCheckpass,
                output: outputFile,
                password: payload.pass,
                baseDir: payload.repo
            )
            let decryptDeps = EncryptService.Decrypt.Dependencies(shellExecutor: dependencies.shellExecutor)
            try await dependencies.encryptService.decrypt(decryptPayload, decryptDeps)

            let outputUrl = payload.repo.appendingPathComponent(outputFile)
            defer {
                catchError { try dependencies.fileManager.removeItem(outputUrl) }
            }
            guard let content = try? String(contentsOf: outputUrl, encoding: .utf8) else {
                return .notMatch
            }

            return content == CheckpassService.Constants.checkpassContent ? .matched : .notMatch
        }

        return try await task.value
    }

    static func createPassfile(
        payload: CheckpassService.CreatePassfile.Payload,
        dependencies: CheckpassService.CreatePassfile.Dependencies
    ) async throws {
        try deleteExistingCheckpassFile(in: payload.repo, fileManager: dependencies.fileManager)

        let newFileName = payload.name + CheckpassService.Constants.checkpassSuffix
        let newFilePath = payload.repo.appendingPathComponent(newFileName)

        dependencies.fileManager.createFile(
            newFilePath.path(percentEncoded: false),
            CheckpassFileConstants.checkpassContent.data(using: .utf8)
        )
        let encryptPayload = EncryptService.Encrypt.Payload(
            file: newFileName,
            password: payload.pass,
            baseDir: payload.repo
        )
        let encryptDeps = EncryptService.Encrypt.Dependencies(shellExecutor: dependencies.shellExecutor)
        _ = try await dependencies.encryptService.encrypt(encryptPayload, encryptDeps)
        try dependencies.fileManager.removeItem(newFilePath)
    }

    private static func deleteExistingCheckpassFile(in repo: URL, fileManager: FileManagerService) throws {
        let contents = try fileManager.contentsOfDirectory(repo.path(percentEncoded: false))
        let existingCheckpass = contents.first { $0.hasSuffix(CheckpassFileConstants.checkpassSuffix) }
        guard let existingCheckpass else {
            return
        }

        let deletePath = repo.appendingPathComponent(existingCheckpass)
        try fileManager.removeItem(deletePath)
    }
}
