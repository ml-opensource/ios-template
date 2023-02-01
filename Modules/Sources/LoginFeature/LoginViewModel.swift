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
        email.contains("@") && email.contains(".") && email.count >= 6
            && !password.isEmpty && !isAPICallInFlight
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
//        loginCancellable = environment.apiClient.authenticate(
//            Username(rawValue: email.trimmingCharacters(in: .whitespacesAndNewlines)),
//            Password(rawValue: password.trimmingCharacters(in: .whitespacesAndNewlines))
//        )
//        .receive(on: environment.mainQueue, options: nil)
//        .sink(
//            receiveCompletion: { [weak self, environment] in
//                if case .failure(let error) = $0 {
//                    self?.route = .alert(
//                        .withTitleAndMessage(
//                            title: environment.localizations.error.errorTitle,
//                            message: error.errorCode == "401"
//                                ? environment.localizations.login.errorInvalidCredentials
//                                : environment.localizations.error.serverError,
//                            action1: .primary(
//                                title: environment.localizations.defaultSection.ok.uppercased(),
//                                action: { self?.route = nil })
//                        )
//                    )
//                }
//                self?.isAPICallInFlight = false
//            },
//            receiveValue: { [unowned self] in onSuccess($0, .init(rawValue: email)) }
//        )
    }

}
