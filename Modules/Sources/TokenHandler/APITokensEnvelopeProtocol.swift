//
//  File.swift
//  
//
//  Created by Jakob Mygind on 27/01/2023.
//

import Foundation


public protocol APITokensEnvelopeProtocol: Equatable, Decodable {
    var getAccessToken: String { get }
    var getRefreshToken: String { get }
}

extension APITokensEnvelopeProtocol {
    var accessTokenExpiry: Date {
        guard let jwt = JWT(accessToken: getAccessToken) else { return Date.distantPast }
        return Date(timeIntervalSince1970: jwt.exp)
    }
    
    func isAccessTokenValid(now: Date) -> Bool {
        accessTokenExpiry > now
    }
}
