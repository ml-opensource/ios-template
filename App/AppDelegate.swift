//
//  AppDelegate.swift
//  InStoreApp
//
//  Created by Jakob Mygind on 15/11/2021.
//

import APIClientLive
import AppFeature
import Combine
import Dependencies
import Localizations
import Model
import NStackSDK
import PersistenceClient
import Style
import SwiftUI
import XCTestDynamicOverlay

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
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)
        
        self.registerFonts()
        self.startAppView()
    }
}

// MARK: - Dependencies setup

extension SceneDelegate {
    
    /// Allows using project specific fonts int the same way you use any of the iOS-provided fonts.
    /// Custom fonts should be located on the `Style`.
    fileprivate func registerFonts() {
        CustomFonts.registerCustomFonts()
    }    
    
    /// Defines content view of the window assigned to the scene with the required dependencies.
    /// This is the entry point for the app which defines the source of truth for related environment settings.
    fileprivate func startAppView() {
        
        @Dependency(\.localizations) var localizations
        
#if RELEASE
        AppView(viewModel: .init())
            .environmentObject(localizations)
#else
        let apiEnvironments = Configuration.API.environments
        let appView = AppView(viewModel: .init())
            .environmentObject(localizations)
            .environment(\.apiEnvironments, apiEnvironments)
#endif
        
        self.window?.rootViewController = UIHostingController(rootView: appView)
        self.window?.makeKeyAndVisible()
    }
}
