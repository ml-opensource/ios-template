//
//  SwiftUIView.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
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
        #if DEBUG
            email = "711dk009@7-eleven.dk"
            password = "1B57E5A0"
        #endif
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

public struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel
    @EnvironmentObject var localizations: ObservableLocalizations

    @State var isShowingDeveloperScreen = false

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
       
            VStack {
                VStack(spacing: 24) {
                    Text(localizations.login.title.uppercased())
                        .font(.headline4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading) {
                        Text(localizations.login.emailHeader)
                            .font(.label2)
                        TextField(
                            localizations.login.emailHeader,
                            text: $viewModel.email,
                            prompt: Text(localizations.login.emailPlaceholder)
                              
                        )
                        .font(.paragraph)

                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    VStack(alignment: .leading) {
                        Text(localizations.login.passwordHeader)
                            .font(.label2)
                        TextField(
                            localizations.login.passwordHeader,
                            text: $viewModel.password,
                            prompt: Text(localizations.login.passwordPlaceholder)
                        )
                        .font(.paragraph)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }

                    VStack(spacing: 20) {
                        Button(
                            localizations.login.loginButton.uppercased(),
                            action: { withAnimation { viewModel.loginButtonTapped() } }
                        )
                        .buttonStyle(
                            PrimaryButtonStyle(
                                isEnabled: viewModel.isButtonEnabled,
                                isLoading: viewModel.isAPICallInFlight
                            ))
                        Text(localizations.login.resetPasswordMessage)
                            .font(.label3)
                           
                    }

                }
               
                .padding(40)
            }
            .frame(width: 423)
            .background(
                Color.base1.cornerRadius(16).shadow(
                    color: .black.opacity(0.15), radius: 2, x: 0, y: 1))
        
        .sheet(isPresented: $isShowingDeveloperScreen, onDismiss: nil) {
            DeveloperScreen(
                apiClient: viewModel.environment.apiClient
            )
        }
        .alert(unwrapping: $viewModel.route, case: /LoginViewModel.Route.alert)


    }

}
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        registerFonts()
//        return LoginView(viewModel: <#LoginViewModel#>)
//            .previewLayout(.fixed(width: 1136, height: 820))
//    }
//}
