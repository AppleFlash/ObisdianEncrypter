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

    func createNewCheckpassFile() async {
        guard let gitRepoPath = state.gitRepoPath else {
            fatalError("Git path not set")
        }

        do {
            let gitPathUrl = URL(filePath: gitRepoPath)
            try await CheckpassService.createPassfile(
                in: gitPathUrl,
                name: state.checkfileName,
                pass: state.checkfilePass,
                fileManager: fileManager
            )

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
