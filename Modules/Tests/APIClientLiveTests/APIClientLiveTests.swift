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

final class APIClientLiveTests: XCTestCase {

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

    lazy var newTokens = APITokens(
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

    var cancellables: Set<AnyCancellable> = []

    func test_refreshing_expired_token() throws {
        let successResponse = HTTPURLResponse(
            url: URL(string: ":")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let now = Date.distantFuture
        var tokens = APITokens.mock

        tokens.token = .expired
        let networkPublisherSubject = PassthroughSubject<
            URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure
        >()

        let apiURLRequest: URLRequest = URLRequest(url: URL(string: ":")!)
        let refreshURL = URL(string: "refresh://")!

        var requestsMade: [URLRequest] = []

        let authHandler = AuthenticationHandler(
            now: { now },
            networkRequestPublisher: { request in
                requestsMade.append(request)
                return networkPublisherSubject.eraseToAnyPublisher()
            },
            refreshURL: refreshURL,
            apiTokens: tokens
        )

        var valuesReceived: [URLSession.DataTaskPublisher.Output] = []

        XCTAssertNil(authHandler.refreshPublisher)  // Not yet refreshing
        authHandler.authenticateRequest(apiURLRequest)  // Make the api call
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    valuesReceived.append($0)

                }
            ).store(in: &cancellables)
        XCTAssertNotNil(authHandler.refreshPublisher)  // Refresh started

        XCTAssertEqual(requestsMade.count, 1)
        XCTAssertEqual(requestsMade.first?.url, refreshURL)  // Refreash call was made
        networkPublisherSubject.send((tokenSuccessResponseData, successResponse))  // Refreshcall returns successfully with tokens

        XCTAssertEqual(authHandler.apiTokens, newTokens)  // We now have new tokens
        networkPublisherSubject.send((tokenSuccessResponseData, successResponse))  // Now original api call is made and for convenience we just send the same data again
        networkPublisherSubject.send(completion: .finished)
        XCTAssertNil(authHandler.refreshPublisher)  // Refresh was terminated
        XCTAssertEqual(valuesReceived.count, 1)
        let result = try XCTUnwrap(valuesReceived.first)
        XCTAssertEqual(result.data, tokenSuccessResponseData)  // Original api call successfully returned some data
    }

    func test_refreshing_expired_token_while_multiple_calls_made() throws {
        let successResponse = HTTPURLResponse(
            url: URL(string: ":")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let now = Date.distantFuture
        var tokens = APITokens.mock

        tokens.token = .expired
        let networkPublisherSubject = PassthroughSubject<
            URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure
        >()

        let apiURLRequest: URLRequest = URLRequest(url: URL(string: ":")!)
        let refreshURL = URL(string: "refresh://")!

        var requestsMade: [URLRequest] = []

        let authHandler = AuthenticationHandler(
            now: { now },
            networkRequestPublisher: { request in
                requestsMade.append(request)
                return networkPublisherSubject.eraseToAnyPublisher()
            },
            refreshURL: refreshURL,
            apiTokens: tokens
        )

        var valuesReceived: [URLSession.DataTaskPublisher.Output] = []

        XCTAssertNil(authHandler.refreshPublisher)  // Not yet refreshing
        authHandler.authenticateRequest(apiURLRequest)  // Make the api call
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    valuesReceived.append($0)

                }
            ).store(in: &cancellables)
        XCTAssertNotNil(authHandler.refreshPublisher)  // Refresh started

        XCTAssertEqual(requestsMade.count, 1)
        XCTAssertEqual(requestsMade.first?.url, refreshURL)  // Refreash call was made
        networkPublisherSubject.send((tokenSuccessResponseData, successResponse))  // Refreshcall returns successfully with tokens

        XCTAssertEqual(authHandler.apiTokens, newTokens)  // We now have new tokens
        networkPublisherSubject.send((tokenSuccessResponseData, successResponse))  // Now original api call is made and for convenience we just send the same data again
        networkPublisherSubject.send(completion: .finished)
        XCTAssertNil(authHandler.refreshPublisher)  // Refresh was terminated
        XCTAssertEqual(valuesReceived.count, 1)
        let result = try XCTUnwrap(valuesReceived.first)
        XCTAssertEqual(result.data, tokenSuccessResponseData)  // Original api call successfully returned some data
    }

}
