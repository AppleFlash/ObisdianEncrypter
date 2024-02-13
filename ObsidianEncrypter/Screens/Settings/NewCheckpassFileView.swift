//
//  NewCheckpassFileView.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 13.02.2024.
//

import SwiftUI

final class NewCheckpassState: ObservableObject {
    @Published var gitRepoPath: String?
    @Published var checkfileName: String = ""
    @Published var checkfilePass: String = ""
}

struct NewCheckpassFileView: View {
    @ObservedObject var state: NewCheckpassState

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
                Text("File's name. It will have .pass suffix")
                TextField("Enter file name", text: $state.checkfileName)
            }

            VStack(alignment: .leading, content: {
                Text("File's pass")
                SecureField("Enter new pass for password checkfile", text: $state.checkfilePass)
            })

            Button {
                print("tap")
            } label: {
                Text("Create").frame(width: 100)
            }
        }.padding(.all)
    }
}

#if DEBUG
struct NewCheckpassFileView_Preview: PreviewProvider {
    static var previews: some View {
        NewCheckpassFileView(state: NewCheckpassState())
    }
}
#endif
