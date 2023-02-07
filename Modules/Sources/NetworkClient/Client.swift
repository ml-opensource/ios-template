//
//  File.swift
//
//
//  Created by Jakob Mygind on 04/01/2022.
//

import Foundation
import Network
import XCTestDynamicOverlay

/// Client for reading whetherthe app has connectivity
public struct NetworkClient {

    public struct NetworkPath {
        public let status: NWPath.Status
    }

    public var pathUpdateStream: () -> AsyncStream<NetworkPath>
}

extension NetworkClient.NetworkPath {
    init(rawValue: NWPath) {
        self.status = rawValue.status
    }
}

#if DEBUG
extension NetworkClient {
    public static let failing = Self(
        pathUpdateStream: XCTUnimplemented("\(Self.self).pathUpdateStream method not implemented.")
    )
    
    public static let noop = Self(
        pathUpdateStream: { .init(unfolding: { .none }) }
    )
    public static let happy = Self(
        pathUpdateStream: {
            .init { continuation in
                continuation.yield(.init(status: .satisfied))
                continuation.finish()
            }
        }
    )
    public static let unhappy = Self(
        pathUpdateStream: {
            .init { continuation in
                continuation.yield(.init(status: .unsatisfied))
                continuation.finish()
            }
        }
    )

    private static var timer: Timer!
    
    public static func flakey(
        firstStatus: NWPath.Status = .unsatisfied,
        timeInterval: TimeInterval = 3
    ) -> Self {
        Self(
            pathUpdateStream: {
                AsyncStream { continuation in
                    var currentStatus = firstStatus
                    continuation.yield(.init(status: firstStatus))
                    timer = Timer(
                        timeInterval: timeInterval,
                        repeats: true
                    ) { _ in
                        currentStatus = currentStatus == .satisfied ? .unsatisfied : .satisfied
                        continuation.yield(.init(status: currentStatus))
                    }
                    continuation.onTermination = { _ in
                        timer.invalidate()
                    }
                    RunLoop.main.add(timer, forMode: .default)
                }
            }
        )
    }
}
#endif
