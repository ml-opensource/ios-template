import Combine
import Foundation
import XCTest

//
//  File.swift
//
//
//  Created by Jakob Mygind on 20/01/2022.
//
@testable import APIClientLive
@testable import Model

final class APIClientAsyncLiveTests: XCTestCase {

    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        return formatter
    }()

    let tokenSuccessResponseData = """
        {
            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOSIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjoxNjQyNjgxMzU1LCJleHAiOjE2NDI2ODI1NTUsImlhdCI6MTY0MjY4MTM1NX0.TUt15w5BOJfeekhM4TY0qdCHNlr4qtDIVdh_S6MzwTI",
            "refreshToken": {
                "token": "6/IOyrlaxkYSI/hqVrDFgzn2tefXfKrVNQJvEIJ32gMhDDNAkmDMYiNogS4LvdS3r3CLuRqbiWWNLcTby3i9xg==",
                "expiresAt": "2022-04-20T12:22:35.3876411Z"
            }
        }
        """.data(using: .utf8)!

    lazy var newTokens = APITokensEnvelope(
        token: .init(
            rawValue:
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOSIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjoxNjQyNjgxMzU1LCJleHAiOjE2NDI2ODI1NTUsImlhdCI6MTY0MjY4MTM1NX0.TUt15w5BOJfeekhM4TY0qdCHNlr4qtDIVdh_S6MzwTI"
        ),
        refreshToken: .init(
            token: .init(
                rawValue:
                    "6/IOyrlaxkYSI/hqVrDFgzn2tefXfKrVNQJvEIJ32gMhDDNAkmDMYiNogS4LvdS3r3CLuRqbiWWNLcTby3i9xg=="
            ),
            expiresAt: formatter.date(from: "2022-04-20T12:22:35.3876411Z")!
        )
    )
    
    let apiCallSuccessData = "Success".data(using: .utf8)!

    @available(iOS 16.0, *)
    @MainActor
    func test_refreshing_expired_token() async throws {
        let successResponse = HTTPURLResponse(
            url: URL(string: ":")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let now = Date.distantFuture
        var tokens: APITokensEnvelope? = APITokensEnvelope.mock

        tokens?.token = .expired

        let apiURLRequest: URLRequest = URLRequest(url: URL(string: ":")!)
        let refreshURL = URL(string: "refresh://")!
        
        var continuation: CheckedContinuation<(Data, URLResponse), Error>!
        
        var requestsMade: [URLRequest] = []
        let authHandler = AuthenticationHandlerAsync(
            refreshURL: refreshURL,
            getTokens: { tokens },
            saveTokens: { tokens = $0 },
            now: { now },
            networkRequest: { urlRequest in
                requestsMade.append(urlRequest)
                return try await withCheckedThrowingContinuation({ cont in
                    continuation = cont
                })
            })

        var valuesReceived: [URLSession.DataTaskPublisher.Output] = []

        var task = await authHandler.refreshTask
        XCTAssertNil(task) // Not yet refreshing
        Task {
            do {
                valuesReceived.append(try await authHandler.performAuthenticatedRequest(apiURLRequest))  // Make the api call
            } catch {
                XCTFail()
            }
        }

        await Task.yield()
        task = await authHandler.refreshTask
        XCTAssertNotNil(task)  // Refresh started
        XCTAssertEqual(requestsMade.count, 1)
        XCTAssertEqual(requestsMade.first?.url, refreshURL)  // Refreash call was made
        continuation.resume(returning: (tokenSuccessResponseData, successResponse))

        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh ended
        
        let refreshedTokens = await authHandler.apiTokens
        XCTAssertEqual(refreshedTokens, newTokens)  // We now have new tokens
        continuation.resume(returning: (apiCallSuccessData, successResponse)) // Now original api call is made and for convenience we just send the same data again
        try await Task.sleep(for: .milliseconds(1))

        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh was terminated
        XCTAssertEqual(valuesReceived.count, 1)
        let result = try XCTUnwrap(valuesReceived.first)
        XCTAssertEqual(result.data, apiCallSuccessData)  // Original api call successfully returned some data
    }

    @available(iOS 16.0, *)
    @MainActor
    func test_refreshing_expired_token_while_multiple_calls_made() async throws {
        let successResponse = HTTPURLResponse(
            url: URL(string: ":")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let now = Date.distantFuture
        var tokens: APITokensEnvelope? = APITokensEnvelope.mock

        tokens?.token = .expired

        let apiURLRequest: URLRequest = URLRequest(url: URL(string: ":")!)
        let refreshURL = URL(string: "refresh://")!
        
        var continuations: [CheckedContinuation<(Data, URLResponse), Error>] = []
        
        var requestsMade: [URLRequest] = []
        let authHandler = AuthenticationHandlerAsync(
            refreshURL: refreshURL,
            getTokens: { tokens },
            saveTokens: { tokens = $0 },
            now: { now },
            networkRequest: { urlRequest in
                requestsMade.append(urlRequest)
                return try await withCheckedThrowingContinuation({ cont in
                    continuations.append(cont)
                })
            })

        var valuesReceived: [URLSession.DataTaskPublisher.Output] = []

        var task = await authHandler.refreshTask
        XCTAssertNil(task) // Not yet refreshing
        
        for _ in 0..<3 {
            Task {
                do {
                    valuesReceived.append(try await authHandler.performAuthenticatedRequest(apiURLRequest))  // Make the api call
                } catch {
                    XCTFail()
                }
            }
        }

        await Task.yield()
        task = await authHandler.refreshTask
        XCTAssertNotNil(task)  // Refresh started
        XCTAssertEqual(requestsMade.count, 1)
        XCTAssertEqual(requestsMade.first?.url, refreshURL)  // Refreash call was made
        (try XCTUnwrap(continuations.removeFirst())).resume(returning: (tokenSuccessResponseData, successResponse))
    
        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh ended
        XCTAssertEqual(continuations.count, 3)
        let refreshedTokens = await authHandler.apiTokens
        XCTAssertEqual(refreshedTokens, newTokens)  // We now have new tokens
        try await Task.sleep(for: .milliseconds(1))
        continuations.forEach {
            $0.resume(returning: (apiCallSuccessData, successResponse))
        }

        try await Task.sleep(for: .milliseconds(1))

        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh was terminated
        XCTAssertEqual(valuesReceived.count, 3)
        let result = try XCTUnwrap(valuesReceived.first)
        XCTAssertEqual(result.data, apiCallSuccessData)  // Original api call successfully returned some data
    }

}

