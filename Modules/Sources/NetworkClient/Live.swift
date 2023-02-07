//
//  File.swift
//
//
//  Created by Jakob Mygind on 04/01/2022.
//

import Combine
import Foundation
import Network

extension NetworkClient {
    public static func live(queue: DispatchQueue) -> Self {

        let monitor = NWPathMonitor()

        return Self(
            pathUpdateStream: {
                AsyncStream { continuation in
                    monitor.start(queue: queue)
                    monitor.pathUpdateHandler = { path in
                        continuation.yield(.init(rawValue: path))
                    }
                    continuation.onTermination = { _ in
                        monitor.cancel()
                    }
                }
            }
        )
    }
}
