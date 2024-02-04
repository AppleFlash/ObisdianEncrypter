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
            MainFactory.createMain()
        }
    }
}

enum MainFactory {
    static func createMain() -> some View {
        let state = MainState()
        let presenter = MainPresenter(state: state, fileManager: .default)
        let view = MainView(presenter: presenter, state: state)
        return view
    }
}
