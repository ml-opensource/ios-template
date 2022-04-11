//
//  File.swift
//
//
//  Created by Jakob Mygind on 15/11/2021.
//

import Foundation
import SwiftUI

// class Colors {}
extension Color {
    public static let base1 = Color("Base1", bundle: .module)

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
        Color.base1
    ]
    static var previews: some View {
        LazyHGrid(rows: [GridItem(.fixed(50)), GridItem(.fixed(50)), GridItem(.fixed(50))]) {
            ForEach(Array(0..<colors.count), id: \.self) {
                Circle().fill(colors[$0]).frame(width: 50, height: 50, alignment: .center)
            }
        }

    }
}
