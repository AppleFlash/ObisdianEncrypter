//
//  ObsidianEncrypterTests.swift
//  ObsidianEncrypterTests
//
//  Created by Sedinkin on 02.02.2024.
//

import XCTest
@testable import ObsidianEncrypter

final class CheckpassServiceTests: XCTestCase {
    let fileManagerMock = FileManagerServiceMock()
    let encryptServiceMock = EncryptServiceMock()
    let shellExecutorMock = ShellExecutorMock()
    let fileReaderMock = FileReaderMock()
    lazy var deps = CheckpassService.CheckPassfile.Dependencies(
        fileManager: .mock(fileManagerMock),
        encryptService: .mock(encryptServiceMock),
        shellExecutor: .mock(shellExecutorMock),
        fileReader: .mock(fileReaderMock)
    )

    func test_whenNoCheckpassFile_thenStatusFileNotExist() async throws {
        let sut = CheckpassService.defaultService()
        let testURL = try XCTUnwrap(URL(string: "test.com"))
        let testPass = "password"
        let payload = CheckpassService.CheckPassfile.Payload(repo: testURL, pass: testPass)
        fileManagerMock.contentsOfDirectoryStub = { _ in ["test.txt"] }

        let status = try await sut.checkPassfile(payload, deps)

        XCTAssertEqual(status, .fileNotExist)
    }

    func test_whenCheckpassFileExistButWrongPas_thenStatusNotMatch() async throws {
        let sut = CheckpassService.defaultService()
        let testURL = try XCTUnwrap(URL(string: "test.com"))
        let testPass = "password"
        let payload = CheckpassService.CheckPassfile.Payload(repo: testURL, pass: testPass)
        fileManagerMock.contentsOfDirectoryStub = { _ in ["test\(CheckpassService.Constants.encSuffix)"] }
        fileManagerMock.removeItemStub = { _ in () }
        encryptServiceMock.decryptStub = { _, _ in () }
        fileReaderMock.readFileStub = { _ in "wrong text" }

        let status = try await sut.checkPassfile(payload, deps)

        XCTAssertEqual(status, .notMatch)
        XCTAssertEqual(encryptServiceMock.decryptReceivedArgs[0].0.output, "checkpass.output")
    }
}

final class CheckpassServiceTests2: XCTestCase {
    func test_whenNoCheckpassFile_thenStatusFileNotExist() async throws {
        let sut = CheckpassService.defaultService()
        let testURL = try XCTUnwrap(URL(string: "test.com"))
        let testPass = "password"
        let payload = CheckpassService.CheckPassfile.Payload(repo: testURL, pass: testPass)
        let deps = CheckpassService.CheckPassfile.Dependencies(
            fileManager: FileManagerService(
                fileExistsAtPath: { _ in fatalError() },
                removeItem: { _ in fatalError() },
                copyItem: { _, _ in fatalError() },
                contentsOfDirectory: { _ in ["test.txt"] },
                createFile: { _, _ in fatalError() },
                hiddenDirExists: { _, _ in fatalError() },
                moveItem: { _, _ in fatalError() }
            ),
            encryptService: EncryptService(
                encryptAll: { _, _ in fatalError() },
                encrypt: { _, _ in fatalError() },
                decrypt: { _, _ in fatalError() }
            ),
            shellExecutor: ShellExecutor(execute: { _, _ in fatalError() }),
            fileReader: FileReader(readFile: { _ in fatalError() })
        )

        let status = try await sut.checkPassfile(payload, deps)

        XCTAssertEqual(status, .fileNotExist)
    }

    func test_whenCheckpassFileExistButWrongPas_thenStatusNotMatch() async throws {
        let sut = CheckpassService.defaultService()
        let testURL = try XCTUnwrap(URL(string: "test.com"))
        let testPass = "password"
        let payload = CheckpassService.CheckPassfile.Payload(repo: testURL, pass: testPass)

        var receivedOutput: String?

        let deps = CheckpassService.CheckPassfile.Dependencies(
            fileManager: FileManagerService(
                fileExistsAtPath: { _ in fatalError() },
                removeItem: { _ in () },
                copyItem: { _, _ in fatalError() },
                contentsOfDirectory: { _ in ["test\(CheckpassService.Constants.encSuffix)"] },
                createFile: { _, _ in fatalError() },
                hiddenDirExists: { _, _ in fatalError() },
                moveItem: { _, _ in fatalError() }
            ),
            encryptService: EncryptService(
                encryptAll: { _, _ in fatalError() },
                encrypt: { _, _ in fatalError() },
                decrypt: { payloadArg, _ in
                    receivedOutput = payloadArg.output
                    return ()
                }
            ),
            shellExecutor: ShellExecutor(execute: { _, _ in fatalError() }),
            fileReader: FileReader(readFile: { _ in "wrong text" })
        )

        let status = try await sut.checkPassfile(payload, deps)

        XCTAssertEqual(status, .notMatch)
        XCTAssertEqual(receivedOutput, "checkpass.output")
    }
}
