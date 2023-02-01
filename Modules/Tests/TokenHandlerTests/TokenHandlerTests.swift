import Combine
import Foundation
import XCTest

//
//  File.swift
//
//
//  Created by Jakob Mygind on 20/01/2022.
//
@testable import TokenHandler
//@testable import Model

final class TokenHandlerTests: XCTestCase {
    
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        return formatter
    }()
    
    var tokenSuccessResponseData: Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        return try! encoder.encode(newTokens)
    }
    
    lazy var newTokens = APITokensEnvelope(
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOSIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjoxNjQyNjgxMzU1LCJleHAiOjE2NDI2ODI1NTUsImlhdCI6MTY0MjY4MTM1NX0.TUt15w5BOJfeekhM4TY0qdCHNlr4qtDIVdh_S6MzwTI",
        refreshToken: .init(
            token:  "6/IOyrlaxkYSI/hqVrDFgzn2tefXfKrVNQJvEIJ32gMhDDNAkmDMYiNogS4LvdS3r3CLuRqbiWWNLcTby3i9xg==",
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
            }
        )
        
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
        (try XCTUnwrap(continuations.removeFirst())).resume(returning: (tokenSuccessResponseData, .success))
        
        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh ended
        XCTAssertEqual(continuations.count, 3)
        let refreshedTokens = await authHandler.apiTokens
        XCTAssertEqual(refreshedTokens, newTokens)  // We now have new tokens
        try await Task.sleep(for: .milliseconds(1))
        continuations.forEach {
            $0.resume(returning: (apiCallSuccessData, .success))
        }
        
        try await Task.sleep(for: .milliseconds(1))
        
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh was terminated
        XCTAssertEqual(valuesReceived.count, 3)
        let result = try XCTUnwrap(valuesReceived.first)
        XCTAssertEqual(result.data, apiCallSuccessData)  // Original api call successfully returned some data
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func test_api_call_fails_with_non_expired_token_but_refresh_succeeds_while_multiple_calls_made() async throws {
       
        let now = Date.distantPast
        var tokens: APITokensEnvelope? = APITokensEnvelope.mock
        
        tokens?.token = .expires06142256
        
        let apiURLRequest: URLRequest = URLRequest(url: URL(string: "apiCall://")!)
        let refreshURL = URL(string: "refresh://")!
    
        var requestsAndContinuations: [(request: URLRequest, continuation: CheckedContinuation<(Data, URLResponse), Error>)] = []
        let authHandler = AuthenticationHandlerAsync(
            refreshURL: refreshURL,
            getTokens: { tokens },
            saveTokens: {
                tokens = $0
            },
            now: { now },
            networkRequest: { urlRequest in
                return try await withCheckedThrowingContinuation({ cont in
                    requestsAndContinuations.append((urlRequest, cont))
                })
            })
        
        var valuesReceived: [URLSession.DataTaskPublisher.Output] = []
        
        var task = await authHandler.refreshTask
        XCTAssertNil(task) // Not yet refreshing
        
        // Make 3 simultaneous api calls
        for _ in 0..<3 {
            Task {
                do {
                    valuesReceived.append(try await authHandler.performAuthenticatedRequest(apiURLRequest))  // Make the api call
                } catch {
                    XCTFail("\(error.localizedDescription)")
                }
            }
        }
        
        await Task.yield()
      
        let firstRequest = requestsAndContinuations.removeFirst()
        XCTAssertEqual(firstRequest.request.url, URL(string: "apiCall://")!)
        (try XCTUnwrap(firstRequest.continuation)).resume(returning: (Data(), .tokenExpired))
        
        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNotNil(task)  // Refresh started
        XCTAssertEqual(requestsAndContinuations.count, 3)
        
        // Find apicall made corresponding to the refreshCall
        let refreshCalls = requestsAndContinuations.filter { $0.request.url == URL(string: "refresh://")! }
        XCTAssertEqual(refreshCalls.count, 1)
        let refreshIndex = try XCTUnwrap(requestsAndContinuations.firstIndex(where: { $0.request.url == URL(string: "refresh://")!}))
        let refreshContinuation = requestsAndContinuations.remove(at: refreshIndex).continuation
        
        (try XCTUnwrap(refreshContinuation)).resume(returning: (tokenSuccessResponseData, .success))
        
        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh was terminated
        let refreshedTokens = await authHandler.apiTokens
        XCTAssertEqual(refreshedTokens, newTokens)  // We now have new tokens
        XCTAssertEqual(requestsAndContinuations.count, 3)
        requestsAndContinuations.forEach {
            $0.continuation.resume(returning: (apiCallSuccessData, .success))
        }
        try await Task.sleep(for: .milliseconds(1))
        XCTAssertEqual(valuesReceived.count, 3)
        let result = try XCTUnwrap(valuesReceived[1])
        XCTAssertEqual(result.data, apiCallSuccessData)  // Original api calls successfully returned some data
    }
    
    @available(iOS 16.0, *)
    @MainActor
    func test_refreshing_expired_token_fail_while_multiple_calls_made() async throws {
        
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
        
        let workCount = 3
        var failedRequests = 0
        
        for _ in 0..<workCount {
            Task {
                do {
                    valuesReceived.append(try await authHandler.performAuthenticatedRequest(apiURLRequest))  // Make the api call
                } catch {
                    failedRequests += 1
                }
            }
        }
        
        await Task.yield()
        task = await authHandler.refreshTask
        XCTAssertNotNil(task)  // Refresh started
        XCTAssertEqual(requestsMade.count, 1)
        XCTAssertEqual(requestsMade.first?.url, refreshURL)  // Refreash call was made
        (try XCTUnwrap(continuations.removeFirst())).resume(returning: (Data(), .tokenRefreshFailed))
        
        try await Task.sleep(for: .milliseconds(1))
        task = await authHandler.refreshTask
        XCTAssertNil(task)  // Refresh ended
        XCTAssertEqual(continuations.count, 0)
        let refreshedTokens = await authHandler.apiTokens
        XCTAssertEqual(refreshedTokens, nil)  // Token refresh failed, tokens should be deleted
        try await Task.sleep(for: .milliseconds(1))

        XCTAssertEqual(workCount, failedRequests)
        
    }
    
}

extension URLResponse {
    static let success = HTTPURLResponse(
        url: URL(string: ":")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    
    static let tokenExpired = HTTPURLResponse(
        url: URL(string: "apiCall://")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
    
    static let tokenRefreshFailed = HTTPURLResponse(
        url: URL(string: "refresh://")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
}

extension String {
    /// A token with expiry some time in December afair
    public static let expired = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMyIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjoxNjM5NTg0OTUyLCJleHAiOjE2Mzk1ODYxNTIsImlhdCI6MTYzOTU4NDk1Mn0.X2w58Hk8Wtct3-PHYqPLGmCsUgrPuLcp9-hw98E4ZCM"
    
    public static let expires06142256 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMyIsInRva2VuVHlwZSI6Ik1lcmNoYW50IiwibmJmIjo5MDM5NTg0OTUyLCJleHAiOjkwMzk1ODQ5NTIsImlhdCI6OTAzOTU4NDk1Mn0.NUkAhQu3Enh-S02ktYWA97OVkp3skSkLcYXFEEpHCfw"
}
