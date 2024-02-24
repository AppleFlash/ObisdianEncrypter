//
//  MainState.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 19.02.2024.
//

import Foundation
import Combine

final class MainState: ObservableObject {
    enum ProgressState {
        case notActive
        case inProgress(String)
        case done
    }

    enum DirError: LocalizedError {
        case noGitDir
        case noStorageInBaseGitDir(String)
        case noObsidianDir
        case encryptError(String)
        case decryptError(String)
        case noEncryptedStore

        var errorDescription: String? {
            switch self {
            case .noGitDir:
                return "Not valid git directory"
            case let .noStorageInBaseGitDir(dirName):
                return "Git fodler should contains \(dirName) directory"
            case .noObsidianDir:
                return "Obsidian folder should contains \(EncryptPresenter.Constants.obsidianDir) directory"
            case let .encryptError(message):
                return "Encryption or sync error. Message: \(message)"
            case let .decryptError(message):
                return "Decryption error. Message: \(message)"
            case .noEncryptedStore:
                return "The folder must contains an encrypted file"
            }
        }
    }

    @Published var gitRepoPath: String = ""
    @Published var vaultRepoPath: String = ""
    @Published var dirError: DirError?
    @Published var password: String = ""
    @Published var needShowSyncedAlert = false
    @Published var progressState: ProgressState = .notActive

    let meta: Meta

    init(meta: Meta) {
        self.meta = meta
    }

    struct Meta {
        let actionPasswordTitle: String
        let actionPlaceholder: String
        let actionTitle: String
        let actionSuccessMessage: String
    }
}
