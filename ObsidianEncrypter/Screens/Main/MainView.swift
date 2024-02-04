//
//  MainView.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import SwiftUI

struct MainView: View {
    private let presenter: MainPresenter
    @ObservedObject var state: MainState

    init(presenter: MainPresenter, state: MainState) {
        self.presenter = presenter
        self.state = state
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Enter .git repo path", text: $state.gitRepoPath)
                Button("Set path") {
                    presenter.showFolderPrompt(folder: .git)
                }
                .alert(isPresented: .constant(state.dirError != nil), error: state.dirError) { error in
                    Button("Ok") {
                        presenter.invalidateError()
                    }
                } message: { error in
                    Text("Try again")
                }
            }
            HStack {
                TextField("Enter Obisdian Vault repo path", text: $state.vaultRepoPath)
                Button("Set path") {
                    presenter.showFolderPrompt(folder: .vault)
                }
            }

            SecureField("Encryption pass", text: $state.encryptionPass)

            Button("Sync!") {
                presenter.synchronize()
            }
            .disabled(!presenter.isSyncAvailable)
            .alert("Synced!", isPresented: $state.needShowSyncedAlert) {
                Button("Ok") {
                    presenter.invalidateSyncState()
                }
            }
        }
    }
}
