//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/12/2021.
//
import Combine
import Foundation
import Model
import TokenHandler

///  Type erasing wrapper used bc enum cases cannot be generic
struct AnyEncodable: Encodable {
    let wrapped: any Encodable
    public init<Input: Encodable>(_ input: Input) {
        self.wrapped = input
    }

    func encode(to encoder: Encoder) throws {
        try wrapped.encode(to: encoder)
    }
}

extension URLRequest {
    func authenticateAndPerform<T, Value: Decodable>(using handler: AuthenticationHandlerAsync<T>) async throws -> Value {
        do {
            let data = try await handler.performAuthenticatedRequest(self)
        } catch {
            
        }
    }
}

func apiDecode<A: Decodable>(
    as type: A.Type,
    file: StaticString = #file,
    line: UInt = #line,
    jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }(),
    overrideDateFormat: String? = nil,
    for request: URLRequest? = nil
) async throws -> A {
    self

        .mapError { APIError(error: $0, file: file, line: line) }
        .flatMap { data, response -> AnyPublisher<A, APIError> in
            do {
                return try Just(jsonDecoder.decode(A.self, from: data))
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch let decodingError {
                if let request = request {
                    debugPrint(
                        "\(#function) \(decodingError) \ndata: \(String(data: data, encoding: .utf8) ?? "-")\nRequest: \(request)"
                    )
                } else {
                    debugPrint(
                        "\(#function) \(decodingError) \ndata: \(String(data: data, encoding: .utf8) ?? "-")"
                    )
                }
                do {
                    var decodedError = try jsonDecoder.decode(APIError.self, from: data)
                    if let code = (response as? HTTPURLResponse)?.statusCode {
                        decodedError.errorCode = "\(code)"
                    }
                    return Fail(error: decodedError)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: APIError(error: decodingError)).eraseToAnyPublisher()
                }
            }
        }
        .eraseToAnyPublisher()
}

func apiRequest(_ method: Method) -> URLRequest {

    var request: URLRequest
    switch method {
    case .get(let url, let parameters):
        request = makeGetRequest(url: url, parameters: parameters)
    case .post(let url, let body, let encoder):
        request = makePostRequest(url: url, requestBody: body, encoder: encoder)
    case .put(let url, let body, let encoder):
        request = makePutRequest(url: url, requestBody: body, encoder: encoder)
    }

    return request
}

extension URLRequest {
    var publisher: Just<Self> {
        Just(self)
    }
}

enum Method {
    case get(url: URL, parameters: [String: Any] = [:])
    case post(
        url: URL,
        body: AnyEncodable,
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return encoder
        }())
    case put(
        url: URL,
        body: AnyEncodable,
        encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return encoder
        }())
}

/// Request builder
/// - Parameters:
///   - url: url + path to hit
///   - parameters: url query params
/// - Returns: Request
public func makeGetRequest(
    url: URL,
    parameters: [String: Any] = [:]
) -> URLRequest {
    let request: URLRequest
    if parameters.isEmpty {
        request = URLRequest(url: url)
    } else {

        let arrayParams = parameters.filter {
            $0.value is [Int] || $0.value is [String]
        }

        let arrayItems: [URLQueryItem] = arrayParams.flatMap {
            (pair: Dictionary<String, Any>.Element) -> [URLQueryItem] in
            var queryItems: [URLQueryItem] = []

            if let intArray = pair.value as? [Int] {
                queryItems.append(
                    contentsOf: intArray.map { URLQueryItem(name: pair.key, value: "\($0)") })

            } else if let stringArray = pair.value as? [String] {
                queryItems.append(
                    contentsOf: stringArray.map { URLQueryItem(name: pair.key, value: "\($0)") })
            } else {
                fatalError()
            }

            return queryItems
        }

        let items: [URLQueryItem] = parameters.filter { !arrayParams.keys.contains($0.key) }.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }

        var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        comps.queryItems = items + arrayItems

        let escapedPlusChar = comps.url!.absoluteString.replacingOccurrences(of: "+", with: "%2B")
        request = .init(url: URL(string: escapedPlusChar)!)
    }
    return request
}

/// Request for posting
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
/// - Returns: Request
public func makePostRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}

/// Request for put
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
/// - Returns: Request
public func makePutRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}
