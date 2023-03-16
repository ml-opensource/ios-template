//
//  File.swift
//
//
//  Created by Jakob Mygind on 10/12/2021.
//

import Combine
import Dependencies
import LoginFeature
import MainFeature
import Model
import PersistenceClient
import SwiftUI

public class AppViewModel: ObservableObject {

    public enum Destination {
        case login(LoginViewModel)
        case main(MainViewModel)
    }
    @Published var destination: Destination?
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.date) var date

    enum BannerState {
        case offline(String)
        case serverError(String)
    }

    @Published var bannerState: BannerState?

    public init(
        destination: AppViewModel.Destination? = nil
    ) {
        self.destination = destination
        
        Task {
            for await token in apiClient.tokensUpdateStream() {
                if token == nil {
                    showLogin()
                }
            }
        }
    }
    
    func onAppear() {
        if
            let tokens = persistenceClient.tokens.load(),
            tokens.refreshToken.expiresAt > date() {
            showMain()
        } else {
            showLogin()
        }
        
    }

    func showLogin() {
        destination = .login(
            .init(
                onSuccess: { [unowned self] in
                    persistenceClient.tokens.save($0)
                    persistenceClient.email.save($1)
                    withAnimation {
                        showMain()
                    }
                }
            )
        )
    }
    
    func showMain() {
        destination = .main(
            // Using witghdependencies(from: self) here makes sure that if you have overridden dependencies e.g. for using a mock endpoint, the children use the mocked endpoint and not the liev one
            withDependencies(from: self, operation: MainViewModel.init)
        )
    }
}
