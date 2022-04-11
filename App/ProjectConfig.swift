//
//  ProjectConfig.swift
//  InStoreApp
//
//  Created by Jakob Mygind on 18/01/2022.
//

import APIClient
import Foundation

public enum Configuration {

    public enum API {
        enum Key: String, CaseIterable {
            #if !RELEASE
                case dev = "API_BASE_URL_DEV"
            #endif
            case prod = "API_BASE_URL_PROD"
            static var defaultKey = "DEFAULT_BASE_URL"
        }

        #if !RELEASE
            public static var environments: [APIClient.APIEnvironment] {
                Key.allCases.map {
                    let urlString: String = try! Configuration.value(for: $0.rawValue)
                    let displayName: String = String($0.rawValue.split(separator: "_").last!)
                    return .init(
                        baseURL: URL(string: "https://" + urlString)!,
                        displayName: displayName,
                        configKey: $0.rawValue
                    )
                }
            }
        #endif

        public static var baseURL: URL {
            #if !RELEASE
                let key: String = try! Configuration.value(for: Key.defaultKey)
                let defaultKey = Key(rawValue: key)!
                return environments[defaultKey].baseURL
            #else
                let urlString: String = try! Configuration.value(for: Key.prod.rawValue)
                return URL(string: "https://" + urlString)!
            #endif
        }
    }
}

// - MARK: Reading values from info.plist -

extension Array where Element == APIClient.APIEnvironment {
    subscript(_ key: Configuration.API.Key) -> APIClient.APIEnvironment {
        first(where: { $0.configKey == key.rawValue })!
    }
}

extension Array: LosslessStringConvertible where Element: LosslessStringConvertible {
    public init?(_ description: String) {
        let splits = description.split(separator: " ").map(String.init)
        guard !splits.isEmpty else { return nil }
        self = splits.compactMap(Element.init)
    }
}


extension Configuration {
    enum Error: Swift.Error {
        case missingKey(String)
        case invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey(key)
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }

}
