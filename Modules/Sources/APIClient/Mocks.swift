//
//  File.swift
//
//
//  Created by Jakob Mygind on 02/12/2021.
//

import Combine
import Foundation
import Model

private var orders = {
    [Order].mocks(12).map { order -> Order in
        var order = order
        return order
    }
}()

extension APIClient {
    public static let mock = Self(
        authenticate: { _, _ in .init(value: .mock) },
        refreshToken: { _ in .init(value: .mock) },
        setToken: { _ in },
        setBaseURL: { _ in },
        currentBaseURL: { URL.init(string: ":")! }
    )

    public static let functionalMock = Self(
        authenticate: { _, _ in
            .init(value: .mock)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main, options: nil)
                .eraseToAnyPublisher()
        },
        refreshToken: { _ in .init(value: .mock) },
        setToken: { _ in },
        setBaseURL: { _ in },
        currentBaseURL: { URL.init(string: ":")! }
    )
}
