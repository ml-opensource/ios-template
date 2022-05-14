//
//  File.swift
//
//
//  Created by Jakob Mygind on 15/11/2021.
//

import Foundation
import SwiftUI

extension Color {
    public static let base1 = color("Base1")
    public static let base2 = color("Base2")
    public static let base3 = color("Base3")
    public static let baseGreen50 = color("BaseGreen50")
    public static let baseOrange50 = color("BaseOrange50")
}

extension Color {
    fileprivate static func color(_ name: String) -> Color {
        Color(name, bundle: .styleBundle)
    }
}

extension UIColor {
    public static func custom(color: Color) -> UIColor {
        let name = "\(color)"
        let start = name.firstIndex(of: "\"")!
        let end = name.lastIndex(of: "\"")!
        let trimmed = String(name[name.index(after: start)...name.index(before: end)])
        return UIColor(named: trimmed, in: .myModule, compatibleWith: nil)!
    }
}

struct Colors_Previews: PreviewProvider {

    static let colors = [
        Color.base1,
        Color.base2,
        Color.base3,
        Color.baseGreen50,
        Color.baseOrange50,
    ]
    static var previews: some View {
        Color.gray.overlay(
            LazyHGrid(rows: [GridItem(.fixed(50)), GridItem(.fixed(50)), GridItem(.fixed(50))]) {
                ForEach(Array(0..<colors.count), id: \.self) {
                    Circle().fill(colors[$0]).frame(width: 50, height: 50, alignment: .center)
                }
            }
        )
        .ignoresSafeArea()
    }
}
