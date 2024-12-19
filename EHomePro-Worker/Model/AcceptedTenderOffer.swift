//
//  AcceptedTenderOffer.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 10/26/24.
//

import Foundation


struct AcceptedTenderOffer: Decodable,Equatable {
    let id: Int
    let acceptedDate: Date
    let status: String
    let tenderOfferId: Int
    let orderId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case acceptedDate = "accepted_date"
        case status
        case tenderOfferId = "tender_offer_id"
        case orderId = "order_id"
    }
}
