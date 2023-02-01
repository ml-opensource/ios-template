//
//  File.swift
//  
//
//  Created by Jakob Mygind on 30/01/2023.
//

import Dependencies
import Foundation

extension ObservableLocalizations: TestDependencyKey {
    public static var testValue: ObservableLocalizations {
        .bundled
    }
}

public extension DependencyValues {
    var localizations: ObservableLocalizations {
        get { self[ObservableLocalizations.self] }
        set { self[ObservableLocalizations.self] = newValue }
    }
}
