//
//  MainPresenter.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import AppKit

enum Folder {
    case git
    case vault
}

final class MainPresenter {
    enum Constants {
        static let storageDir = "storage"
        static let gitDir = ".git"
        static let obsidianDir = ".obsidian"

        fileprivate static let gitDirKey = "syncronizer.git.dir"
        fileprivate static let vaultDirKey = "syncronizer.vault.dir"
    }

    private let state: MainState
    private let fileManager: FileManager

    var isSyncAvailable: Bool {
        !state.encryptionPass.isEmpty && !state.gitRepoPath.isEmpty && !state.vaultRepoPath.isEmpty
    }

    init(state: MainState, fileManager: FileManager) {
        self.state = state
        self.fileManager = fileManager

        tryRestorePaths()
    }

    func showFolderPrompt(folder: Folder) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        openPanel.begin { [weak self] response in
            if response == .OK {
                guard let url = openPanel.urls.first else {
                    return
                }

                switch folder {
                case .git:
                    self?.checkIfGitRepo(url)
                case .vault:
                    self?.checkIfObsidianRepo(url)
                }
            }
        }
    }

    func invalidateError() {
        state.dirError = nil
    }

    func invalidateSyncState() {
        state.needShowSyncedAlert = false
        state.encryptionPass = ""
    }

    func synchronize() {
        do {
            try EncryptService.encryptAll(
                gitDir: URL(filePath: state.gitRepoPath),
                vaultDir: URL(filePath: state.vaultRepoPath),
                password: state.encryptionPass,
                fileManager: fileManager
            )
            state.needShowSyncedAlert = true
        } catch {
            state.dirError = .encryptError(error.localizedDescription)
        }
    }

    private func tryRestorePaths() {
        if let gitRepoPath = UserDefaults.standard.url(forKey: Constants.gitDirKey) {
            state.gitRepoPath = gitRepoPath.path(percentEncoded: false)
        }
        if let vaultRepoPath = UserDefaults.standard.url(forKey: Constants.vaultDirKey) {
            state.vaultRepoPath = vaultRepoPath.path(percentEncoded: false)
        }
    }

    private func checkIfGitRepo(_ url: URL) {
        let gitDirPath = url.appendingPathComponent(Constants.gitDir)
        guard fileManager.hiddenDirExists(gitDirPath, in: url) else {
            state.dirError = .noGitDir
            return
        }
        let starogeDirPath = url.appendingPathComponent(Constants.storageDir)
        guard fileManager.fileExists(atPath: starogeDirPath.path()) else {
            state.dirError = .noStorageInBaseGitDir
            return
        }

        let path = url.path(percentEncoded: false)
        state.gitRepoPath = path
        UserDefaults.standard.set(path, forKey: Constants.gitDirKey)

    }

    private func checkIfObsidianRepo(_ url: URL) {
        let obsidianDirPath = url.appendingPathComponent(Constants.obsidianDir)
        guard fileManager.hiddenDirExists(obsidianDirPath, in: url) else {
            state.dirError = .noObsidianDir
            return
        }

        let path = url.path(percentEncoded: false)
        state.vaultRepoPath = path
        UserDefaults.standard.set(path, forKey: Constants.vaultDirKey)
    }
}

extension FileManager {
    func hiddenDirExists(_ hiddenDir: URL, in dir: URL) -> Bool {
        let result = try? contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isHiddenKey])
            .first { url in
                let values = try? url.resourceValues(forKeys: [.isHiddenKey])
                return url == hiddenDir && values?.isHidden == true
            }
        return result != nil
    }
}

final class MainState: ObservableObject {
    enum DirError: LocalizedError {
        case noGitDir
        case noStorageInBaseGitDir
        case noObsidianDir
        case encryptError(String)

        var errorDescription: String? {
            switch self {
            case .noGitDir:
                return "Not valid git directory"
            case .noStorageInBaseGitDir:
                return "Git fodler should contains \(MainPresenter.Constants.storageDir) directory"
            case .noObsidianDir:
                return "Obsidian folder should contains \(MainPresenter.Constants.obsidianDir) directory"
            case let .encryptError(message):
                return "Encryption or sync error. Message: \(message)"
            }
        }
    }

    @Published var gitRepoPath: String = ""
    @Published var vaultRepoPath: String = ""
    @Published var dirError: DirError?
    @Published var encryptionPass: String = ""
    @Published var needShowSyncedAlert = false
}
