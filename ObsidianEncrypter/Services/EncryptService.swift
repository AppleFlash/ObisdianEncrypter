//
//  EncryptService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 04.02.2024.
//

import Foundation

struct EncryptService: ClosureMockable {
    enum Constants {
        static let storageDirName = "storage"
        static let outputZipName = "storage.zip"
        static let encSuffix = ".enc"
    }

    enum EncryptAll {
        struct Payload {
            let gitDir: URL
            let vaultDir: URL
            let password: String
        }

        struct Dependencies {
            let fileManager: FileManagerService
            let shellExecutor: ShellExecutor
        }
    }

    let encryptAll: (EncryptAll.Payload, EncryptAll.Dependencies) async throws -> Void

    enum Encrypt {
        struct Payload {
            let file: String
            let password: String
            let baseDir: URL
        }

        struct Dependencies {
            let shellExecutor: ShellExecutor
        }
    }

    let encrypt: (Encrypt.Payload, Encrypt.Dependencies) async throws -> String

    enum Decrypt {
        struct Payload {
            let file: String
            let output: String
            let password: String
            let baseDir: URL
        }

        struct Dependencies {
            let shellExecutor: ShellExecutor
        }
    }

    let decrypt: (Decrypt.Payload, Decrypt.Dependencies) async throws -> Void
}

extension EncryptService {
    static func defaultService() -> Self {
        return Self(
            encryptAll: EncryptServiceImp.encryptAll(payload:dependencies:),
            encrypt: EncryptServiceImp.encrypt(payload:dependencies:),
            decrypt: EncryptServiceImp.decrypt(payload:dependencies:)
        )
    }
}

// MARK: - Implementation

private enum EncryptServiceImp {
    static func encryptAll(
        payload: EncryptService.EncryptAll.Payload,
        dependencies: EncryptService.EncryptAll.Dependencies
    ) async throws {
        let task = Task {
            let storageDir = payload.gitDir.appendingPathComponent(EncryptService.Constants.storageDirName)
            if dependencies.fileManager.fileExistsAtPath(storageDir.path(percentEncoded: false)) {
                try dependencies.fileManager.removeItem(storageDir)
            }
            try dependencies.fileManager.copyItem(payload.vaultDir, storageDir)
            _ = try await dependencies.shellExecutor.execute(
                "zip -r \(EncryptService.Constants.outputZipName) \(EncryptService.Constants.storageDirName)",
                payload.gitDir
            )
            try dependencies.fileManager.removeItem(storageDir)
            let encryptPayload = EncryptService.Encrypt.Payload(
                file: EncryptService.Constants.outputZipName,
                password: payload.password,
                baseDir: payload.gitDir
            )
            let encryptDeps = EncryptService.Encrypt.Dependencies(shellExecutor: dependencies.shellExecutor)
            try await encrypt(payload: encryptPayload, dependencies: encryptDeps)
            try dependencies.fileManager.removeItem(
                payload.gitDir.appendingPathComponent(EncryptService.Constants.outputZipName)
            )
        }
        return try await task.value
    }

    @discardableResult
    static func encrypt(
        payload: EncryptService.Encrypt.Payload,
        dependencies: EncryptService.Encrypt.Dependencies
    ) async throws -> String {
        let fileName = payload.file + EncryptService.Constants.encSuffix
        _ = try await dependencies.shellExecutor.execute(
            "openssl enc -aes-256-cbc -salt -pbkdf2 -in \(payload.file) -out \(fileName) -k \(payload.password)",
            payload.baseDir
        )

        return fileName
    }

    static func decrypt(
        payload: EncryptService.Decrypt.Payload,
        dependencies: EncryptService.Decrypt.Dependencies
    ) async throws {
        _ = try await dependencies.shellExecutor.execute(
            "openssl enc -aes-256-cbc -d -pbkdf2 -in \(payload.file) -out \(payload.output) -k \(payload.password)",
            payload.baseDir
        )
    }
}
