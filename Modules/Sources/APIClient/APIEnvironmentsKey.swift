//
//  File.swift
//
//
//  Created by Jakob Mygind on 18/01/2022.
//

import Foundation
import SwiftUI

extension APIClient {
    public struct APIEnvironment: Hashable, Identifiable {
        public var id: String {
            configKey
        }

        public init(
            baseURL: URL,
            displayName: String,
            configKey: String
        ) {
            self.baseURL = baseURL
            self.displayName = displayName
            self.configKey = configKey
        }

        public var baseURL: URL
        public var displayName: String
        public var configKey: String
    }
}

private struct APIEnvironmentsKey: EnvironmentKey {
    static let defaultValue: [APIClient.APIEnvironment] = []
}

extension EnvironmentValues {
    public var apiEnvironments: [APIClient.APIEnvironment] {
        get { self[APIEnvironmentsKey.self] }
        set { self[APIEnvironmentsKey.self] = newValue }
    }
}

extension View {
    public func apiEnvironments(_ apiEnvironments: [APIClient.APIEnvironment]) -> some View {
        environment(\.apiEnvironments, apiEnvironments)
    }
}
