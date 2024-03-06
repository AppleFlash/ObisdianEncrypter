//
//  EncryptService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 04.02.2024.
//

import Foundation

struct EncryptService: ClosureMockable {
    let encryptAll: (EncryptAllPayload) async throws -> Void
    let encrypt: (EncryptPayload) async throws -> String
    let decrypt: (DecryptPayload) async throws -> Void
}

extension EncryptService {
    enum Constants {
        static let storageDirName = "storage"
        static let outputZipName = "storage.zip"
        static let encSuffix = ".enc"
    }

    struct EncryptAllPayload {
        let gitDir: URL
        let vaultDir: URL
        let password: String
    }

    struct EncryptPayload {
        let file: String
        let password: String
        let baseDir: URL
    }

    struct DecryptPayload {
        let file: String
        let output: String
        let password: String
        let baseDir: URL
    }
}

extension EncryptService {
    static func defaultService(
        fileManager: FileManagerService,
        shellExecutor: ShellExecutor
    ) -> Self {
        return Self(
            encryptAll: {
                try await EncryptServiceImp.encryptAll(
                    payload: $0,
                    fileManager: fileManager,
                    shellExecutor: shellExecutor
                )
            },
            encrypt: {
                try await EncryptServiceImp.encrypt(payload: $0, shellExecutor: shellExecutor)
            },
            decrypt: {
                try await EncryptServiceImp.decrypt(payload: $0, shellExecutor: shellExecutor)
            }
        )
    }
}

// MARK: - Implementation

private enum EncryptServiceImp {
    static func encryptAll(
        payload: EncryptService.EncryptAllPayload,
        fileManager: FileManagerService,
        shellExecutor: ShellExecutor
    ) async throws {
        let task = Task {
            let storageDir = payload.gitDir.appendingPathComponent(EncryptService.Constants.storageDirName)
            if fileManager.fileExistsAtPath(storageDir.path(percentEncoded: false)) {
                try fileManager.removeItem(storageDir)
            }
            try fileManager.copyItem(payload.vaultDir, storageDir)
            _ = try await shellExecutor.execute(
                "zip -r \(EncryptService.Constants.outputZipName) \(EncryptService.Constants.storageDirName)",
                payload.gitDir
            )
            try fileManager.removeItem(storageDir)
            let encryptPayload = EncryptService.EncryptPayload(
                file: EncryptService.Constants.outputZipName,
                password: payload.password,
                baseDir: payload.gitDir
            )
            try await encrypt(payload: encryptPayload, shellExecutor: shellExecutor)
            try fileManager.removeItem(
                payload.gitDir.appendingPathComponent(EncryptService.Constants.outputZipName)
            )
        }
        return try await task.value
    }

    @discardableResult
    static func encrypt(
        payload: EncryptService.EncryptPayload,
        shellExecutor: ShellExecutor
    ) async throws -> String {
        let fileName = payload.file + EncryptService.Constants.encSuffix
        _ = try await shellExecutor.execute(
            "openssl enc -aes-256-cbc -salt -pbkdf2 -in \(payload.file) -out \(fileName) -k \(payload.password)",
            payload.baseDir
        )

        return fileName
    }

    static func decrypt(
        payload: EncryptService.DecryptPayload,
        shellExecutor: ShellExecutor
    ) async throws {
        _ = try await shellExecutor.execute(
            "openssl enc -aes-256-cbc -d -pbkdf2 -in \(payload.file) -out \(payload.output) -k \(payload.password)",
            payload.baseDir
        )
    }
}
