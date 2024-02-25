//
//  ObsidianEncrypterApp.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 02.02.2024.
//

import SwiftUI

@main
struct ObsidianEncrypterApp: App {
    var body: some Scene {
        WindowGroup {
            TabView  {
                MainFactory.shared.createEncrypt().tabItem { Text("Encrypt") }
                MainFactory.shared.createDecrypt().tabItem { Text("Decrypt") }
            }
        }
        Settings {
            MainFactory.shared.createSettings()
        }
    }
}

class MainFactory {
    static let shared = MainFactory()

    lazy var appStorageService = AppStorageService.make()

    func createEncrypt() -> some View {
        let state = MainState(
            meta: MainState.Meta(
                actionPasswordTitle: "Encrypt password:",
                actionPlaceholder: "Encryption pass",
                actionTitle: "Encrypt & Sync!",
                actionSuccessMessage: "Synced!"
            )
        )
        let presenter = MainViewPresenter.encryptPresenter(
            state: state,
            appStorageService: appStorageService
        )
        let view = MainView(presenter: presenter, state: state)
        return view
    }

    func createDecrypt() -> some View {
        let state = MainState(
            meta: MainState.Meta(
                actionPasswordTitle: "Decrypt password:",
                actionPlaceholder: "Decryption pass",
                actionTitle: "Decrypt!",
                actionSuccessMessage: "Decrypted!"
            )
        )
        let presenter = MainViewPresenter.decryptPresenter(
            state: state,
            appStorageService: appStorageService
        )
        let view = MainView(presenter: presenter, state: state)
        return view
    }

    func createSettings() -> some View {
        let state = NewCheckpassState()
        let presenter = NewCheckpassFilePresenter(
            appStorageService: appStorageService,
            state: state,
            fileManager: .defaultFileManager(),
            encryptService: .defaultService(),
            shellExecutor: .baseExecutor(),
            checkpassService: .defaultService()
        )

        return SettingsView {
            NewCheckpassFileView(state: state, presenter: presenter)
        }
    }
}
