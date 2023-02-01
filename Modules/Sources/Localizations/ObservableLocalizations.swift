//
//  TranslationsAccessor.swift
//  Shared
//
//  Created by Jakob Mygind on 12/10/2020.
//  Copyright © 2020 ufst. All rights reserved.
//

import Combine
import Foundation
import NStackSDK

@dynamicMemberLookup
public class ObservableLocalizations: ObservableObject {
    @Published private var _localizations: Localizations = .bundled

    public init(_ translations: Localizations) {
        self._localizations = translations
    }

    public subscript<Section>(dynamicMember keyPath: KeyPath<Localizations, Section>) -> Section {
        _localizations[keyPath: keyPath]
    }

    public func updateLocalizations(_ localizations: Localizations) {
        self._localizations = localizations
    }
}

extension Localizations {
    public static var bundled: Localizations = loadTranslationsFromJSON(
        "Localizations_da-DK", in: .myModule)
}

extension ObservableLocalizations {
    public static var bundled = ObservableLocalizations(.bundled)
}

class CurrentBundleFinder {}
extension Foundation.Bundle {
    static var myModule: Bundle = {
        //         The name of your local package, prepended by "LocalPackages_"
        let bundleName = "Modules_Localizations"
        let candidates = [
            //             Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            //             Bundle should be present here when the package is linked into a framework.
            Bundle(for: CurrentBundleFinder.self).resourceURL,
            //             For command-line tools.
            Bundle.main.bundleURL,
            //             Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/").
            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent()
                .deletingLastPathComponent(),
        ]
        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named \(bundleName)")
    }()
}
