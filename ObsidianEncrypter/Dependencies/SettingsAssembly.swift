//
//  SettingsAssembly.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 06.03.2024.
//

final class SettingsAssembly: Assembly {
    private lazy var serviceAssembly: ServiceAssembly = self.context.assembly()

    func newCheckpassPresenter(_ state: NewCheckpassState) -> NewCheckpassFilePresenter {
        define(
            .unique,
            initClosure: {
                NewCheckpassFilePresenter(
                    appStorageService: serviceAssembly.appStorageService,
                    state: state,
                    checkpassService: serviceAssembly.checkpassService,
                    keychainService: serviceAssembly.keychainService
                )
            }
        )
    }
}
