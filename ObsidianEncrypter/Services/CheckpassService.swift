//
//  CheckpassService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 15.02.2024.
//

import Foundation

struct CheckpassService {
    let checkPassfile: (CheckpassPayload) async throws -> CheckStatus
    let createPassfile: (CreatePassfilePayload) async throws -> Void
}

extension CheckpassService {
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

    struct CheckpassPayload {
        let repo: URL
        let pass: String
    }

    struct CreatePassfilePayload {
        let repo: URL
        let name: String
        let pass: String
    }
}

extension CheckpassService {
    static func defaultService(
        fileManager: FileManagerService,
        encryptService: EncryptService,
        shellExecutor: ShellExecutor,
        fileReader: FileReader
    ) -> CheckpassService {
        let service = CheckpassServiceImp(
            fileManager: fileManager,
            encryptService: encryptService,
            shellExecutor: shellExecutor,
            fileReader: fileReader
        )
        return Self(
            checkPassfile: service.checkPassfile(payload:),
            createPassfile: service.createPassfile(payload:)
        )
    }
}

// MARK: - Implementation

private final class CheckpassServiceImp {
    private let fileManager: FileManagerService
    private let encryptService: EncryptService
    private let shellExecutor: ShellExecutor
    private let fileReader: FileReader

    init(
        fileManager: FileManagerService,
        encryptService: EncryptService,
        shellExecutor: ShellExecutor,
        fileReader: FileReader
    ) {
        self.fileManager = fileManager
        self.encryptService = encryptService
        self.shellExecutor = shellExecutor
        self.fileReader = fileReader
    }

    func checkPassfile(
        payload: CheckpassService.CheckpassPayload
    ) async throws -> CheckpassService.CheckStatus {
        let task = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else {
                return CheckpassService.CheckStatus.notMatch
            }

            let contents = try fileManager.contentsOfDirectory(payload.repo.path(percentEncoded: false))
            let existingCheckpass = contents.first { $0.hasSuffix(CheckpassService.Constants.encSuffix) }
            guard let existingCheckpass else {
                return CheckpassService.CheckStatus.fileNotExist
            }

            let outputFile = "checkpass.output"
            let decryptPayload = EncryptService.DecryptPayload(
                file: existingCheckpass,
                output: outputFile,
                password: payload.pass,
                baseDir: payload.repo
            )
            try await encryptService.decrypt(decryptPayload)

            let outputUrl = payload.repo.appendingPathComponent(outputFile)
            defer {
                catchError { try self.fileManager.removeItem(outputUrl) }
            }

            guard let content = try? fileReader.readFile(outputUrl) else {
                return .notMatch
            }

            return content == CheckpassService.Constants.checkpassContent ? .matched : .notMatch
        }

        return try await task.value
    }

    func createPassfile(
        payload: CheckpassService.CreatePassfilePayload
    ) async throws {
        try deleteExistingCheckpassFile(in: payload.repo, fileManager: fileManager)

        let newFileName = payload.name + CheckpassService.Constants.checkpassSuffix
        let newFilePath = payload.repo.appendingPathComponent(newFileName)

        fileManager.createFile(
            newFilePath.path(percentEncoded: false),
            CheckpassFileConstants.checkpassContent.data(using: .utf8)
        )
        let encryptPayload = EncryptService.EncryptPayload(
            file: newFileName,
            password: payload.pass,
            baseDir: payload.repo
        )
        _ = try await encryptService.encrypt(encryptPayload)
        try fileManager.removeItem(newFilePath)
    }

    private func deleteExistingCheckpassFile(in repo: URL, fileManager: FileManagerService) throws {
        let contents = try fileManager.contentsOfDirectory(repo.path(percentEncoded: false))
        let existingCheckpass = contents.first { $0.hasSuffix(CheckpassFileConstants.checkpassSuffix) }
        guard let existingCheckpass else {
            return
        }

        let deletePath = repo.appendingPathComponent(existingCheckpass)
        try fileManager.removeItem(deletePath)
    }
}
