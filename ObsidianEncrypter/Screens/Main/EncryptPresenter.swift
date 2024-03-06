//
//  MainPresenter.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import AppKit
import Combine

final class EncryptPresenter {
    enum Constants {
        static let gitDir = ".git"
        static let obsidianDir = ".obsidian"
    }

    private let state: MainState
    private let fileManager: FileManagerService
    private let appStorageService: AppStorageService
    private let storageDir: String
    private let encryptService: EncryptService
    private let shellExecutor: ShellExecutor
    private let checkpassService: CheckpassService
    private let keychainService: KeychainPasswordService

    private var disposables = Set<AnyCancellable>()

    var isSyncAvailable: Bool {
        !state.password.isEmpty && !state.gitRepoPath.isEmpty && !state.vaultRepoPath.isEmpty && !state.progressState.isInProgress
    }

    init(
        state: MainState,
        storageDir: String,
        fileManager: FileManagerService,
        appStorageService: AppStorageService,
        encryptService: EncryptService,
        shellExecutor: ShellExecutor,
        checkpassService: CheckpassService,
        keychainService: KeychainPasswordService
    ) {
        self.state = state
        self.storageDir = storageDir
        self.fileManager = fileManager
        self.appStorageService = appStorageService
        self.encryptService = encryptService
        self.shellExecutor = shellExecutor
        self.checkpassService = checkpassService
        self.keychainService = keychainService

        subscribePathChanges()
        useKeychainPassowrd()
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

    func useKeychainPassowrd() {
        guard let password = keychainService.readPassword() else {
            return
        }
        state.password = password
    }

    func invalidateError() {
        state.dirError = nil
    }

    func invalidateSyncState() {
        state.needShowSyncedAlert = false
        state.password = ""
    }

    func synchronize() async {
        @MainActor func clean() async {
            state.password = ""
        }
        
        do {
            let gitDir = URL(filePath: state.gitRepoPath)

            await updateProgress("Checking password...")
            let checkpassPayload = CheckpassService.CheckpassPayload(repo: gitDir, pass: state.password)
            let checkStatus = try await checkpassService.checkPassfile(checkpassPayload)
            if checkStatus == .fileNotExist {
                state.dirError = .encryptError("You should create passfile first")
                await clean()
                return
            }
            if checkStatus == .notMatch {
                state.dirError = .encryptError("Incorrect password. Create new file or try to remember")
                await clean()
                return
            }

            await updateProgress("Encrypting...")
            let encryptAllPayload = EncryptService.EncryptAllPayload(
                gitDir: gitDir,
                vaultDir: URL(filePath: state.vaultRepoPath),
                password: state.password
            )
            try await encryptService.encryptAll(encryptAllPayload)
            await updateProgress("Add to git...")
            _ = try await shellExecutor.execute("git add .", gitDir)
            await updateProgress("Creating commit...")
            _ = try await shellExecutor.execute(#"git commit -m "Encrypt all""#, gitDir)
            await updateProgress("Pushing to git...")
            _ = try await shellExecutor.execute("git push", gitDir)
            await MainActor.run {
                state.needShowSyncedAlert = true
                state.progressState = .done
            }
        } catch {
            await MainActor.run {
                state.progressState = .notActive
                state.dirError = .encryptError(error.localizedDescription)
            }
            await clean()
        }
    }

    @MainActor private func updateProgress(_ text: String) async {
        state.progressState = .inProgress(text)
    }

    private func subscribePathChanges() {
        appStorageService
            .gitRepoPathUpdated()
            .compactMap { $0 }
            .sink { [state] in
                state.gitRepoPath = $0.path(percentEncoded: false)
            }
            .store(in: &disposables)

        appStorageService
            .vaultRepoPathUpdated()
            .compactMap { $0 }
            .sink { [state] in
                state.vaultRepoPath = $0.path(percentEncoded: false)
            }
            .store(in: &disposables)
    }

    private func checkIfGitRepo(_ url: URL) {
        let gitDirPath = url.appendingPathComponent(Constants.gitDir)
        guard fileManager.hiddenDirExists(gitDirPath, url) else {
            state.dirError = .noGitDir
            return
        }
        let starogeDirPath = url.appendingPathComponent(storageDir)
        guard fileManager.fileExistsAtPath(starogeDirPath.path()) else {
            state.dirError = .noStorageInBaseGitDir(storageDir)
            return
        }

        let path = url.path(percentEncoded: false)
        state.gitRepoPath = path
        appStorageService.saveGitRepoPath(url)

    }

    private func checkIfObsidianRepo(_ url: URL) {
        let obsidianDirPath = url.appendingPathComponent(Constants.obsidianDir)
        guard fileManager.hiddenDirExists(obsidianDirPath, url) else {
            state.dirError = .noObsidianDir
            return
        }

        let path = url.path(percentEncoded: false)
        state.vaultRepoPath = path
        appStorageService.saveVaultRepoPath(url)
    }
}
