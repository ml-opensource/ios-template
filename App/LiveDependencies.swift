//
//  Environment.swift
//  PROJECT_NAME
//
//  Created by Jakob Mygind on 24/01/2023.
//

import APIClient
import APIClientLive
import AppVersion
import Dependencies
import Foundation
import Localizations
import Model
import NetworkClient
import NStackSDK
import PersistenceClient
import TokenHandler

extension APIClient: DependencyKey {
    public static var liveValue: APIClient {
        
        @Dependency(\.envVars) var envVars
        @Dependency(\.persistenceClient) var persistenceClient

        var continuation: AsyncStream<APITokensEnvelope?>.Continuation!
        
        let tokenValuesStream: AsyncStream<APITokensEnvelope?> = .init { cont in
            continuation = cont
        }
        let authHandler = AuthenticationHandlerAsync<APITokensEnvelope>(
            refreshURL: envVars.refreshURL,
            getTokens: persistenceClient.tokens.load,
            saveTokens: { tokens in
                persistenceClient.tokens.save(tokens)
                continuation.yield(tokens)
            }
        )
        
        return APIClient.live(
            baseURL: envVars.baseURL,
            authenticationHandler: authHandler,
            tokensUpdateStream: tokenValuesStream
        )
    }
}

extension PersistenceClient: DependencyKey {
    
    public static var liveValue: PersistenceClient {
        @Dependency(\.envVars) var envVars
        
        return .live(keyPrefix: envVars.persistenceKeyPrefix)
    }
}

extension AppVersion: DependencyKey {
    public static var liveValue: AppVersion {
        .live
    }
}

/// Handles setup of [NStack](https://nstack.io) services.
/// This example demonstrates [Localization](https://nstack-io.github.io/docs/docs/features/localize.html) service activation.
extension ObservableLocalizations: DependencyKey {
    public static var liveValue: ObservableLocalizations {
        
        @Dependency(\.envVars) var envVars
        return startNStackSDK(
            appId: envVars.nstackVars.appId,
            restAPIKey: envVars.nstackVars.restAPIKey,
            environment: envVars.nstackVars.environment
        )
    }
}

extension NetworkClient: DependencyKey {
    public static var liveValue: NetworkClient {
        .live(queue: .main)
    }
}

