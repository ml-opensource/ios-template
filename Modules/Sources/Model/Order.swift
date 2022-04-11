//
//  File.swift
//
//
//  Created by Jakob Mygind on 18/11/2021.
//

import Foundation
import Tagged

public struct Order: Equatable, Identifiable, Codable, Hashable {

    public typealias ID = Tagged<Self, Int>

    public var id: ID
    public var deliveryDate: Date
   
    public init(
        id: Order.ID,
        deliveryDate: Date
    ) {
        self.id = id
        self.deliveryDate = deliveryDate
    }
}
