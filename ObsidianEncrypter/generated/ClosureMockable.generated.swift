// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
@testable import ObsidianEncrypter
import Foundation
import XCTest

final class EncryptServiceMock {
    var encryptAllStub: ((EncryptService.EncryptAll.Payload, EncryptService.EncryptAll.Dependencies) async throws  -> Void)?
    private (set) var encryptAllInvocationCount = 0
    private (set) var encryptAllReceivedArgs: [(EncryptService.EncryptAll.Payload, EncryptService.EncryptAll.Dependencies)] = []
    private(set) lazy var encryptAll: (EncryptService.EncryptAll.Payload, EncryptService.EncryptAll.Dependencies) async throws  -> Void = { arg1, arg2 in
        guard let stub = self.encryptAllStub else {
            XCTFail("Stub not set for encryptAllStub")
            return 
        }

        self.encryptAllReceivedArgs.append((arg1, arg2))
        return try await stub(arg1, arg2)
    }
    var encryptStub: ((EncryptService.Encrypt.Payload, EncryptService.Encrypt.Dependencies) async throws  -> String)?
    var encryptDefaultValue: String! 
    private (set) var encryptInvocationCount = 0
    private (set) var encryptReceivedArgs: [(EncryptService.Encrypt.Payload, EncryptService.Encrypt.Dependencies)] = []
    private(set) lazy var encrypt: (EncryptService.Encrypt.Payload, EncryptService.Encrypt.Dependencies) async throws  -> String = { arg1, arg2 in
        guard let stub = self.encryptStub else {
            XCTFail("Stub not set for encryptStub")
            return self.encryptDefaultValue 
        }

        self.encryptReceivedArgs.append((arg1, arg2))
        return try await stub(arg1, arg2)
    }
    var decryptStub: ((EncryptService.Decrypt.Payload, EncryptService.Decrypt.Dependencies) async throws  -> Void)?
    private (set) var decryptInvocationCount = 0
    private (set) var decryptReceivedArgs: [(EncryptService.Decrypt.Payload, EncryptService.Decrypt.Dependencies)] = []
    private(set) lazy var decrypt: (EncryptService.Decrypt.Payload, EncryptService.Decrypt.Dependencies) async throws  -> Void = { arg1, arg2 in
        guard let stub = self.decryptStub else {
            XCTFail("Stub not set for decryptStub")
            return 
        }

        self.decryptReceivedArgs.append((arg1, arg2))
        return try await stub(arg1, arg2)
    }
}

