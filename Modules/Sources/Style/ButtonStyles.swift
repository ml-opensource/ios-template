//
//  File.swift
//
//
//  Created by Jakob Mygind on 20/12/2021.
//

import Foundation
import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {

    let isEnabled: Bool
    let isLoading: Bool
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?

    public init(
        isEnabled: Bool = true,
        isLoading: Bool = false,
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = .infinity,
        minHeight: CGFloat? = 48
    ) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            } else {
                configuration.label
            }
        }
        .font(.headline6)
//        .foregroundColor(isEnabled ? .onTint1 : .onBase3)
        .padding(.horizontal, 16)
        .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight)
//        .background(
//            isEnabled
//                ? AnyView(Color.tintAccent)
//                : AnyView(Image.pattern.resizable(resizingMode: .tile))
//        )
        .clipShape(Capsule())
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    public static var primary: Self {
        self.init()
    }
}

public struct SecondaryButtonStyle: ButtonStyle {

    let isEnabled: Bool
    let isLoading: Bool
    let maxWidth: CGFloat?
    let minHeight: CGFloat?

    public init(
        isEnabled: Bool = true,
        isLoading: Bool = false,
        maxWidth: CGFloat? = .infinity,
        minHeight: CGFloat? = 48
    ) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.maxWidth = maxWidth
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            } else {
                configuration.label
            }
        }
        .padding(.horizontal, 8)
        .font(.headline6)
//        .foregroundColor(isEnabled ? .onBase1 : .onBase3)
        .frame(maxWidth: maxWidth, minHeight: minHeight)
        .background(
            isEnabled
                ? AnyView(EmptyView())
                : AnyView(Image.pattern.resizable(resizingMode: .tile))
        )
        .clipShape(Capsule())
//        .overlay(Capsule().stroke(Color.onBaseDivider2))
        .contentShape(Rectangle())
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    public static var secondary: Self {
        self.init()
    }
}

public struct DestructiveButtonStyle: ButtonStyle {

    let isEnabled: Bool
    let isLoading: Bool
    let maxWidth: CGFloat?
    let minHeight: CGFloat?

    public init(
        isEnabled: Bool = true,
        isLoading: Bool = false,
        maxWidth: CGFloat? = .infinity,
        minHeight: CGFloat? = 48
    ) {
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.maxWidth = maxWidth
        self.minHeight = minHeight
    }

    public func makeBody(configuration: Configuration) -> some View {
        Group {
            if isLoading {
                ProgressView().progressViewStyle(.circular)
            } else {
                configuration.label
            }
        }
        .font(.headline6)
//        .foregroundColor(isEnabled ? .onTint1 : .onBase3)
        .frame(maxWidth: maxWidth, minHeight: minHeight)
//        .background(
//            isEnabled
//                ? AnyView(Color.baseRed80)
//                : AnyView(Image.pattern.resizable(resizingMode: .tile))
//        )
        .clipShape(Capsule())
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    public static var destructive: Self {
        self.init()
    }
}
