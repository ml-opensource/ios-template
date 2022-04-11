//
//  File.swift
//
//
//  Created by Jakob Mygind on 15/11/2021.
//

import Foundation
import SwiftUI

enum FontName: String {
    case kelptBold = "KelptA3-Bold"
    case kelptMedium = "KelptA3-Medium"
    case kelptRegular = "KelptA3-Regular"
    case helveticaRegular = "Helvetica-Regular"
}

extension Font {
    public enum SemanticName: CaseIterable {
        case headline1, headline2, headline3, headline4, headline5, headline6, subheadline1,
            subheadline2, label1, label2, label3, paragraph, caption
    }
}

extension View {
    func font(_ name: FontName, size: CGFloat) -> some View {
        font(.custom(name.rawValue, size: size))
    }

    @ViewBuilder
    public func font(_ name: Font.SemanticName) -> some View {
        switch name {

        case .headline1:
            font(.kelptBold, size: 63).offset(x: 0, y: 12)
        case .headline2:
            font(.kelptBold, size: 52).offset(x: 0, y: 10)
        case .headline3:
            font(.kelptBold, size: 42).offset(x: 0, y: 8)
        case .headline4:
            font(.kelptBold, size: 32).offset(x: 0, y: 6)
        case .headline5:
            font(.kelptBold, size: 24).offset(x: 0, y: 4)
        case .headline6:
            font(.kelptMedium, size: 18).offset(x: 0, y: 3)
        case .subheadline1:
            font(.kelptMedium, size: 23).offset(x: 0, y: 4)
        case .subheadline2:
            font(.kelptMedium, size: 19).offset(x: 0, y: 3)
        case .label1:
            font(.kelptRegular, size: 23).offset(x: 0, y: 4)
        case .label2:
            font(.kelptRegular, size: 19).offset(x: 0, y: 3)
        case .label3:
            font(.kelptRegular, size: 15).offset(x: 0, y: 2)
        case .paragraph:
            font(.helveticaRegular, size: 16)
        case .caption:
            font(.helveticaRegular, size: 13)
        }
    }
}

extension UIFont {
    public static func custom(_ semanticName: Font.SemanticName) -> UIFont {
        switch semanticName {
        case .headline1:
            return UIFont(name: FontName.kelptBold.rawValue, size: 63)!
        default: fatalError("Not implemented for UIfont")
        }
    }
}

#if DEBUG
    struct Font_Previews: PreviewProvider {
        static var previews: some View {
            registerFonts()
            return VStack {
                ForEach(Font.SemanticName.allCases, id: \.self) {
                    Text("Word").font($0)
                        .padding(12)
                        .background(Color.green)

                }

            }
        }
    }
#endif
