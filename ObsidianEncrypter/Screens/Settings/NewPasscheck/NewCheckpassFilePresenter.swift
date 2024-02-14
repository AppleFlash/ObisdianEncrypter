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
    private let fileManager: FileManager

    private var disposables = Set<AnyCancellable>()

    init(appStorageService: AppStorageService, state: NewCheckpassState, fileManager: FileManager = .default) {
        self.appStorageService = appStorageService
        self.state = state
        self.fileManager = fileManager

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

    func createNewCheckpassFile() {
        guard let gitRepoPath = state.gitRepoPath else {
            fatalError("Git path not set")
        }

        do {
            try deleteExistingCheckpassFile()

            let gitPathUrl = URL(filePath: gitRepoPath)
            let newFileName = state.checkfileName + CheckpassFileConstants.checkpassSuffix
            let newFilePath = gitPathUrl
                .appendingPathComponent(newFileName)
            let stringPath = newFilePath.path(percentEncoded: false)

            fileManager.createFile(
                atPath: newFilePath.path(percentEncoded: false),
                contents: CheckpassFileConstants.checkpassContent.data(using: .utf8)!
            )
            try EncryptService.encrypt(
                newFileName,
                password: state.checkfilePass,
                baseDir: gitPathUrl
            )
            let status = CheckpassService.checkPass(state.checkfilePass, gitRepoPath: gitRepoPath)
            state.checkfileName = ""
            state.checkfilePass = ""
            state.needShowSavedAlert = true
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func invalidateSaveState() {
        state.needShowSavedAlert = false
    }

    private func deleteExistingCheckpassFile() throws {
        guard let gitRepoPath = state.gitRepoPath else {
            fatalError("Git path not set")
        }

        let contents = try fileManager.contentsOfDirectory(atPath: gitRepoPath)
        let existingCheckpass = contents.first { $0.hasSuffix(CheckpassFileConstants.checkpassSuffix) }
        guard let existingCheckpass else {
            return
        }

        let deletePath = URL(filePath: gitRepoPath).appendingPathComponent(existingCheckpass)
        try fileManager.removeItem(atPath: deletePath.path())
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
