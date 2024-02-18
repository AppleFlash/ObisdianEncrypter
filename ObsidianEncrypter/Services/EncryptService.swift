//
//  EncryptService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 04.02.2024.
//

import Foundation

enum EncryptService {
    enum Constants {
        static let storageDirName = "storage"
        static let outputZipName = "storage.zip"
        static let encSuffix = ".enc"
    }

    static func encryptAll(
        gitDir: URL,
        vaultDir: URL,
        password: String,
        fileManager: FileManager
    ) throws {
        let storageDir = gitDir.appendingPathComponent(Constants.storageDirName)
        if fileManager.fileExists(atPath: storageDir.path(percentEncoded: false)) {
            try fileManager.removeItem(at: storageDir)
        }
        try fileManager.copyItem(at: vaultDir, to: storageDir)
        catchError {
            try ShellExecutor.execute("zip -r \(Constants.outputZipName) \(Constants.storageDirName)", dirURL: gitDir)
            try fileManager.removeItem(at: storageDir)
            try encrypt(Constants.outputZipName, password: password, baseDir: gitDir)
            try fileManager.removeItem(at: gitDir.appendingPathComponent(Constants.outputZipName))
        }
    }

    @discardableResult
    static func encrypt(
        _ file: String,
        password: String,
        baseDir: URL
    ) throws -> String {
        let fileName = file + Constants.encSuffix
        try ShellExecutor.execute(
            "openssl enc -aes-256-cbc -salt -pbkdf2 -in \(file) -out \(fileName) -k \(password)",
            dirURL: baseDir
        )

        return fileName
    }

    static func decrypt(
        _ file: String,
        output: String,
        password: String,
        baseDir: URL
    ) throws {
        try ShellExecutor.execute(
            "openssl enc -aes-256-cbc -d -pbkdf2 -in \(file) -out \(output) -k \(password)",
            dirURL: baseDir
        )
    }
}
