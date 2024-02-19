//
//  MainViewPresenter.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 19.02.2024.
//

import Foundation

enum Folder {
    case git
    case vault
}

struct MainViewPresenter {
    let isActionAvailable: () -> Bool
    let showFolderPrompt: (Folder) -> Void
    let invalidateError: () -> Void
    let invalidateActionState: () -> Void
    let doAction: () -> Void
}

extension MainViewPresenter {
    static func encryptPresenter(
        state: MainState,
        fileManager: FileManager,
        appStorageService: AppStorageService
    ) -> MainViewPresenter {
        let presenter = EncryptPresenter(
            state: state, 
            storageDir: "storage",
            fileManager: fileManager,
            appStorageService: appStorageService
        )
        return MainViewPresenter(
            isActionAvailable: { [presenter] in presenter.isSyncAvailable },
            showFolderPrompt: presenter.showFolderPrompt,
            invalidateError: presenter.invalidateError,
            invalidateActionState: presenter.invalidateSyncState,
            doAction: presenter.synchronize
        )
    }

    static func decryptPresenter(
        state: MainState,
        fileManager: FileManager,
        appStorageService: AppStorageService
    ) -> MainViewPresenter {
        let presenter = DecryptPresenter(
            state: state, 
            storageFileName: "storage.zip.enc",
            fileManager: fileManager,
            appStorageService: appStorageService
        )
        return MainViewPresenter(
            isActionAvailable: { [presenter] in presenter.isSyncAvailable },
            showFolderPrompt: presenter.showFolderPrompt,
            invalidateError: presenter.invalidateError,
            invalidateActionState: presenter.invalidateSyncState,
            doAction: presenter.decrypt
        )
    }

    static func stub() -> MainViewPresenter {
        MainViewPresenter(
            isActionAvailable: { true },
            showFolderPrompt: { _ in },
            invalidateError: {},
            invalidateActionState: {},
            doAction: {}
        )
    }
}
