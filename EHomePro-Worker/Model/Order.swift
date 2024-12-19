//
//  Order.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import Foundation

struct Order: Identifiable, Codable {
    let id: Int
    let price: Double?
    var status: String
    let dateAndTime: [Int]
    let title: String?
    let description: String
    let customerId: Int
    let customerAddressId: Int
    let workTypeId: Int
    
    enum CodingKeys: String, CodingKey {
        case id, price, status, dateAndTime = "date_and_time", title, description, customerId = "customer_id", customerAddressId = "customer_address_id", workTypeId = "work_type_id"
    }
}

enum OrderStatusForRequest: String, Codable {
    case created = "CREATED"
    case createdSecondTry = "CREATED_SECOND_TRY"
    case processing = "PROCESSING"
    case processingSecondTry = "PROCESSING_SECOND_TRY"
    case inAction = "IN_ACTION"
    case cancel = "CANCEL"
    case done = "DONE"
}


