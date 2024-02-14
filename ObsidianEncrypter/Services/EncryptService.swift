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
            try pushChanges(baseDir: gitDir)
        }
    }

    static func encrypt(
        _ file: String,
        password: String,
        baseDir: URL
    ) throws {
        try ShellExecutor.execute(
            "openssl enc -aes-256-cbc -salt -pbkdf2 -in \(file) -out \(file).enc -k \(password)",
            dirURL: baseDir
        )
    }

    static func dencrypt(
        _ file: String,
        output: String,
        password: String,
        baseDir: URL
    ) throws {
        try ShellExecutor.execute(
            "openssl enc -aes-256-cbc -d -pbkdf2 -in \(file).enc -out \(output) -k \(password)",
            dirURL: baseDir
        )
    }

    private static func pushChanges(baseDir: URL) throws {
        try ShellExecutor.execute("git add .", dirURL: baseDir)
        try ShellExecutor.execute(#"git commit -m "Encrypt all""#, dirURL: baseDir)
        try ShellExecutor.execute("git push", dirURL: baseDir)
    }
}
