//
//  File.swift
//  
//
//  Created by Jakob Mygind on 14/11/2022.
//

import Foundation
import Model

/// This class is used to authenticate all requests, and if needed refresh the tokens
/// The state of tokens can be monitored by subscribing to `tokenUpdatePublisher`, if this outouts nil, it means the user should log in again
public actor AuthenticationHandlerAsync {
    
    var apiTokens: APITokensEnvelope? {
        get { getTokens() }
        set { saveTokens(newValue) }
    }
    
    var refreshTask: Task<APITokensEnvelope, Error>?
    var networkRequest:
    (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data(for: )
    var now: () -> Date = Date.init
    
    private var refreshURL: URL
    
    let getTokens: () -> APITokensEnvelope?
    let saveTokens: (APITokensEnvelope?) -> Void
    
    public init(
        refreshURL: URL,
        getTokens: @escaping () -> APITokensEnvelope?,
        saveTokens: @escaping (APITokensEnvelope?) -> Void,
        now: @escaping () -> Date = Date.init,
        networkRequest: @escaping (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data(for: )
    ) {
        self.refreshURL = refreshURL
        self.getTokens = getTokens
        self.saveTokens = saveTokens
        self.now = now
        self.networkRequest = networkRequest
    }
    
    func validTokens() async throws -> APITokensEnvelope {
        if let handle = refreshTask {
            return try await handle.value
        }
        
        guard let apiTokens else {
            throw URLError(.userAuthenticationRequired)
        }
        
        if apiTokens.token.isValid(now: now()) {
            return apiTokens
        }
        
        return try await refreshedTokens()
    }
    
    func refreshedTokens() async throws -> APITokensEnvelope {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        let task = Task { () throws -> APITokensEnvelope in
            defer { self.refreshTask = nil }
            
            guard let refreshToken = apiTokens?.refreshToken else {
                throw URLError(.userAuthenticationRequired)
            }
            let newTokens = try await AuthenticationHandlerAsync.refreshTokens(using: refreshToken.token, refreshURL: refreshURL, networkRequest: networkRequest)
            apiTokens = newTokens
            
            return newTokens
        }
        
        self.refreshTask = task
        
        return try await task.value
    }
    
    /// Make call to refresh access token
    /// - Parameter refreshToken: refreshtoken to be used
    /// - Returns: A fresh set of tokens
    private static func refreshTokens(
        using refreshToken: RefreshToken,
        refreshURL: URL,
        networkRequest: (URLRequest) async throws -> (Data, URLResponse)
    ) async throws -> APITokensEnvelope {
        struct Body: Encodable {
            let token: String
        }
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(Body(token: refreshToken.rawValue))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let response = try await networkRequest(request)
        print("✈️ResponseData: \(String(data: response.0, encoding: .utf8)!)")
        if let code = (response.1 as? HTTPURLResponse)?.statusCode,
           code == 401 {
            throw URLError(.userAuthenticationRequired)
        }
        
        return try decoder.decode(APITokensEnvelope.self, from: response.0)
    }
    
    /// Authenticates URLRequests
    /// - Parameter request: Requests to be authenticated
    /// - Returns: The result of the request
    public func performAuthenticatedRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        
        do {
            let tokens = try await validTokens()
            
            do {
                let response = try await performAuthenticatedRequest(request, accessToken: tokens.token)
                if
                    let code = (response.1 as? HTTPURLResponse)?.statusCode,
                    code == 401 {
                    throw URLError(.userAuthenticationRequired)
                }
                return response
            } catch let error as URLError where error.code == .userAuthenticationRequired {
                let freshTokens = try await refreshedTokens()
                let response = try await performAuthenticatedRequest(request, accessToken: freshTokens.token)
                return response
            }
        } catch {
            apiTokens = nil
            throw error
        }
    }
    
    /// Adds access token to request
    /// throws auth error if provided token should be invalid
    private func performAuthenticatedRequest(
        _ request: URLRequest,
        accessToken: AccessToken
    ) async throws -> (Data, URLResponse) {
        var request = request
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return try await networkRequest(request)
    }
}
