//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/01/2022.
//

import Foundation
import Model

/// Client used for storing data
public struct PersistenceClient {
    public var tokens: FileClient<APITokensEnvelope>
    public var email: FileClient<Username>
}
