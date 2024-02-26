//
//  FileReader.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 27.02.2024.
//

import Foundation

struct FileReader: ClosureMockable {
    let readFile: (URL) throws -> String
}

extension FileReader {
    static func baseReader() -> Self {
        Self(readFile: {
            try String(contentsOf: $0, encoding: .utf8)
        })
    }
}
