//
//  Try+ErrorHandler.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 04.02.2024.
//

import Foundation

@discardableResult
func catchError<T>(_ closure: () throws -> T) -> T {
    do {
        return try closure()
    } catch {
        fatalError("Error occured: \(error)")
    }
}

func catchError(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        fatalError("Error occured: \(error)")
    }
}

