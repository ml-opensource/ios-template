//
//  File.swift
//  
//
//  Created by Nicolai Harbo on 20/04/2022.
//

import APIClient
import AppVersion
import CombineSchedulers
import Localizations

public struct LoginEnvironment {

    var mainQueue: AnySchedulerOf<DispatchQueue>
    var apiClient: APIClient
    var date: () -> Date
    var calendar: Calendar
    var localizations: ObservableLocalizations
    var appVersion: AppVersion

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        apiClient: APIClient,
        date: @escaping () -> Date,
        calendar: Calendar,
        localizations: ObservableLocalizations,
        appVersion: AppVersion
    ) {
        self.mainQueue = mainQueue
        self.apiClient = apiClient
        self.date = date
        self.calendar = calendar
        self.localizations = localizations
        self.appVersion = appVersion
    }
}
