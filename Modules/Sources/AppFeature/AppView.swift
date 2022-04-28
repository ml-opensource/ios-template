//
//  SwiftUIView.swift
//
//
//  Created by Jakob Mygind on 10/12/2021.
//

import Login
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
                       Text("Main")
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
        }
        .onAppear(perform: viewModel.onAppear)
    }
}
