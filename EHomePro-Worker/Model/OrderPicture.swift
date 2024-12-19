//
//  OrderPicture.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/12/24.
//

import Foundation


struct OrderPicture: Codable {
    let id: Int
    let pictureUrl: String
    let orderId: Int
    
    // Custom CodingKeys to match JSON keys
    enum CodingKeys: String, CodingKey {
        case id
        case pictureUrl = "picture_url"
        case orderId = "order_id"
    }
}
