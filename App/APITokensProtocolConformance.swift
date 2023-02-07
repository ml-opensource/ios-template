//
//  APITokensProtocolConformance.swift
//  PROJECT_NAME
//
//  Created by Jakob Mygind on 30/01/2023.
//

import MLTokenHandler
import Model
import Foundation

extension APITokensEnvelope: APITokensEnvelopeProtocol {
    public var getAccessToken: String {
        token.rawValue
    }

    public var getRefreshToken: String {
        refreshToken.token.rawValue
    }
}
