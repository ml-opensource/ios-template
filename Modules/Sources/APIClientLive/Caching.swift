//
//  File.swift
//
//
//  Created by Jakob Mygind on 23/12/2021.
//

import APIClient
import Combine
import Foundation
import Model

extension APIClient {

    /// Wrapper type for data enriching data with the time of caching
    struct CachedObject<T, ID: Hashable>: Hashable {

        let id: ID
        let data: T
        let added: Date

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: CachedObject<T, ID>, rhs: CachedObject<T, ID>) -> Bool {
            return lhs.id == rhs.id
        }
    }

    /// Helper function to transform one field of a struct
    /// - Returns: Modified struct
    public func transform<Value>(
        at keypath: WritableKeyPath<Self, Value>, transform: (Value) -> Value
    ) -> Self {
        var copy = self
        let value = self[keyPath: keypath]
        copy[keyPath: keypath] = transform(value)
        return copy
    }
}
