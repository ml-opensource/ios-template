//
//  File.swift
//
//
//  Created by Jakob Mygind on 20/12/2021.
//

import APIClient
import AppVersion
import Combine
import CombineSchedulers
import Localizations
import Model
import NetworkClient
import PersistenceClient
import XCTestDynamicOverlay

/// All encompassing environment
public struct AppEnvironment {

    var mainQueue: AnySchedulerOf<DispatchQueue>
    var apiClient: APIClient
    var date: () -> Date
    var calendar: Calendar
    var localizations: ObservableLocalizations
    var appVersion: AppVersion
    var persistenceClient: PersistenceClient
    var tokenUpdatePublisher: AnyPublisher<APITokens?, Never>
    var networkMonitor: NetworkClient

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        apiClient: APIClient,
        date: @escaping () -> Date,
        calendar: Calendar,
        localizations: ObservableLocalizations,
        appVersion: AppVersion,
        persistenceClient: PersistenceClient,
        tokenUpdatePublisher: AnyPublisher<APITokens?, Never>,
        networkMonitor: NetworkClient
    ) {
        self.mainQueue = mainQueue
        self.apiClient = apiClient
        self.date = date
        self.calendar = calendar
        self.localizations = localizations
        self.appVersion = appVersion
        self.persistenceClient = persistenceClient
        self.tokenUpdatePublisher = tokenUpdatePublisher
        self.networkMonitor = networkMonitor
    }
}

extension AppEnvironment {

    public static let mock = Self(
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        apiClient: .mock,
        date: Date.init,
        calendar: .init(identifier: .gregorian),
        localizations: .init(.bundled),
        appVersion: .noop,
        persistenceClient: .mock,
        tokenUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher(),
        networkMonitor: .happy
    )

    #if DEBUG
        static let failing = Self(
            mainQueue: .failing,
            apiClient: .failing,
            date: {
                XCTFail("Not implemented")
                return Date()
            },
            calendar: .init(identifier: .gregorian),
            localizations: .init(.bundled),
            appVersion: .failing,
            persistenceClient: .failing,
            tokenUpdatePublisher: .failing(),
            networkMonitor: .failing
        )
    #endif
}
