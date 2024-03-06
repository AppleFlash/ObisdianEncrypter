//
//  Assembly.swift
//  ObsidianEncrypter
//
//  Created by Sedinkin on 03.03.2024.
//

import Foundation

final class DIContext {
    enum Strategy {
        case unique
        case signleton
    }

    static let shared = DIContext()

    fileprivate var singletones: [String: Any] = [:]
    fileprivate var assemblies: [String: Assembly] = [:]

    func assembly<T: Assembly>() -> T {
        let key = getKey(for: T.self)
        if let assembly = assemblies[key] {
            return assembly as! T
        } else {
            let assembly = T.newInstance(context: self)
            assemblies[key] = assembly
            return assembly
        }
    }
}

class Assembly {
    let context: DIContext

    required init(context: DIContext = .shared) {
        self.context = context
    }

    static func create(_ context: DIContext = .shared) -> Self {
        context.assembly()
    }

    fileprivate static func newInstance(context: DIContext) -> Self {
        Self(context: context)
    }

    func define<T>(_ scope: DIContext.Strategy, object: @autoclosure () -> T) -> T {
        define(scope, initClosure: object)
    }

    func define<T>(_ scope: DIContext.Strategy, initClosure: () -> T) -> T {
        switch scope {
        case .unique:
            return initClosure()
        case .signleton:
            let key = getKey(for: T.self)
            if let object = context.singletones[key] {
                guard let typedObject = object as? T else {
                    fatalError()
                }

                return typedObject
            } else {
                let object = initClosure()
                context.singletones[key] = object
                return object
            }
        }
    }
}

private func getKey<T>(for type: T.Type) -> String {
    String(reflecting: type)
}
