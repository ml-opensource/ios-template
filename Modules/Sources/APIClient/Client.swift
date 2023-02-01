//
//  File.swift
//
//
//  Created by Jakob Mygind on 18/11/2021.
//

import Combine
import Foundation
import Model
import XCTestDynamicOverlay

/// Interface for all network calls
public struct APIClient {

    public var authenticate: (Username, Password) async throws -> APITokensEnvelope
    public var setBaseURL: (URL) -> Void
    public var currentBaseURL: () -> URL
    public var tokensUpdateStream: AsyncStream<APITokensEnvelope?>

    public init(
        authenticate: @escaping (Username, Password) async throws -> APITokensEnvelope,
        setBaseURL: @escaping (URL) -> Void,
        currentBaseURL: @escaping () -> URL,
        tokensUpdateStream: AsyncStream<APITokensEnvelope?>
    ) {
        self.authenticate = authenticate
        self.setBaseURL = setBaseURL
        self.currentBaseURL = currentBaseURL
        self.tokensUpdateStream = tokensUpdateStream

    }
}

extension APIClient {
    public static let failing = APIClient(
        authenticate: unimplemented("authenticate failing endpoint called"),
        setBaseURL: unimplemented("setBaseURL"),
        currentBaseURL: unimplemented("currentBaseURL"),
        tokensUpdateStream: unimplemented("tokensUpdateStream")
    )
}
