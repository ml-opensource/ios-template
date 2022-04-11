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

        let subject = PassthroughSubject<NWPath, Never>()
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = subject.send(_:)

        return Self.init(
            pathUpdatePublisher:
                subject
                .handleEvents(
                    receiveSubscription: { _ in monitor.start(queue: queue) },
                    receiveCancel: monitor.cancel
                )
                .map(NetworkClient.NetworkPath.init(rawValue:))
                .eraseToAnyPublisher()
        )
    }
}
