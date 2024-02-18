//
//  NewCheckpassFileView.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 13.02.2024.
//

import SwiftUI

struct NewCheckpassFileView: View {
    @ObservedObject private var state: NewCheckpassState
    private let presenter: NewCheckpassFilePresenter

    init(state: NewCheckpassState, presenter: NewCheckpassFilePresenter) {
        self.state = state
        self.presenter = presenter
    }

    var body: some View {
        if state.gitRepoPath != nil {
            contentView
        } else {
            Text("Ooops! Git repo path should be set")
                .foregroundStyle(.red)
                .padding()
        }
    }

    private var contentView: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("File's name. It will have \(CheckpassService.encSuffix) suffix")
                TextField("Enter file name", text: $state.checkfileName)
            }

            VStack(alignment: .leading, content: {
                Text("File's pass")
                SecureField("Enter new pass for password checkfile", text: $state.checkfilePass)
            })

            Button {
                presenter.createNewCheckpassFile()
            } label: {
                Text("Create").frame(width: 100)
            }
            .disabled(!state.isReadyToCreate)
            .alert("Saved!", isPresented: $state.needShowSavedAlert) {
                Button("Ok") {
                    presenter.invalidateSaveState()
                }
            }

        }.padding(.all)
    }
}
