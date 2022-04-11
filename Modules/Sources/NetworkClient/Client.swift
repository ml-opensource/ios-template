//
//  File.swift
//
//
//  Created by Jakob Mygind on 04/01/2022.
//

import Combine
import Foundation
import Network
import XCTestDynamicOverlay

/// Client for reading whetherthe app has connectivity
public struct NetworkClient {

    public struct NetworkPath {
        public let status: NWPath.Status
    }

    public var pathUpdatePublisher: AnyPublisher<NetworkPath, Never>
}

extension NetworkClient.NetworkPath {
    init(rawValue: NWPath) {
        self.status = rawValue.status
    }
}

extension NetworkClient {
    public static let failing = Self.init(pathUpdatePublisher: .failing())
    public static let noop = Self.init(
        pathUpdatePublisher: Empty(completeImmediately: false).eraseToAnyPublisher())
    public static let happy = Self.init(
        pathUpdatePublisher: .init(value: .init(status: .satisfied)))
    public static let unhappy = Self.init(
        pathUpdatePublisher: .init(value: .init(status: .unsatisfied)))

    public static var flakey: Self {

        Self(
            pathUpdatePublisher: Timer.publish(
                every: 3, tolerance: nil, on: .main, in: .default, options: nil
            )
            .autoconnect()
            .scan(
                NWPath.Status.satisfied,
                { status, _ in
                    status == .satisfied ? .unsatisfied : .satisfied
                }
            )
            .map(NetworkClient.NetworkPath.init(status:))
            .eraseToAnyPublisher()
        )
    }
}

extension AnyPublisher {
    fileprivate static func failing(_ message: String = "") -> Self {
        .fireAndForget {
            XCTFail("\(message.isEmpty ? "" : "\(message) - ")A failing effect ran.")
        }
    }

    fileprivate init(value: Output) {
        self = Just(value).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }

    fileprivate init(_ error: Failure) {
        self = Fail(error: error).eraseToAnyPublisher()
    }

    fileprivate static func fireAndForget(_ work: @escaping () -> Void) -> Self {
        Deferred { () -> Empty<Output, Failure> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToAnyPublisher()
    }
}
