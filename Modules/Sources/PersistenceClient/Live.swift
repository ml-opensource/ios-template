//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/01/2022.
//

import Foundation
import Model

extension PersistenceClient {
    public static func live(keyPrefix: String) -> Self {
        .init(
            tokens: .live(key: keyPrefix + ".savedtokenskey"),
            email: .live(key: keyPrefix + ".savedemailkey")
        )
    }
}
