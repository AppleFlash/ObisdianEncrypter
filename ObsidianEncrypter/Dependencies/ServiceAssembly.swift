//
//  ServiceAssembly.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 06.03.2024.
//

final class ServiceAssembly: Assembly {
    var fileManager: FileManagerService {
        define(.signleton, object: .defaultFileManager())
    }

    var appStorageService: AppStorageService {
        define(.signleton, object: .make())
    }

    var encryptService: EncryptService {
        define(
            .signleton,
            object: .defaultService(
                fileManager: fileManager,
                shellExecutor: shellExecutor
            )
        )
    }

    var shellExecutor: ShellExecutor {
        define(.signleton, object: .baseExecutor())
    }

    var checkpassService: CheckpassService {
        define(
            .signleton,
            object: .defaultService(
                fileManager: fileManager,
                encryptService: encryptService,
                shellExecutor: shellExecutor,
                fileReader: fileReader
            )
        )
    }

    var fileReader: FileReader {
        define(.signleton, object: .baseReader())
    }

    var keychainService: KeychainPasswordService {
        define(.signleton, object: .defaultService(.codableService()))
    }
}
