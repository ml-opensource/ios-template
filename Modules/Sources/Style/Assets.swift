//
//  File.swift
//
//
//  Created by Jakob Mygind on 22/11/2021.
//

import Foundation
import SwiftUI

class ThisBundle {}
extension Image {
    public static let arrowLeft = image("ArrowLeft")
    public static let arrowRight = image("ArrowRight")
    public static let checkmark = image("Checkmark")
    public static let cutlery = image("Cutlery")
    public static let logo = image("Logo")
    public static let pattern = image("Pattern")
    public static let printing = image("Printing")
    public static let search = image("Search")
    public static let settings = image("Settings")
    public static let x = image("x")
}

extension Image {
    fileprivate static func image(_ name: String) -> Image {
        Image(
            name,
            bundle: .findBundle(thisBundleName: "Modules_Style", classInThisBundle: ThisBundle.self)
        )
    }
}
