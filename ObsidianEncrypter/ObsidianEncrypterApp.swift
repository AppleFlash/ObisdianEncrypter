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
            MainFactory.shared.createMain()
        }
        Settings {
            MainFactory.shared.createSettings()
        }
    }
}

class MainFactory {
    static let shared = MainFactory()

    lazy var appStorageService = AppStorageService.make()

    func createMain() -> some View {
        let state = MainState()
        let presenter = MainPresenter(state: state, fileManager: .default, appStorageService: appStorageService)
        let view = MainView(presenter: presenter, state: state)
        return view
    }

    func createSettings() -> some View {
        let state = NewCheckpassState()
        let presenter = NewCheckpassFilePresenter(appStorageService: appStorageService, state: state)

        return SettingsView {
            NewCheckpassFileView(state: state, presenter: presenter)
        }
    }
}
