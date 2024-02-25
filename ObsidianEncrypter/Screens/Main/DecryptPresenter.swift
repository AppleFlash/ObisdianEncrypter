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
    private let fileManager: FileManagerService
    private let appStorageService: AppStorageService
    private let encryptService: EncryptService
    private let shellExecutor: ShellExecutor
    private let checkpassService: CheckpassService

    private let storageFileName: String
    private var disposables = Set<AnyCancellable>()

    var isSyncAvailable: Bool {
        !state.password.isEmpty && !state.gitRepoPath.isEmpty && !state.vaultRepoPath.isEmpty && !state.progressState.isInProgress
    }

    init(
        state: MainState,
        storageFileName: String,
        fileManager: FileManagerService,
        appStorageService: AppStorageService,
        encryptService: EncryptService,
        shellExecutor: ShellExecutor,
        checkpassService: CheckpassService
    ) {
        self.state = state
        self.storageFileName = storageFileName
        self.fileManager = fileManager
        self.appStorageService = appStorageService
        self.encryptService = encryptService
        self.shellExecutor = shellExecutor
        self.checkpassService = checkpassService

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

    func decrypt() async {
        let gitDir = URL(filePath: state.gitRepoPath)
        let vaultDir = URL(filePath: state.vaultRepoPath)
        let zip = "output"
        let outputPath = gitDir.appendingPathComponent(zip)
        let newOutputPath = outputPath.appendingPathExtension("zip")

        let outputVaultZipPath = vaultDir.appendingPathComponent(zip).appendingPathExtension("zip")

        @MainActor func reset() {
            state.password = ""
            state.progressState = .done
        }

        func clean() {
            try? fileManager.removeItem(outputPath)
            try? fileManager.removeItem(newOutputPath)
        }

        do {
            await updateProgress("Decryptig...")
            let decryptPayload = EncryptService.Decrypt.Payload(
                file: storageFileName,
                output: zip,
                password: state.password,
                baseDir: gitDir
            )
            let decryptDeps = EncryptService.Decrypt.Dependencies(shellExecutor: shellExecutor)
            try await encryptService.decrypt(decryptPayload, decryptDeps)

            await updateProgress("Moving folder...")
            try fileManager.moveItem(outputPath, newOutputPath)
            try fileManager.moveItem(newOutputPath, outputVaultZipPath)

            await MainActor.run {
                state.needShowSyncedAlert = true
            }
        } catch ShellExecutor.ShError.nonZeroCode {
            clean()
            await MainActor.run {
                state.dirError = .decryptError("Password probably incorrect")
            }
        } catch {
            clean()
            await MainActor.run {
                state.dirError = .decryptError(error.localizedDescription)
            }
        }

        await reset()
    }

    @MainActor private func updateProgress(_ text: String) async {
        state.progressState = .inProgress(text)
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
        guard fileManager.fileExistsAtPath(storagePath.path()) else {
            state.dirError = .noEncryptedStore
            return
        }

        let path = url.path(percentEncoded: false)
        state.gitRepoPath = path
        appStorageService.saveDecryptInputRepoPath(url)
    }
}
