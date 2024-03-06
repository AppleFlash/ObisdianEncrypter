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
    private lazy var mainAssembly = MainAssembly.create()
    private lazy var settingsAssembly = SettingsAssembly.create()

    func createEncrypt() -> some View {
        let state = mainAssembly.encryptState
        let presenter = mainAssembly.encryptPresenter(state)
        let view = MainView(presenter: presenter, state: state)
        return view
    }

    func createDecrypt() -> some View {
        let state = mainAssembly.decryptState
        let presenter = mainAssembly.decryptPresenter(state)
        let view = MainView(presenter: presenter, state: state)
        return view
    }

    func createSettings() -> some View {
        let state = NewCheckpassState()
        let presenter = settingsAssembly.newCheckpassPresenter(state)

        return SettingsView {
            NewCheckpassFileView(state: state, presenter: presenter)
        }
    }
}
