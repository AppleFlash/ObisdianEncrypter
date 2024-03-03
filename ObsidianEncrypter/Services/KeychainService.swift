//
//  KeychainService.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 02.03.2024.
//

import CryptoKit
import Foundation

struct KeychainService<T> {
    struct SavePayload {
        let object: T
        let info: ObjectInfo
    }
    struct ObjectInfo {
        let service: String
        let account: String
    }

    let saveObject: (SavePayload) -> Void
    let readObject: (ObjectInfo) -> T?
}

extension KeychainService where T: Codable {
    static func codableService() -> KeychainService<T> {
        KeychainService<T>(
            saveObject: { payload in
                guard let data = try? JSONEncoder().encode(payload.object) else {
                    return
                }

                let query = [
                    kSecValueData: data,
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrService: payload.info.service,
                    kSecAttrAccount: payload.info.account,
                ] as CFDictionary

                let status = SecItemAdd(query, nil)

                if status == errSecDuplicateItem {
                    // Item already exist, thus update it.
                    let query = [
                        kSecAttrService: payload.info.service,
                        kSecAttrAccount: payload.info.account,
                        kSecClass: kSecClassGenericPassword,
                    ] as CFDictionary

                    let attributesToUpdate = [kSecValueData: data] as CFDictionary

                    // Update existing item
                    SecItemUpdate(query, attributesToUpdate)
                }
            }, readObject: { info in
                let query = [
                    kSecAttrService: info.service,
                    kSecAttrAccount: info.account,
                    kSecClass: kSecClassGenericPassword,
                    kSecReturnData: true
                ] as CFDictionary

                var result: AnyObject?
                SecItemCopyMatching(query, &result)
                guard let data = result as? Data else {
                    return nil
                }

                let object = try? JSONDecoder().decode(T.self, from: data)
                return object
            }
        )
    }
}

struct KeychainPasswordService {
    let savePassword: (String) -> Void
    let readPassword: () -> String?
}

extension KeychainPasswordService {
    static func defaultService(_ keychainService: KeychainService<String>) -> Self {
        let objectInfo = KeychainService<String>.ObjectInfo(
            service: "Obsidian Checkpass",
            account: "obsidian checkpass"
        )

        return Self(
            savePassword: { password in
                keychainService.saveObject(KeychainService.SavePayload(object: password, info: objectInfo))
            },
            readPassword: {
                keychainService.readObject(objectInfo)
            }
        )
    }
}
