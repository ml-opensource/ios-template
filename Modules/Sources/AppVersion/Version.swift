//
//  File.swift
//
//
//  Created by Jakob Mygind on 10/12/2021.
//

import Foundation

/// Testable client providing info about Build and App version
public struct AppVersion {
    public var version: () -> String
    public var build: () -> String

    public init(
        version: @escaping () -> String,
        build: @escaping () -> String
    ) {
        self.version = version
        self.build = build
    }

    public static let live = Self(
        version: { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" },
        build: { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "" }
    )

    public static let mock = Self(
        version: { "1.2.3" },
        build: { "4" }
    )
    
    public static let noop = Self(
        version: { "0.0.0" },
        build: { "0" }
    )
}


import XCTestDynamicOverlay

extension AppVersion {
    public static let failing = Self(
        version: {
            XCTFail("\(Self.self).version is unimplemented")
            return ""
        },
        build: {
            XCTFail("\(Self.self).build is unimplemented")
            return ""
        }
    )
}
