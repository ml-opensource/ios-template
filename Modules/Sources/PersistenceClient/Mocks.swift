//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/01/2022.
//

import Foundation

#if !RELEASE
    extension PersistenceClient {
        public static let noop = Self(
            tokens: .noop,
            email: .noop
        )

        public static let failing = Self(
            tokens: .failing,
            email: .failing
        )

        public static let mock = Self(
            tokens: .init(load: { .mock }, save: { _ in }),
            email: .init(load: { .init(rawValue: "mock@mock.dk") }, save: { _ in })
        )
    }
#endif
