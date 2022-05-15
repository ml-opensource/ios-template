//
//  SwiftUIView.swift
//
//
//  Created by Jakob Mygind on 10/12/2021.
//

import LoginFeature
import MainFeature
import Style
import SwiftUI
import SwiftUINavigation

/// View that can switch between Login and Main view
public struct AppView: View {
    @ObservedObject var viewModel: AppViewModel

    public init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        IfLet($viewModel.route) { $route in
            Switch($route) {
                CaseLet(/AppViewModel.Route.main) { $vm in
                    NavigationView {
                        MainFeatureView(viewModel: vm)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(edge: .leading)
                                )
                                .animation(.default)
                            )
                            .navigationBarHidden(true)
                    }
                    .navigationViewStyle(.stack)
                }
                CaseLet(/AppViewModel.Route.login) { $vm in
                    LoginView(viewModel: vm)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading), removal: .move(edge: .trailing)
                            )
                            .animation(.default)
                        )
                }
            }
            .banner(unwrapping: viewModel.bannerState)
        } else: {
            ProgressView()
        }
        // .onAppear(perform: viewModel.onAppear)
    }
}

#if DEBUG
    import Localizations

    struct AppView_Previews: PreviewProvider {
        static var localizations: ObservableLocalizations = .init(.bundled)

        static var previews: some View {
            AppView(viewModel: .init(environment: .mock))
                .previewDisplayName("No Route")

            AppView(
                viewModel: .init(
                    environment: .mock,
                    route: .main(
                        .init(environment: .init(mainQueue: .immediate)))
                )
            )
            .registerFonts()
            .environmentObject(ObservableLocalizations.init(.bundled))
            .previewDisplayName("Main")

            let environment: AppEnvironment = .mock
            AppView(
                viewModel: .init(
                    environment: environment,
                    route: .login(
                        .init(
                            onSuccess: { _, _ in },
                            environment:
                                LoginEnvironment(
                                    mainQueue: environment.mainQueue,
                                    apiClient: environment.apiClient,
                                    date: environment.date,
                                    calendar: environment.calendar,
                                    localizations: environment.localizations,
                                    appVersion: environment.appVersion
                                )
                        )
                    )
                )
            )
            .registerFonts()
            .environmentObject(ObservableLocalizations.init(.bundled))
            .previewDisplayName("Login")
        }
    }
#endif
