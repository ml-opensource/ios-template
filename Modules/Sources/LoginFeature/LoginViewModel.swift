//
//  File.swift
//  
//
//  Created by Nicolai Harbo on 20/04/2022.
//

import APIClient
import AppVersion
import Combine
import Dependencies
import Model
import Style

public class LoginViewModel: ObservableObject {

    var onSuccess: (APITokensEnvelope, Username) -> Void
    
    @Dependency(\.appVersion) var appVersion
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.localizations) var localizations

    enum Route {
        case alert(AlertState)
    }
    @Published var route: Route?

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var appVersionString: String = ""
    @Published var isAPICallInFlight = false
    @Published var focusState: LoginView.FocueField?

    var loginCancellable: AnyCancellable?
    var cancellables: Set<AnyCancellable> = []

    public init(
        onSuccess: @escaping (APITokensEnvelope, Username) -> Void
    ) {
        self.onSuccess = onSuccess
        appVersionString = "\(appVersion.version())(\(appVersion.build()))"
    }

    /// Simple heuristics for email pattern
    var isButtonEnabled: Bool {
        email.contains("@")
        && email.contains(".")
        && email.count >= 6
        && !password.isEmpty
        && !isAPICallInFlight
    }
    
    func onAppear() {
        focusState = .email
    }
    
    func emailChanged(_ text: String) {
        email = text
    }
    
    func passwordChanged(_ text: String) {
        password = text
    }

    func loginButtonTapped() {
        isAPICallInFlight = true
        Task {
            do {
                let token = try await apiClient.authenticate(
                    Username(rawValue: email.trimmingCharacters(in: .whitespacesAndNewlines)),
                    Password(rawValue: password.trimmingCharacters(in: .whitespacesAndNewlines))
                )
                onSuccess(token, .init(rawValue: email))
            } catch let error as APIError {
                route = .alert(
                    .withTitleAndMessage(
                        title: localizations.error.errorTitle,
                        message: error.errorCode == "401"
                        ? localizations.login.errorInvalidCredentials
                        : localizations.error.serverError,
                        action1: .primary(
                            title: localizations.defaultSection.ok.uppercased(),
                            action: { [weak self] in self?.route = nil })
                    )
                )
            }
            isAPICallInFlight = false
        }
    }

}
