//
//  File.swift
//  
//
//  Created by Jakob Mygind on 24/01/2023.
//

import Dependencies
import Foundation

extension APIClient: TestDependencyKey {
    
    public static var testValue: APIClient {
        .failing
    }
    
    public static var previewValue: APIClient {
        .mock
    }
}

public extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
