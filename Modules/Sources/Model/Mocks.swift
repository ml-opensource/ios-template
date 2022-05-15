//
//  File.swift
//
//
//  Created by Jakob Mygind on 19/11/2021.
//

import Combine
import Foundation
import StoreKit
import XCTestDynamicOverlay

// MARK: - Here are mocked versions of the domain models
extension Product {

    public static let mock = Self(
        id: 1,
        name: "MockCroissant",
        description: "MockCroissant something description",
        price: 123.0,
        netContentValue: "90",
        netContentMeasurementUnitCode: "GR",
        thumbnailImageUrls: [
            URL(
                string:
                    "https://live.nemligstatic.com/scommerce/images/croissant.jpg?i=CJRwsn-w/5045129&w=623&h=623&mode=pad"
            )!
        ],
        standardImageUrls: [
            URL(
                string:
                    "https://live.nemligstatic.com/scommerce/images/croissant.jpg?i=CJRwsn-w/5045129&w=623&h=623&mode=pad"
            )!
        ]
    )

    public static func mocks(amount: Int) -> [Product] {
        var products: [Product] = []
        for index in 0..<amount {
            products.append(
                .init(
                    id: .init(rawValue: index),
                    name: "MockCroissant",
                    description: "MockCroissant something description",
                    price: Double.random(in: 61.5...615),
                    netContentValue: "90",
                    netContentMeasurementUnitCode: "GR",
                    thumbnailImageUrls: [
                        URL(
                            string:
                                "https://live.nemligstatic.com/scommerce/images/croissant.jpg?i=CJRwsn-w/5045129&w=623&h=623&mode=pad"
                        )!
                    ],
                    standardImageUrls: [
                        URL(
                            string:
                                "https://live.nemligstatic.com/scommerce/images/croissant.jpg?i=CJRwsn-w/5045129&w=623&h=623&mode=pad"
                        )!
                    ]
                )
            )
        }
        return products
    }
}

extension Array where Element == Product {
    public static func mocks(_ count: Int) -> Self {
        guard count > 0 else { return [] }
        return (1...count).map { n in

            var mock = Product.mock
            mock.id = .init(rawValue: n)
            mock.name = "Croissant \(n)"

            return mock
        }
    }
}

extension Array where Element == LineItem {
    public static func mocks(_ count: Int) -> Self {
        guard count > 0 else { return [] }
        return (1...count).map { n in

            var mock = Product.mock
            mock.id = .init(rawValue: n)
            mock.name = "Croissant \(n)"

            return LineItem(product: mock, quantity: n)
        }
    }
}

extension Order {
    public static let mock = Self(
        id: 1234,
        deliveryDate: Date()
    )

    public static func testMock(date: Date) -> Self {
        var mock = self.mock
        mock.deliveryDate = date
        return mock
    }
}

extension Array where Element == Order {
    public static func mocks(_ count: Int) -> Self {
        guard count > 0 else { return [] }
        return (1...count).map { n in

            var mock = Order.mock
            mock.deliveryDate += Double(n - 1) * 86400
            return mock
        }
    }
}

/// Used for convenience in mocking and testing
extension AnyPublisher {
    public static func failing(_ message: String = "") -> Self {
        .fireAndForget {
            XCTFail("\(message.isEmpty ? "" : "\(message) - ")A failing effect ran.")
        }
    }

    public init(value: Output) {
        self = Just(value).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }

    public init(_ error: Failure) {
        self = Fail(error: error).eraseToAnyPublisher()
    }

    public static func fireAndForget(_ work: @escaping () -> Void) -> Self {
        Deferred { () -> Empty<Output, Failure> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToAnyPublisher()
    }
}
