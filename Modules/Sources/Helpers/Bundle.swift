//
//  File.swift
//  
//
//  Created by Fábio Maciel de Sousa on 16.03.2022.
//

import UIKit

public extension Bundle {
    /// This allows you to use resources from a certain module in other Swift Package previews.
    /// Inspiration from here: https://developer.apple.com/forums/thread/664295
    static func getCurrentBundle<BundleFinder: AnyObject>(bundleName: String,
                                                          bundleFinder: BundleFinder.Type) -> Bundle {
        // The name of your local package bundle. This may change on every different version of Xcode.
        // It used to be "LocalPackages_<ModuleName>" for iOS. To find out what it is, print out  the path for
        // Bundle(for: BundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent()
        // and then look for what bundle is named in there.
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,
            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,
            // For command-line tools.
            Bundle.main.bundleURL,
            // Bundle should be present here when running previews from a different package
            // (this is the path to "…/Debug-iphonesimulator/").
            Bundle(for: BundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
            Bundle(for: BundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        ]

        for candidate in candidates {
            let bundlePathiOS = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("Can't find bundle: \(bundleName). See Bundle.swift")
    }
}
