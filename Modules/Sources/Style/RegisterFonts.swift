import UIKit

class FontsBundle {}
@discardableResult
public func registerFonts() -> Bool {
    [
        UIFont.registerFont(
            bundles: .findBundle(
                thisBundleName: "Modules_Style", classInThisBundle: FontsBundle.self),
            fontName: "KelptA3-Bold", fontExtension: "otf"),
        UIFont.registerFont(
            bundles: .findBundle(
                thisBundleName: "Modules_Style", classInThisBundle: FontsBundle.self),
            fontName: "KelptA3-Regular", fontExtension: "otf"),
        UIFont.registerFont(
            bundles: .findBundle(
                thisBundleName: "Modules_Style", classInThisBundle: FontsBundle.self),
            fontName: "KelptA3-Medium", fontExtension: "otf"),
    ]
    .allSatisfy { $0 }
}

extension UIFont {

    static func registerFont(bundles: Bundle..., fontName: String, fontExtension: String) -> Bool {
        for bundle in bundles {
            if registerFont(bundle: bundle, fontName: fontName, fontExtension: fontExtension) {
                return true
            }
        }
        return false
    }
    static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
            print("Couldn't find font \(fontName)")
            return false
        }
        guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
            print("Couldn't load data from the font \(fontName)")
            return false
        }
        guard let font = CGFont(fontDataProvider) else {
            print("Couldn't create font from data")
            return false
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterGraphicsFont(font, &error)
        guard success else {
            print(
                """
                Error registering font: \(fontName). Maybe it was already registered.\
                \(error.map { " \($0.takeUnretainedValue().localizedDescription)" } ?? "")
                """
            )
            return true
        }

        return true
    }
}
