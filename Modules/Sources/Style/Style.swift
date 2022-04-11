import Foundation

class CurrentBundleFinder {}
extension Foundation.Bundle {
    static var myModule: Bundle = findBundle(
        thisBundleName: "Modules_Style", classInThisBundle: CurrentBundleFinder.self)
}
