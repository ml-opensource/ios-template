//
//  File.swift
//
//
//  Created by Jakob Mygind on 17/12/2021.
//

import Foundation
import SwiftUI
import SwiftUINavigation

public struct AlertState: Equatable {

    public enum Action: Equatable {

        case primary(title: String, action: () -> Void)
        case secondary(title: String, action: () -> Void)
        case destructive(title: String, action: () -> Void)
        
        public var title: String {
            switch self {
                
            case .primary(let title, action: _),
                    .secondary(let title, action: _),
                    .destructive(let title, action: _):
                return title
            }
        }
        
        public static func == (lhs: AlertState.Action, rhs: AlertState.Action) -> Bool {
            switch (lhs, rhs) {
            case (.primary(title: let title1, action: _), .primary(title: let title2, action: _)),
                (
                    .secondary(title: let title1, action: _),
                    .secondary(title: let title2, action: _)
                ),
                (
                    .destructive(title: let title1, action: _),
                    .destructive(title: let title2, action: _)
                ):
                return title1 == title2
            default:
                return false
            }
        }
    }

    public let title: String?
    public let message: String?
    public let actions: [Action]
    
    private init(
        title: String?,
        message: String?,
        actions: [AlertState.Action]
    ) {
        self.title = title
        self.message = message
        self.actions = actions
    }

    public static func withTitleAndMessage(
        title: String,
        message: String,
        action1: Action,
        action2: Action? = nil
    ) -> AlertState {
        self.init(title: title, message: message, actions: [action1, action2].compactMap { $0 })
    }

    public static func withTitle(
        title: String,
        action1: Action,
        action2: Action? = nil
    ) -> AlertState {
        self.init(title: title, message: nil, actions: [action1, action2].compactMap { $0 })
    }

    public static func withMessage(
        message: String,
        action1: Action,
        action2: Action? = nil
    ) -> AlertState {
        self.init(title: nil, message: message, actions: [action1, action2].compactMap { $0 })
    }
}

public struct CustomAlert: ViewModifier {

    @Binding var isPresented: Bool
    @Binding var value: AlertState?
    init(unwrapping value: Binding<AlertState?>) {
        self._value = value
        self._isPresented = value.isPresent()
    }

    public func body(content: Content) -> some View {
        // wrap the view being modified in a ZStack and render dialog on top of it
        ZStack {
            content
            if isPresented, let value = value {
                AlertView(alertState: value)
                    .transition(.opacity.animation(.default))
                
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

extension View {
    public func alert(unwrapping value: Binding<AlertState?>) -> some View {
        self.modifier(CustomAlert(unwrapping: value))
    }

    public func alert<Enum>(
        unwrapping enum: Binding<Enum?>,
        case casePath: CasePath<Enum, AlertState>
    ) -> some View {
        self.modifier(CustomAlert(unwrapping: `enum`.case(casePath)))
    }
}

public struct AlertView: View {

    let alertState: AlertState

    public var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)

            VStack {
                VStack(spacing: 16) {
                    if let title = alertState.title {
                        Text(title.uppercased())
                            .font(.headline6)
                    }

                    if let message = alertState.message {
                        Text(message)
                            .font(.subheadline1)
                    }

                    HStack(spacing: 16) {
                        ForEach(alertState.actions, id: \.title) {
                            $0.button
                        }
                    }
                    .textCase(.uppercase)
                }
                .padding(16)
            }
            .frame(maxWidth: 552)
            .background(
                Color.base1.cornerRadius(16).shadow(
                    color: .black.opacity(0.15), radius: 2, x: 0, y: 1))
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

extension AlertState.Action {
    @ViewBuilder
    var button: some View {
        switch self {

        case .primary(let title, let action):
            Button(title, action: action)
                .buttonStyle(.primary)
        case .secondary(let title, let action):
            Button(title, action: action)
                .buttonStyle(.secondary)
        case .destructive(let title, let action):
            Button(title, action: action)
                .buttonStyle(.destructive)
        }
    }
}

struct TestView: View {
     let alertState: AlertState? = .withTitleAndMessage(title: "WithtitleAndMessage", message: "Message", action1: .primary(title: "Primary", action: {}))
    var body: some View {
        Text("Hi")
            .alert(unwrapping: .constant(alertState))
    }
}

struct AlertView_Previews: PreviewProvider {
    static let alertState: AlertState? = .withTitleAndMessage(title: "WithtitleAndMessage", message: "Message", action1: .primary(title: "Primary", action: {}))
    
    static var previews: some View {
        
        TabView {
            TestView().tabItem { Text("Tab1") }
           
            Color.green.tabItem { Text("Tab2") }
        }
           
    }
}
