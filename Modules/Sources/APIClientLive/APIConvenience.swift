//
//  File.swift
//  
//
//  Created by Jakob Mygind on 07/02/2023.
//

import Foundation
import MLTokenHandler
import Model

func performAuthenticatedRequest<TokenType: APITokensEnvelopeProtocol, Output: Decodable>(
  _ request: URLRequest,
  using authHandler: AuthenticationHandlerAsync<TokenType>,
  file: StaticString = #file,
  line: UInt = #line,
  jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
  }()
) async throws -> Output {
  do {
    let (data, response) = try await authHandler.performAuthenticatedRequest(request)
    do {

      let decoded = try jsonDecoder.decode(Output.self, from: data)
      return decoded
    } catch is DecodingError {
      var decodedError = try jsonDecoder.decode(APIError.self, from: data)
      if let code = (response as? HTTPURLResponse)?.statusCode {
        decodedError.errorCode = "\(code)"
      }
      throw decodedError
    }
  } catch {
    if let error = error as? APIError {
      throw error
    }
    throw APIError(error: error, file: file, line: line)
  }
}
