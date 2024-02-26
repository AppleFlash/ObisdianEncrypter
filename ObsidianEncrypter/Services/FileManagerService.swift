//
//  FileManagerService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 25.02.2024.
//

import Foundation

struct FileManagerService: ClosureMockable {
    let fileExistsAtPath: (String) -> Bool
    let removeItem: (URL) throws -> Void
    let copyItem: (_ source: URL, _ destination: URL) throws -> Void
    let contentsOfDirectory: (_ path: String) throws -> [String]
    let createFile: (_ path: String, _ content: Data?) -> Void
    let hiddenDirExists: (_ hiddenDir: URL, _ dir: URL) -> Bool
    let moveItem: (_ source: URL, _ destination: URL) throws -> Void
}

extension FileManagerService {
    static func defaultFileManager() -> Self {
        Self(
            fileExistsAtPath: FileManager.default.fileExists(atPath:),
            removeItem: FileManager.default.removeItem(at:),
            copyItem: FileManager.default.copyItem(at:to:),
            contentsOfDirectory: FileManager.default.contentsOfDirectory(atPath:),
            createFile: {
                FileManager.default.createFile(atPath: $0, contents: $1, attributes: nil)
            },
            hiddenDirExists: FileManager.default.hiddenDirExists(_:in:),
            moveItem: FileManager.default.moveItem(at:to:)
        )
    }
}
