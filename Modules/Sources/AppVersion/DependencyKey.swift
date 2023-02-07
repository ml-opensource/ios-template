//
//  File.swift
//  
//
//  Created by Jakob Mygind on 01/02/2023.
//

import Dependencies
import Foundation

extension AppVersion: TestDependencyKey {
    public static var testValue: AppVersion {
        .failing
    }
    
    public static var previewValue: AppVersion {
        .mock
    }
}

extension DependencyValues {
    public var appVersion: AppVersion {
        get { self[AppVersion.self] }
        set { self[AppVersion.self] = newValue }
    }
}
