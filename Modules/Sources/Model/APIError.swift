//
//  File.swift
//
//
//  Created by Jakob Mygind on 14/12/2021.
//

import Foundation

public struct APIError: Codable, Error, LocalizedError, Equatable {
    public var errorCode: String?
    public let message: String
    public let errorDump: String?
    public let line: UInt?
    public let file: String?

    public init(
        error: Error,
        file: StaticString = #fileID,
        line: UInt = #line
    ) {
        var string = ""
        dump(error, to: &string)
        self.errorDump = string
        self.file = String(describing: file)
        self.line = line
        self.message = error.localizedDescription
        errorCode = "-"
    }

    public enum CodingKeys: String, CodingKey {
        case message = "Message"
        case errorCode
        case errorDump
        case line
        case file

    }

    public var errorDescription: String? {
        self.message
    }
}
