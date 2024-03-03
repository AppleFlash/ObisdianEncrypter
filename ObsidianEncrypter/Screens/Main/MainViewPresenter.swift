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
    let doAction: () async -> Void
    let useKeychainPassowrd: () -> Void
}

extension MainViewPresenter {
    static func encryptPresenter(
        state: MainState,
        appStorageService: AppStorageService
    ) -> MainViewPresenter {
        let presenter = EncryptPresenter(
            state: state, 
            storageDir: "storage",
            fileManager: .defaultFileManager(),
            appStorageService: appStorageService,
            encryptService: .defaultService(),
            shellExecutor: .baseExecutor(),
            checkpassService: .defaultService(),
            fileReader: .baseReader(),
            keychainService: .defaultService(.codableService())
        )
        return MainViewPresenter(
            isActionAvailable: { [presenter] in presenter.isSyncAvailable },
            showFolderPrompt: presenter.showFolderPrompt,
            invalidateError: presenter.invalidateError,
            invalidateActionState: presenter.invalidateSyncState,
            doAction: presenter.synchronize,
            useKeychainPassowrd: presenter.useKeychainPassowrd
        )
    }

    static func decryptPresenter(
        state: MainState,
        appStorageService: AppStorageService
    ) -> MainViewPresenter {
        let presenter = DecryptPresenter(
            state: state, 
            storageFileName: "storage.zip.enc",
            fileManager: .defaultFileManager(),
            appStorageService: appStorageService,
            encryptService: .defaultService(),
            shellExecutor: .baseExecutor(),
            checkpassService: .defaultService(),
            keychainService: .defaultService(.codableService())
        )
        return MainViewPresenter(
            isActionAvailable: { [presenter] in presenter.isSyncAvailable },
            showFolderPrompt: presenter.showFolderPrompt,
            invalidateError: presenter.invalidateError,
            invalidateActionState: presenter.invalidateSyncState,
            doAction: presenter.decrypt,
            useKeychainPassowrd: presenter.useKeychainPassowrd
        )
    }

    static func stub() -> MainViewPresenter {
        MainViewPresenter(
            isActionAvailable: { true },
            showFolderPrompt: { _ in },
            invalidateError: {},
            invalidateActionState: {},
            doAction: {},
            useKeychainPassowrd: {}
        )
    }
}
