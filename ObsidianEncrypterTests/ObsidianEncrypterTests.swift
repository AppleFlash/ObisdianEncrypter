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
        XCTAssertEqual(encryptServiceMock.decryptReceivedArgs.map(\.0.output), ["checkpass.output"])
    }
}
