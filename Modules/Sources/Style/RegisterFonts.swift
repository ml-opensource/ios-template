import Helpers
import SwiftUI

public enum CustomFonts {
    static let fontNames = [
        "KelptA3-Bold",
        "KelptA3-Regular",
        "KelptA3-Medium",
    ]

    public static func registerCustomFonts() {
        for font in fontNames {
            guard let url = Bundle.styleBundle.url(forResource: font, withExtension: "otf") else {
                fatalError("Couldn't find font: \(font)!")
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension View {

    /// Attach this to any Xcode Preview's view to have custom fonts displayed
    /// Note: Not needed for the actual app
    public func registerFonts() -> some View {
        CustomFonts.registerCustomFonts()
        return self
    }
}

// MARK: - getting current bundle to use in previews
extension Foundation.Bundle {
    private class CurrentBundleFinder {}

    static var styleBundle: Bundle = {
        .getCurrentBundle(
            bundleName: "Modules_Style",
            bundleFinder: CurrentBundleFinder.self
        )
    }()
}
