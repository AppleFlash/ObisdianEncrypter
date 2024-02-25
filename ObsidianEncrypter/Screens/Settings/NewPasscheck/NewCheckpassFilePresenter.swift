//
//  NewCheckpassFilePresenter.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 14.02.2024.
//

import Foundation
import Combine

enum CheckpassFileConstants {
    static let checkpassSuffix = ".pass"
    static let checkpassContent = "checkpass file content"
}

final class NewCheckpassFilePresenter {
    private enum Constants {
        static let checkpassSuffix = ".pass"
        static let checkpassContent = ".pass"
    }

    private let appStorageService: AppStorageService
    private let state: NewCheckpassState
    private let fileManager: FileManagerService
    private let encryptService: EncryptService
    private let shellExecutor: ShellExecutor
    private let checkpassService: CheckpassService

    private var disposables = Set<AnyCancellable>()

    init(
        appStorageService: AppStorageService,
        state: NewCheckpassState,
        fileManager: FileManagerService,
        encryptService: EncryptService,
        shellExecutor: ShellExecutor,
        checkpassService: CheckpassService
    ) {
        self.appStorageService = appStorageService
        self.state = state
        self.fileManager = fileManager
        self.encryptService = encryptService
        self.shellExecutor = shellExecutor
        self.checkpassService = checkpassService

        subscribePathChanges()
    }

    private func subscribePathChanges() {
        appStorageService
            .gitRepoPathUpdated()
            .compactMap { $0 }
            .sink { [state] in
                state.gitRepoPath = $0.path(percentEncoded: false)
            }
            .store(in: &disposables)
    }

    func createNewCheckpassFile() async {
        guard let gitRepoPath = state.gitRepoPath else {
            fatalError("Git path not set")
        }

        do {
            let gitPathUrl = URL(filePath: gitRepoPath)
            let createCheckpassPayload = CheckpassService.CreatePassfile.Payload(
                repo: gitPathUrl,
                name: state.checkfileName,
                pass: state.checkfilePass
            )
            let createCheckpassDeps = CheckpassService.CreatePassfile.Dependencies(
                fileManager: fileManager,
                shellExecutor: shellExecutor,
                encryptService: encryptService
            )
            try await checkpassService.createPassfile(createCheckpassPayload, createCheckpassDeps)

            await MainActor.run {
                state.checkfileName = ""
                state.checkfilePass = ""
                state.needShowSavedAlert = true
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func invalidateSaveState() {
        state.needShowSavedAlert = false
    }
}

final class NewCheckpassState: ObservableObject {
    @Published var gitRepoPath: String?
    @Published var checkfileName: String = ""
    @Published var checkfilePass: String = ""
    @Published var needShowSavedAlert = false

    var isGitSet: Bool {
        !(gitRepoPath?.isEmpty ?? true)
    }

    var isReadyToCreate: Bool {
        !checkfileName.isEmpty && !checkfilePass.isEmpty && isGitSet
    }
}