extension EncryptService {
    static func mock(_ object: EncryptServiceMock) -> Self {
        EncryptService(encryptAll: object.encryptAll, encrypt: object.encrypt, decrypt: object.decrypt)
    }
}
final class FileManagerServiceMock {
    var fileExistsAtPathStub: ((String)  -> Bool)?
    var fileExistsAtPathDefaultValue: Bool! 
    private (set) var fileExistsAtPathInvocationCount = 0
    private (set) var fileExistsAtPathReceivedArgs: [(String)] = []
    private(set) lazy var fileExistsAtPath: (String)  -> Bool = { arg1 in
        guard let stub = self.fileExistsAtPathStub else {
            XCTFail("Stub not set for fileExistsAtPathStub")
            return self.fileExistsAtPathDefaultValue 
        }

        self.fileExistsAtPathReceivedArgs.append((arg1))
        return   stub(arg1)
    }
    var removeItemStub: ((URL) throws  -> Void)?
    private (set) var removeItemInvocationCount = 0
    private (set) var removeItemReceivedArgs: [(URL)] = []
    private(set) lazy var removeItem: (URL) throws  -> Void = { arg1 in
        guard let stub = self.removeItemStub else {
            XCTFail("Stub not set for removeItemStub")
            return 
        }

        self.removeItemReceivedArgs.append((arg1))
        return try  stub(arg1)
    }
    var copyItemStub: ((URL, URL) throws  -> Void)?
    private (set) var copyItemInvocationCount = 0
    private (set) var copyItemReceivedArgs: [(URL, URL)] = []
    private(set) lazy var copyItem: (URL, URL) throws  -> Void = { arg1, arg2 in
        guard let stub = self.copyItemStub else {
            XCTFail("Stub not set for copyItemStub")
            return 
        }

        self.copyItemReceivedArgs.append((arg1, arg2))
        return try  stub(arg1, arg2)
    }
    var contentsOfDirectoryStub: ((String) throws  -> [String])?
    var contentsOfDirectoryDefaultValue: [String]! 
    private (set) var contentsOfDirectoryInvocationCount = 0
    private (set) var contentsOfDirectoryReceivedArgs: [(String)] = []
    private(set) lazy var contentsOfDirectory: (String) throws  -> [String] = { arg1 in
        guard let stub = self.contentsOfDirectoryStub else {
            XCTFail("Stub not set for contentsOfDirectoryStub")
            return self.contentsOfDirectoryDefaultValue 
        }

        self.contentsOfDirectoryReceivedArgs.append((arg1))
        return try  stub(arg1)
    }
    var createFileStub: ((String, Data?)  -> Void)?
    private (set) var createFileInvocationCount = 0
    private (set) var createFileReceivedArgs: [(String, Data?)] = []
    private(set) lazy var createFile: (String, Data?)  -> Void = { arg1, arg2 in
        guard let stub = self.createFileStub else {
            XCTFail("Stub not set for createFileStub")
            return 
        }

        self.createFileReceivedArgs.append((arg1, arg2))
        return   stub(arg1, arg2)
    }
    var hiddenDirExistsStub: ((URL, URL)  -> Bool)?
    var hiddenDirExistsDefaultValue: Bool! 
    private (set) var hiddenDirExistsInvocationCount = 0
    private (set) var hiddenDirExistsReceivedArgs: [(URL, URL)] = []
    private(set) lazy var hiddenDirExists: (URL, URL)  -> Bool = { arg1, arg2 in
        guard let stub = self.hiddenDirExistsStub else {
            XCTFail("Stub not set for hiddenDirExistsStub")
            return self.hiddenDirExistsDefaultValue 
        }

        self.hiddenDirExistsReceivedArgs.append((arg1, arg2))
        return   stub(arg1, arg2)
    }
    var moveItemStub: ((URL, URL) throws  -> Void)?
    private (set) var moveItemInvocationCount = 0
    private (set) var moveItemReceivedArgs: [(URL, URL)] = []
    private(set) lazy var moveItem: (URL, URL) throws  -> Void = { arg1, arg2 in
        guard let stub = self.moveItemStub else {
            XCTFail("Stub not set for moveItemStub")
            return 
        }

        self.moveItemReceivedArgs.append((arg1, arg2))
        return try  stub(arg1, arg2)
    }
}

extension FileManagerService {
    static func mock(_ object: FileManagerServiceMock) -> Self {
        FileManagerService(fileExistsAtPath: object.fileExistsAtPath, removeItem: object.removeItem, copyItem: object.copyItem, contentsOfDirectory: object.contentsOfDirectory, createFile: object.createFile, hiddenDirExists: object.hiddenDirExists, moveItem: object.moveItem)
    }
}
final class FileReaderMock {
    var readFileStub: ((URL) throws  -> String)?
    var readFileDefaultValue: String! 
    private (set) var readFileInvocationCount = 0
    private (set) var readFileReceivedArgs: [(URL)] = []
    private(set) lazy var readFile: (URL) throws  -> String = { arg1 in
        guard let stub = self.readFileStub else {
            XCTFail("Stub not set for readFileStub")
            return self.readFileDefaultValue 
        }

        self.readFileReceivedArgs.append((arg1))
        return try  stub(arg1)
    }
}

extension FileReader {
    static func mock(_ object: FileReaderMock) -> Self {
        FileReader(readFile: object.readFile)
    }
}
final class ShellExecutorMock {
    var executeStub: ((String, URL) async throws  -> String)?
    var executeDefaultValue: String! 
    private (set) var executeInvocationCount = 0
    private (set) var executeReceivedArgs: [(String, URL)] = []
    private(set) lazy var execute: (String, URL) async throws  -> String = { arg1, arg2 in
        guard let stub = self.executeStub else {
            XCTFail("Stub not set for executeStub")
            return self.executeDefaultValue 
        }

        self.executeReceivedArgs.append((arg1, arg2))
        return try await stub(arg1, arg2)
    }
}

extension ShellExecutor {
    static func mock(_ object: ShellExecutorMock) -> Self {
        ShellExecutor(execute: object.execute)
    }
}
