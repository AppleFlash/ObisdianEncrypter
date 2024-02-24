//
//  MainView.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.02.2024.
//

import SwiftUI

struct MainView: View {
    private let presenter: MainViewPresenter
    @ObservedObject var state: MainState

    init(presenter: MainViewPresenter, state: MainState) {
        self.presenter = presenter
        self.state = state
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading) {
                Text("Git folder:")
                HStack {
                    TextField("Enter .git repo path", text: $state.gitRepoPath)
                    Button("Set path") {
                        presenter.showFolderPrompt(.git)
                    }
                    .alert(isPresented: .constant(state.dirError != nil), error: state.dirError) { error in
                        Button("Ok") {
                            presenter.invalidateError()
                        }
                    } message: { error in
                        Text("Try again")
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("Obsidian folder:")
                HStack {
                    TextField("Enter Obisdian Vault repo path", text: $state.vaultRepoPath)
                    Button("Set path") {
                        presenter.showFolderPrompt(.vault)
                    }
                }
            }

            VStack(alignment: .leading) {
                Text(state.meta.actionPasswordTitle)
                HStack {
                    SecureField(state.meta.actionPlaceholder, text: $state.password).frame(maxWidth: 150)
                    Spacer()
                }
            }

            ZStack {
                if case let .inProgress(progressMessage) = state.progressState {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(progressMessage)
                        Spacer()
                    }
                }


                Button(state.meta.actionTitle) {
                    Task {
                        await presenter.doAction()
                    }
                }
                .disabled(!presenter.isActionAvailable())
                .alert(state.meta.actionSuccessMessage, isPresented: $state.needShowSyncedAlert) {
                    Button("Ok") {
                        presenter.invalidateActionState()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct EncryptView_Preview: PreviewProvider {
    static var previews: some View {
        let state = MainState(
            meta: MainState.Meta(
                actionPasswordTitle: "Test action pass",
                actionPlaceholder: "Test pass placeholder",
                actionTitle: "Test action title",
                actionSuccessMessage: "Test success message"
            )
        )
        MainView(
            presenter: .stub(),
            state: state
        )
    }
}
#endif
