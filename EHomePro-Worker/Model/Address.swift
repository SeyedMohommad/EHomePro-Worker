//
//  Address.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/17/24.
//

import Foundation

struct Address: Codable, Identifiable, Hashable {
    var id: Int?
    var address: String
    var latitude: Double
    var longitude: Double
    var state: String
    var city: String
    var zipcode: String
    var title: String
    var details: String
    var isDefault: Bool
    var customerId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case address
        case latitude
        case longitude
        case state
        case city
        case zipcode
        case title
        case details
        case isDefault = "is_default"
        case customerId = "customer_id"
    }
}
