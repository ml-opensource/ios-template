//
//  AppDelegate.swift
//  InStoreApp
//
//  Created by Jakob Mygind on 15/11/2021.
//

import APIClientLive
import AppFeature
import Combine
import Localizations
import Model
import PersistenceClient
import Style
import SwiftUI
import UIKit

@main
final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        return true
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var localizations: ObservableLocalizations = .init(.bundled)
    var tokenCancellable: AnyCancellable?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)

        if !Style.registerFonts() {
            fatalError()
        }
        localizations = startNStackSDK(
            appId: <#appID#>,
            restAPIKey: <#restAPIKey#>
        )

       
        let baseURL = Configuration.API.baseURL

        let persistenceClient = PersistenceClient.live(keyPrefix: <#"dk.7-eleven.instore"#>)

        #if !RELEASE
            UserDefaults.standard.register(defaults: ["USE_MOCK_API": false])
            let isUsingMockAPI = UserDefaults.standard.bool(forKey: "USE_MOCK_API")
            if isUsingMockAPI {
                persistenceClient.tokens.save(nil)
            }
        #endif

        let authHandler = AuthenticationHandler(
            refreshURL: <#refreshURL#>,
            tokens: persistenceClient.tokens.load()
        )
        tokenCancellable = authHandler.tokenUpdatePublisher.sink(
            receiveValue: persistenceClient.tokens.save)

        let environment = AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            apiClient: isUsingMockAPI
                ? .functionalMock
                : .live(baseURL: baseURL, authenticationHandler: authHandler),
            date: Date.init,
            calendar: .autoupdatingCurrent,
            localizations: localizations,
            appVersion: .live,
            persistenceClient: persistenceClient,
            tokenUpdatePublisher: authHandler.tokenUpdatePublisher.eraseToAnyPublisher(),
            networkMonitor: .live(queue: .main)
        )

        let apiEnvironments = Configuration.API.environments

        let vm = AppViewModel(environment: environment)
        #if RELEASE
            let appView = AppView(viewModel: vm)
                .environmentObject(localizations)
        #else
            let appView = AppView(viewModel: vm)
                .environmentObject(localizations)
                .environment(\.apiEnvironments, apiEnvironments)
        #endif

        self.window!.rootViewController = UIHostingController(rootView: appView)
        self.window!.makeKeyAndVisible()
    }
}
