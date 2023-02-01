//
//  File.swift
//  
//
//  Created by Jakob Mygind on 27/01/2023.
//

import Foundation
import TokenHandler

public struct RefreshTokenEnvelope: Codable, Equatable {
    init(token: String, expiresAt: Date) {
        self.token = token
        self.expiresAt = expiresAt
    }

    public var token: String
    public var expiresAt: Date
}

public struct APITokensEnvelope: Codable, Equatable {
    init(
        token: String,
        refreshToken: RefreshTokenEnvelope
    ) {
        self.token = token
        self.refreshToken = refreshToken
    }

    public var token: String
    public var refreshToken: RefreshTokenEnvelope
}

extension APITokensEnvelope {
    public static let mock = Self(
        token: "MockToken",
        refreshToken: .init(token: "MockRefreshToken", expiresAt: .distantFuture))
}

extension APITokensEnvelope: APITokensEnvelopeProtocol {
    public var getAccessToken: String {
        token
    }
    
    public var getRefreshToken: String {
        refreshToken.token
    }
}
