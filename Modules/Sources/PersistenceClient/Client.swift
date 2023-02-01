//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/01/2022.
//

import Dependencies
import Foundation
import Model

/// Client used for storing data
public struct PersistenceClient {
    public var tokens: FileClient<APITokensEnvelope>
    public var email: FileClient<Username>
}

extension PersistenceClient: TestDependencyKey {
    public static var testValue: Self {
        .failing
    }
}

public extension DependencyValues {
  var persistenceClient: PersistenceClient {
    get { self[PersistenceClient.self] }
    set { self[PersistenceClient.self] = newValue }
  }
}
