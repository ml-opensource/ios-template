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

    public var authenticate: (Username, Password) -> AnyPublisher<APITokens, APIError>
    public var refreshToken: (RefreshToken) -> AnyPublisher<APITokens, APIError>
    public var setToken: (APITokens) -> Void
    public var setBaseURL: (URL) -> Void
    public var currentBaseURL: () -> URL

    public init(
        authenticate: @escaping (Username, Password) -> AnyPublisher<APITokens, APIError>,
        refreshToken: @escaping (RefreshToken) -> AnyPublisher<APITokens, APIError>,
        setToken: @escaping (APITokens) -> Void,
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
    public static let failing = Self(
        authenticate: { _, _ in .failing("\(Self.self).authenticate failing endpoint called") },
        refreshToken: { _ in .failing("\(Self.self).refreshToken failing endpoint called") },
        setToken: { _ in XCTFail("\(Self.self).setToken failing endpoint called") },
        setBaseURL: { _ in fatalError() },
        currentBaseURL: { fatalError() }
    )
}
