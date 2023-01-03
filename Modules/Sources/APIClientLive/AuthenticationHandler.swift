//
//  File.swift
//
//
//  Created by Jakob Mygind on 15/12/2021.
//

import Combine
import Foundation
import Model

/// This class is used to authenticate all requests, and if needed refresh the tokens
/// The state of tokens can be monitored by subscribing to `tokenUpdatePublisher`, if this outouts nil, it means the user should log in again
public class AuthenticationHandler {

    public let tokenUpdatePublisher: CurrentValueSubject<APITokensEnvelope?, Never>
    var now: () -> Date = Date.init
    var networkRequestPublisher:
        (URLRequest) -> AnyPublisher<
            URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure
        > = {
            URLSession.shared.dataTaskPublisher(for: $0).eraseToAnyPublisher()
        }
    private let queue = DispatchQueue(label: "Authenticator.\(UUID().uuidString)")
    private(set) var refreshPublisher: PassthroughSubject<APITokensEnvelope, Error>?

    private var refreshURL: URL
    var apiTokens: APITokensEnvelope? {
        didSet {
            if let apiTokens = apiTokens {
                refreshPublisher?.send(apiTokens)
            } else {
                refreshPublisher?.send(completion: .finished)
            }
            tokenUpdatePublisher.send(apiTokens)
        }
    }

    public init(
        refreshURL: URL,
        tokens: APITokensEnvelope?
    ) {
        self.apiTokens = tokens
        self.tokenUpdatePublisher = CurrentValueSubject(tokens)
        self.refreshURL = refreshURL
    }

    #if DEBUG
        init(

            now: @escaping () -> Date = Date.init,
            networkRequestPublisher: @escaping (URLRequest) -> AnyPublisher<
                URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure
            > = {
                URLSession.shared.dataTaskPublisher(for: $0).eraseToAnyPublisher()
            },
            refreshPublisher: PassthroughSubject<APITokensEnvelope, Error>? = nil,
            refreshURL: URL,
            apiTokens: APITokensEnvelope? = nil
        ) {
            self.tokenUpdatePublisher = CurrentValueSubject(apiTokens)
            self.now = now
            self.networkRequestPublisher = networkRequestPublisher
            self.refreshPublisher = refreshPublisher
            self.refreshURL = refreshURL
            self.apiTokens = apiTokens
        }

    #endif

    /// Authenticates URLRequests
    /// - Parameter request: Requests to be authenticated
    /// - Returns: The result of the request
    public func authenticateRequest(_ request: URLRequest) -> AnyPublisher<
        URLSession.DataTaskPublisher.Output, Error
    > {
        return queue.sync {

            guard let apiTokens = apiTokens else {
                return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
            }

            if let tokenSubject = refreshPublisher {
                return
                    tokenSubject
                    .flatMap { [unowned self] in
                        makeAuthenticatedRequest(request, accessToken: $0.token)
                    }.eraseToAnyPublisher()
            }

            if !apiTokens.token.isValid(now: now()) {
                self.refreshPublisher = .init()
                return self.refreshTokens(using: apiTokens.refreshToken.token)
                    .handleEvents(
                        receiveOutput: { self.apiTokens = $0 },
                        receiveCompletion: { _ in
                            self.refreshPublisher = nil
                        }
                    )
                    .map(\.token)
                    .flatMap { [unowned self] in makeAuthenticatedRequest(request, accessToken: $0)
                    }
                    .tryCatch {
                        [unowned self] (error: Error) throws -> AnyPublisher<
                            URLSession.DataTaskPublisher.Output, Error
                        > in
                        if let urlError = error as? URLError,
                            urlError == URLError(.userAuthenticationRequired)
                        {
                            self.apiTokens = nil
                            return Empty(completeImmediately: true).eraseToAnyPublisher()
                        } else {
                            throw error
                        }
                    }
                    .eraseToAnyPublisher()
            }

            return makeAuthenticatedRequest(request, accessToken: apiTokens.token)
        }
    }

    /// Adds access token to request
    /// throws auth error if provided token should be invalid
    private func makeAuthenticatedRequest(
        _ request: URLRequest,
        accessToken: AccessToken
    ) -> AnyPublisher<URLSession.DataTaskPublisher.Output, Error> {
        var request = request
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return networkRequestPublisher(request)
            .tryMap {
                if let code = ($0.1 as? HTTPURLResponse)?.statusCode,
                    code == 401
                {
                    throw URLError(.userAuthenticationRequired)
                } else {
                    return $0
                }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// Make call to refresh access token
    /// - Parameter refreshToken: refreshtoken to be used
    /// - Returns: A fresh set of tokens
    private func refreshTokens(using refreshToken: RefreshToken) -> AnyPublisher<APITokensEnvelope, Error> {
        struct Body: Encodable {
            let token: String
        }

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)

        return makePostRequest(url: refreshURL, requestBody: Body(token: refreshToken.rawValue))
            .publisher
            .flatMap(networkRequestPublisher)
            .tryMap {
                if let code = ($0.1 as? HTTPURLResponse)?.statusCode,
                    code == 401
                {
                    throw URLError(.userAuthenticationRequired)
                } else {
                    return $0.data
                }
            }
            .decode(type: APITokensEnvelope.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

#if !RELEASE
    extension AccessToken {
        /// A token with expiry some time in December afair
        public static let expired = AccessToken(
            rawValue:
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMyIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjoxNjM5NTg0OTUyLCJleHAiOjE2Mzk1ODYxNTIsImlhdCI6MTYzOTU4NDk1Mn0.X2w58Hk8Wtct3-PHYqPLGmCsUgrPuLcp9-hw98E4ZCM"
        )
    }
#endif
