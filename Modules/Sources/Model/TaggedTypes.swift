//
//  File.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
//

import Foundation
import Tagged

// MARK: Strong types for simple values

public enum UsernameTag {}
public typealias Username = Tagged<UsernameTag, String>

public enum PasswordTag {}
public typealias Password = Tagged<PasswordTag, String>

public enum SearchQueryTag {}
public typealias SearchQuery = Tagged<SearchQueryTag, String>

