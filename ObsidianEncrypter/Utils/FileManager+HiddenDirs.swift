//
//  FileManager+HiddenDirs.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 19.02.2024.
//

import Foundation

extension FileManager {
    func hiddenDirExists(_ hiddenDir: URL, in dir: URL) -> Bool {
        let result = try? contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isHiddenKey])
            .first { url in
                let values = try? url.resourceValues(forKeys: [.isHiddenKey])
                return url == hiddenDir && values?.isHidden == true
            }
        return result != nil
    }
}
