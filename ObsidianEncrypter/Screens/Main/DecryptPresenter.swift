//
//  DecryptPresenter.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 19.02.2024.
//

import AppKit
import Combine

final class DecryptPresenter {
    private let state: MainState
    private let fileManager: FileManager
    private let appStorageService: AppStorageService

    private let storageFileName: String
    private var disposables = Set<AnyCancellable>()

    var isSyncAvailable: Bool {
        !state.password.isEmpty && !state.gitRepoPath.isEmpty && !state.vaultRepoPath.isEmpty
    }

    init(state: MainState, storageFileName: String, fileManager: FileManager, appStorageService: AppStorageService) {
        self.state = state
        self.storageFileName = storageFileName
        self.fileManager = fileManager
        self.appStorageService = appStorageService

        subscribePathChanges()
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
                    self?.state.vaultRepoPath = url.path(percentEncoded: false)
                    self?.appStorageService.saveDecryptOutputRepoPath(url)
                }
            }
        }
    }

    func invalidateError() {
        state.dirError = nil
    }

    func invalidateSyncState() {
        state.needShowSyncedAlert = false
        state.password = ""
    }

    func decrypt() {
        let gitDir = URL(filePath: state.gitRepoPath)
        let vaultDir = URL(filePath: state.vaultRepoPath)
        let zip = "output"
        let outputPath = gitDir.appendingPathComponent(zip)
        let newOutputPath = outputPath.appendingPathExtension("zip")
        
        let outputVaultZipPath = vaultDir.appendingPathComponent(zip).appendingPathExtension("zip")

        defer {
            state.password = ""
        }

        func clear() {
            try? fileManager.removeItem(at: outputPath)
            try? fileManager.removeItem(at: newOutputPath)
        }

        do {
            try EncryptService.decrypt(
                storageFileName,
                output: zip,
                password: state.password,
                baseDir: gitDir
            )

            try fileManager.moveItem(at: outputPath, to: newOutputPath)

            try fileManager.moveItem(
                at: newOutputPath,
                to: outputVaultZipPath
            )

            state.needShowSyncedAlert = true
        } catch ShellExecutor.ShError.nonZeroCode {
            clear()
            state.dirError = .decryptError("Password probably incorrect")
        } catch {
            clear()
            state.dirError = .decryptError(error.localizedDescription)
        }
    }

    private func subscribePathChanges() {
        appStorageService
            .decryptInputRepoPathUpdated()
            .compactMap { $0 }
            .sink { [state] in
                state.gitRepoPath = $0.path(percentEncoded: false)
            }
            .store(in: &disposables)

        appStorageService
            .decryptOutputRepoPathUpdated()
            .compactMap { $0 }
            .sink { [state] in
                state.vaultRepoPath = $0.path(percentEncoded: false)
            }
            .store(in: &disposables)
    }

    private func checkIfGitRepo(_ url: URL) {
        let storagePath = url.appendingPathComponent(storageFileName)
        guard fileManager.fileExists(atPath: storagePath.path()) else {
            state.dirError = .noEncryptedStore
            return
        }

        let path = url.path(percentEncoded: false)
        state.gitRepoPath = path
        appStorageService.saveDecryptInputRepoPath(url)
    }
}
