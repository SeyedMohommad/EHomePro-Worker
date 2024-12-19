//
//  AdditionalInfo.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/20/24.
//

import Foundation

struct AdditionalInfo: Codable, Identifiable {
    let id: Int
    let description: String
    let pictureUrls: [String]
    let orderId: Int
    let workerId: Int

    // Map JSON keys to Swift property names if they differ
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case pictureUrls = "picture_urls"
        case orderId = "order_id"
        case workerId = "worker_id"
    }
}
