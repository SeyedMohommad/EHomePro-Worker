//
//  TenderOffer.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/15/24.
//

import Foundation

struct TenderOffer: Codable,Equatable {
    let id: Int?
    let price: Double
    let description: String
    let workerLatitude: Double
    let tenderOfferStatus: TenderOfferStatus
    let workerAltitude: Double
    let isWorkerAccepted: Bool
    let isOrderAccepted: Bool?
    let workerId: Int
    let orderId: Int
    let verificationCode: String?
    
    // Custom CodingKeys to map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case description
        case workerLatitude = "worker_latitude"
        case tenderOfferStatus = "tender_offer_status"
        case workerAltitude = "worker_altitude"
        case isWorkerAccepted = "is_worker_accepted"
        case isOrderAccepted = "is_order_accepted"
        case workerId = "worker_id"
        case orderId = "order_id"
        case verificationCode = "verification_code"
    }
}

// TenderOfferStatus enum with String raw values, conforming to Codable
enum TenderOfferStatus: String, Codable { // Codable conformance is implicit with RawRepresentable
    case created = "CREATED"
    case createdSecondTry = "CREATED_SECOND_TRY"
    case accepted = "ACCEPTED"
    case acceptedSecondTry = "ACCEPTED_SECOND_TRY"
    case inAction = "IN_ACTION"
    case canceled = "CANCELED"
    case done = "DONE"

    // Method to return the string value of the enum case
    func stringValue() -> String {
        return self.rawValue
    }
}

