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
        IfLet($viewModel.destination) { $destination in
            Switch($destination) {
                CaseLet(/AppViewModel.Destination.main) { $vm in
                    NavigationView {
                        MainView(viewModel: vm)
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
                CaseLet(/AppViewModel.Destination.login) { $vm in
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
         .onAppear(perform: viewModel.onAppear)
    }
}

#if DEBUG
import Localizations

struct AppView_Previews: PreviewProvider {
    static var localizations: ObservableLocalizations = .init(.bundled)
    
    static var previews: some View {
        AppView(viewModel: .init())
            .previewDisplayName("No Destination")
        
        AppView(
            viewModel: .init(
                destination: .main(
                    .init()
                )
            )
        )
        .registerFonts()
        .environmentObject(ObservableLocalizations.bundled)
        .previewDisplayName("Main")
        
        AppView(
            viewModel: .init(destination: .login(
                .init(
                    onSuccess: { _, _ in }
                )
            )
            )
        )
        .registerFonts()
        .environmentObject(ObservableLocalizations.bundled)
        .previewDisplayName("Login")
    }
}
#endif
