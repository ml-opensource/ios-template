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
    public var refreshToken: (RefreshToken)  async throws -> APITokensEnvelope
    public var setToken: (APITokensEnvelope) -> Void
    public var setBaseURL: (URL) -> Void
    public var currentBaseURL: () -> URL

    public init(
        authenticate: @escaping (Username, Password) async throws -> APITokensEnvelope,
        refreshToken: @escaping (RefreshToken)  async throws -> APITokensEnvelope,
        setToken: @escaping (APITokensEnvelope) -> Void,
        setBaseURL: @escaping (URL) -> Void,
        currentBaseURL: @escaping () -> URL
    ) {
        self.authenticate = authenticate
        self.refreshToken = refreshToken
        self.setToken = setToken
        self.setBaseURL = setBaseURL
        self.currentBaseURL = currentBaseURL

    }
}

extension APIClient {
    public static let failing = APIClient(
        authenticate: XCTUnimplemented("authenticate failing endpoint called"),
        refreshToken: XCTUnimplemented("\(Self.self).refreshToken failing endpoint called") ,
        setToken: { _ in XCTFail("\(Self.self).setToken failing endpoint called") },
        setBaseURL: { _ in fatalError() },
        currentBaseURL: { fatalError() }
    )
}
