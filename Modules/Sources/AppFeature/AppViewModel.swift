//
//  File.swift
//
//
//  Created by Jakob Mygind on 10/12/2021.
//

import APIClient
import AppVersion
import Combine
import CombineSchedulers
import Foundation
import Localizations
import Login
import Model
import NetworkClient
import PersistenceClient
import SwiftUI
import UIKit

public class AppViewModel: ObservableObject {

    var environment: AppEnvironment
    var cancellables: Set<AnyCancellable> = []

    public enum Route {
        case login(LoginViewModel)
        case main(MainViewModel)
    }
    @Published var route: Route?

    enum BannerState {
        case offline(String)
        case serverError(String)
    }

    @Published var bannerState: BannerState?

    public init(
        environment: AppEnvironment,
        route: AppViewModel.Route? = nil
    ) {
        self.environment = environment
        self.route = route
        environment.tokenUpdatePublisher
            .dropFirst()
            .filter { $0 == nil }
            .removeDuplicates()
            .sink { [unowned self] _ in
                showLogin()
            }
            .store(in: &cancellables)

       
    }
    
    func onAppear() {
        if
            let tokens = environment.persistenceClient.tokens.load(),
            tokens.refreshToken.expiresAt > environment.date() {
            showMain()
        } else {
            showLogin()
        }
        
    }

    func showLogin() {
        route = .login(
            .init(
                onSuccess: { [unowned self] in
                    environment.persistenceClient.tokens.save($0)
                    environment.apiClient.setToken($0)
                    environment.persistenceClient.email.save($1)
                    withAnimation {
                        showMain()
                    }
                },
                environment: LoginEnvironment(
                    mainQueue: environment.mainQueue,
                    apiClient: environment.apiClient,
                    date: environment.date,
                    calendar: environment.calendar,
                    localizations: environment.localizations,
                    appVersion: environment.appVersion
                )))
    }
    
    func showMain() {
        route = .main(
            .init(environment: .init(mainQueue: environment.mainQueue))
        )
    }
}

#warning("Just for demo purposes, this would live in a feature module with the MainView and such")
public class MainViewModel: ObservableObject {
    public struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }
    let environment: Environment
    public init(environment: Environment) {
        self.environment = environment
    }
}
