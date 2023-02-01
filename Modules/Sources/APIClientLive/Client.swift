//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/12/2021.
//

import APIClient
import Combine
import Foundation
import Model
import TokenHandler
import XCTestDynamicOverlay

extension APIClient {

    /// APIClient that hits the network
    /// - Parameters:
    ///   - url: base url to be used
    ///   - authenticationHandler: AuthenticationHandler type
    /// - Returns: Live APIclient
    public static func live<APITokensEnvelope: APITokensEnvelopeProtocol>(
        baseURL url: URL,
        authenticationHandler: AuthenticationHandlerAsync<APITokensEnvelope>,
        tokensUpdateStream: AsyncStream<Model.APITokensEnvelope?>
    ) -> Self {
        var baseURL = url
        let tokensUpdateStream = tokensUpdateStream
        return Self(
            authenticate: unimplemented(),
            setBaseURL: { baseURL = $0 },
            currentBaseURL: { baseURL },
            tokensUpdateStream: tokensUpdateStream
        )
    }
}
