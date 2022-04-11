//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/12/2021.
//

import Combine
import Foundation
import Model

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    public func apiDecode<A: Decodable>(
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
    ) -> AnyPublisher<A, APIError> {
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
}
