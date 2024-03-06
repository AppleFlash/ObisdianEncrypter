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
