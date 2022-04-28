//
//  File.swift
//  
//
//  Created by Nicolai Harbo on 20/04/2022.
//

import APIClient
import AppVersion
import Combine
import CombineSchedulers
import Localizations
import Model
import Style
import SwiftUI
import SwiftUINavigation

public class LoginViewModel: ObservableObject {

    var environment: LoginEnvironment
    var onSuccess: (APITokens, Username) -> Void

    enum Route {
        case alert(AlertState)
    }
    @Published var route: Route?

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var appVersion: String = ""
    @Published var isAPICallInFlight = false

    var loginCancellable: AnyCancellable?
    var cancellables: Set<AnyCancellable> = []

    public init(
        onSuccess: @escaping (APITokens, Username) -> Void,
        environment: LoginEnvironment
    ) {
        self.environment = environment
        self.onSuccess = onSuccess
        appVersion = "\(environment.appVersion.version())(\(environment.appVersion.build()))"
    }

    /// Simple heuristics for email pattern
    var isButtonEnabled: Bool {
        email.contains("@") && email.contains(".") && email.count >= 6
            && !password.isEmpty && !isAPICallInFlight
    }

    func loginButtonTapped() {
        isAPICallInFlight = true
        loginCancellable = environment.apiClient.authenticate(
            Username(rawValue: email.trimmingCharacters(in: .whitespacesAndNewlines)),
            Password(rawValue: password.trimmingCharacters(in: .whitespacesAndNewlines))
        )
        .receive(on: environment.mainQueue, options: nil)
        .sink(
            receiveCompletion: { [weak self, environment] in
                if case .failure(let error) = $0 {
                    self?.route = .alert(
                        .withTitleAndMessage(
                            title: environment.localizations.error.errorTitle,
                            message: error.errorCode == "401"
                                ? environment.localizations.login.errorInvalidCredentials
                                : environment.localizations.error.serverError,
                            action1: .primary(
                                title: environment.localizations.defaultSection.ok.uppercased(),
                                action: { self?.route = nil })
                        )
                    )
                }
                self?.isAPICallInFlight = false
            },
            receiveValue: { [unowned self] in onSuccess($0, .init(rawValue: email)) }
        )
    }

}
