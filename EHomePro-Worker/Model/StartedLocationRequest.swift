//
//  Untitled.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 12/3/24.
//

import Foundation

struct StartedLocationRequest: Codable {
    let id: Int
    var latitude: Double
    var altitude: Double
    var dateAndTime: [Int]
    let workerId: Int
    let tenderOfferId: Int
    
    enum CodingKeys: String, CodingKey {
        case id, latitude, altitude
        case dateAndTime = "date_and_time"
        case workerId = "worker_id"
        case tenderOfferId = "tender_offer_id"
    }
}
