//
//  EnvVars.swift
//  PROJECT_NAME
//
//  Created by Jakob Mygind on 24/01/2023.
//

import Dependencies
import Foundation
import NStackSDK
import PersistenceClient

public struct EnvVars {
    
    public struct NStackVars {
        let appId: String
        let restAPIKey: String
        let environment: NStackSDK.Configuration.NStackEnvironment
    }
    
    var baseURL: URL
    var refreshURL: URL
    var persistenceKeyPrefix: String
    var nstackVars: NStackVars
}

extension EnvVars: DependencyKey {
#warning("Set up environment variables here")
    public static var liveValue: EnvVars {
        .init(
            baseURL: Configuration.API.baseURL,
            refreshURL: unimplemented(),
            persistenceKeyPrefix: Bundle.main.bundleIdentifier!,
            nstackVars: .init(
                appId: unimplemented(),
                restAPIKey: unimplemented(),
                environment: currentNStackEnvironment()
            )
        )
    }
    
    static func currentNStackEnvironment() -> NStackSDK.Configuration.NStackEnvironment {
    #if RELEASE
        return .production
    #elseif TEST
        return .test
    #else
        return .debug
    #endif
    }
}

extension DependencyValues {
    public var envVars: EnvVars {
       get { self[EnvVars.self] }
       set { self[EnvVars.self] = newValue }
     }
}
