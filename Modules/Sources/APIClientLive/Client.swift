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

extension APIClient {

    /// APIClient that hits the network
    /// - Parameters:
    ///   - url: base url to be used
    ///   - authenticationHandler: AuthenticationHandler type
    /// - Returns: Live APIclient
    public static func live(
        baseURL url: URL,
        authenticationHandler: AuthenticationHandler
    ) -> Self {
        var baseURL = url

        return Self(
            authenticate: { username, password in
                fatalError()
//                struct Body: Encodable {
//                    let username: String
//                    let password: String
//                }
//
//                let decoder = JSONDecoder()
//                let formatter = DateFormatter()
//                formatter.locale = Locale(identifier: "en_US_POSIX")
//                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
//                decoder.dateDecodingStrategy = .formatted(formatter)
//
//                return makePostRequest(
//                    url: baseURL.appendingPathComponent("authenticate"),
//                    requestBody: Body(username: username.rawValue, password: password.rawValue)
//                )
//                .publisher
//                .flatMap(URLSession.shared.dataTaskPublisher(for:))
//                .apiDecode(as: APITokens.self, jsonDecoder: decoder)
//                .eraseToAnyPublisher()
            },
            refreshToken: { _ in fatalError("Manually refreshing should not be necessary") },
            setToken: {
                authenticationHandler.apiTokens = $0
            },
            setBaseURL: { baseURL = $0 },
            currentBaseURL: { baseURL }
        )
    }
}
