//
//  SwiftUIView.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
//

import Dependencies
import Localizations
import Style
import SwiftUI
import SwiftUINavigation

public struct LoginView: View {
    
    enum FocueField: Hashable {
        case email, password
    }
    
    @FocusState var focusField: FocueField?

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
                        text: .init(
                            get: { viewModel.email },
                            set: viewModel.emailChanged(_:)
                        ),
                        prompt: Text(localizations.login.emailPlaceholder)

                    )
                    .focused($focusField, equals: .email)
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
                        text: .init(
                            get: { viewModel.password },
                            set: viewModel.passwordChanged(_:)
                        ),
                        prompt: Text(localizations.login.passwordPlaceholder)
                    )
                    .focused($focusField, equals: .password)
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
            DeveloperScreen()
        }
        .alert(unwrapping: $viewModel.route, case: /LoginViewModel.Route.alert)
        .onAppear(perform: viewModel.onAppear)
        .bind($viewModel.focusState, to: $focusField)
    }
}

#if DEBUG
    import Localizations

    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView(viewModel: withDependencies {
                $0.localizations = .bundled
                $0.apiClient = .mock
                $0.appVersion = .mock
            } operation: {
                LoginViewModel(onSuccess: { _, _ in })
            })
          
            .registerFonts()
            .environmentObject(ObservableLocalizations.bundled)
        }
    }
#endif
