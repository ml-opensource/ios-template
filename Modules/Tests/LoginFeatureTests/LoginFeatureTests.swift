//
//  File.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
//

import Dependencies
import Foundation
import Model
import XCTest

@testable import LoginFeature

final class LoginFeatureTests: XCTestCase {
    func testLoginSuccess() async throws {
        
        var successCalls: [(APITokensEnvelope, Username)] = []
        
        let model = withDependencies {
            $0.appVersion = .init(version: { "version" }, build: { "build" })
            $0.apiClient.tokensUpdateStream = { .finished }
            $0.apiClient.authenticate = { _, _ in
                .mock
            }
        } operation: {
            LoginViewModel(onSuccess: {
                successCalls.append(($0, $1))
            })
        }
        
        model.onAppear()
        XCTAssertEqual(model.focusState, .email)
        XCTAssertEqual(model.appVersionString, "version(build)")
        
        model.emailChanged("Hej")
        XCTAssertFalse(model.isButtonEnabled)
        model.emailChanged("Hej@hop")
        
        XCTAssertFalse(model.isButtonEnabled)
        model.emailChanged("Hej@hop.dk")
        XCTAssertFalse(model.isButtonEnabled)
        
        model.passwordChanged("12345")
        XCTAssertTrue(model.isButtonEnabled)
        
        model.loginButtonTapped()
        
        XCTAssertTrue(model.isAPICallInFlight)
        await Task.yield()
        XCTAssertFalse(model.isAPICallInFlight)
        
        XCTAssertEqual(successCalls.count, 1)
        let successCall = try XCTUnwrap(successCalls.first)
        
        XCTAssertEqual(successCall.0, APITokensEnvelope.mock)
        XCTAssertEqual(successCall.1, Username("Hej@hop.dk"))
       
        
    }
}
