//
//  File.swift
//
//
//  Created by Jakob Mygind on 02/12/2021.
//

import Combine
import Foundation
import Model

extension APIClient {
    public static let mock = Self(
        authenticate: { _, _ in .mock },
        refreshToken: { _ in .mock },
        setToken: { _ in },
        setBaseURL: { _ in },
        currentBaseURL: { URL.init(string: ":")! }
    )
}
