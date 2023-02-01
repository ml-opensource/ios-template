//
//  File.swift
//
//
//  Created by Jakob Mygind on 18/11/2021.
//

import Foundation
import NStackSDK

public func startNStackSDK(
    appId: String,
    restAPIKey: String,
    environment: NStackSDK.Configuration.NStackEnvironment
) -> ObservableLocalizations {
    let config = NStackSDK.Configuration(
        appId: appId, restAPIKey: restAPIKey, localizationClass: Localizations.self,
        environment: environment
    )

    NStack.start(configuration: config, launchOptions: nil)
    let localizationsWrapper = ObservableLocalizations(lo)

    NStack.sharedInstance.update { _ in

        DispatchQueue.main.async {
            localizationsWrapper.updateLocalizations(lo)
        }
    }
    return localizationsWrapper
}

internal var lo: Localizations {
    guard let manager = NStack.sharedInstance.localizationManager else {
        return Localizations()
    }
    do {
        return try manager.localization()
    } catch {
        print("saved translations not found due to \(error), falling back to bundled json")
        return loadTranslationsFromJSON("Localizations_da-DK", in: .module)
    }
}

internal func loadTranslationsFromJSON(_ filename: String, in bundle: Bundle) -> Localizations {
    let path = bundle.path(forResource: filename, ofType: "json")!

    let data = try! String(contentsOfFile: path).data(using: .utf8)!
    let dict =
        try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    let translationsData = try! JSONSerialization.data(
        withJSONObject: dict["data"]!, options: .fragmentsAllowed)

    let result = try! JSONDecoder().decode(Localizations.self, from: translationsData)
    return result
}
