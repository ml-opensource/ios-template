//
//  File.swift
//
//
//  Created by Jakob Mygind on 21/12/2021.
//

import Foundation
import Model

public struct OrderDTO: Codable {

    public var id: Int
    
    public var deliveryDate: Date
   
}

extension Order {
    init(_ dto: OrderDTO) throws {

        self.init(
            id: .init(rawValue: dto.id),
            deliveryDate: dto.deliveryDate
        )
    }
}

extension Array where Element == Order {
    init(_ dtos: [OrderDTO]) throws {
        self = try dtos.map(Order.init)
    }
}
