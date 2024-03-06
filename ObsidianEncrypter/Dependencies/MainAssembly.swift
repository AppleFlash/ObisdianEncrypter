//
//  MainAssembly.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 06.03.2024.
//

final class MainAssembly: Assembly {
    private lazy var serviceAssembly: ServiceAssembly = self.context.assembly()

    var encryptState: MainState {
        define(
            .unique,
            object: MainState(
                meta: MainState.Meta(
                    actionPasswordTitle: "Encrypt password:",
                    actionPlaceholder: "Encryption pass",
                    actionTitle: "Encrypt & Sync!",
                    actionSuccessMessage: "Synced!"
                )
            )
        )
    }

    var decryptState: MainState {
        define(
            .unique,
            object: MainState(
                meta: MainState.Meta(
                    actionPasswordTitle: "Decrypt password:",
                    actionPlaceholder: "Decryption pass",
                    actionTitle: "Decrypt!",
                    actionSuccessMessage: "Decrypted!"
                )
            )
        )
    }

    func encryptPresenter(_ state: MainState) -> MainViewPresenter {
        define(
            .unique,
            initClosure: {
                let presenter = EncryptPresenter(
                    state: state,
                    storageDir: "storage",
                    fileManager: serviceAssembly.fileManager,
                    appStorageService: serviceAssembly.appStorageService,
                    encryptService: serviceAssembly.encryptService,
                    shellExecutor: serviceAssembly.shellExecutor,
                    checkpassService: serviceAssembly.checkpassService,
                    keychainService: serviceAssembly.keychainService
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
        )
    }

    func decryptPresenter(_ state: MainState) -> MainViewPresenter {
        define(
            .unique,
            initClosure: {
                let presenter = DecryptPresenter(
                    state: state,
                    storageFileName: "storage.zip.enc",
                    fileManager: serviceAssembly.fileManager,
                    appStorageService: serviceAssembly.appStorageService,
                    encryptService: serviceAssembly.encryptService,
                    shellExecutor: serviceAssembly.shellExecutor,
                    checkpassService: serviceAssembly.checkpassService,
                    keychainService: serviceAssembly.keychainService
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
        )
    }
}
