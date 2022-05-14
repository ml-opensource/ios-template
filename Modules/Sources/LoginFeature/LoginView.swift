//
//  SwiftUIView.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
//

import APIClient
import Combine
import Localizations
import Model
import Style
import SwiftUI
import SwiftUINavigation

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
            Color.base1
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
        )
        .sheet(isPresented: $isShowingDeveloperScreen, onDismiss: nil) {
            DeveloperScreen(
                apiClient: viewModel.environment.apiClient
            )
        }
        .alert(unwrapping: $viewModel.route, case: /LoginViewModel.Route.alert)
    }
}

#if DEBUG
    import Localizations

    struct LoginView_Previews: PreviewProvider {
        static var localizations: ObservableLocalizations = .init(.bundled)

        static var previews: some View {
            LoginView(
                viewModel: .init(
                    onSuccess: { _, _ in },
                    environment: .init(
                        mainQueue: .immediate,
                        apiClient: .mock,
                        date: Date.init,
                        calendar: .init(identifier: .gregorian),
                        localizations: .init(.bundled),
                        appVersion: .noop
                    )
                )
            )
            .registerFonts()
            .environmentObject(ObservableLocalizations.init(.bundled))
        }
    }
#endif
