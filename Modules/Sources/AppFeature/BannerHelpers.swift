//
//  File.swift
//
//
//  Created by Jakob Mygind on 17/01/2022.
//

import Foundation
import Style
import SwiftUI

extension View {

    /// Banner that shows offline or server error 'toast' style banner
    /// - Parameter enum: field controlling banner state
    /// - Returns: modified view
    func banner(unwrapping enum: AppViewModel.BannerState?) -> some View {
        ZStack {
            self
            if let `enum` = `enum` {

                switch `enum` {
                case let .serverError(msg):
                    makeBanner(message: msg, color: .red)

                case let .offline(msg):
                    makeBanner(message: msg, color: .orange)
                }
            }
        }
    }

    func makeBanner(
        message: String,
        color: Color
    ) -> some View {
        VStack {
            Spacer()
            Text(message)
                .font(.label2)
                .foregroundColor(.black)
                .padding(.horizontal, 50)
                .frame(minWidth: 359, minHeight: 54)
                .background(color.cornerRadius(8).shadow(radius: 3))
                .padding(.bottom, 12)

        }.zIndex(1)
            .transition(
                .move(edge: .bottom)
            )
    }
}
