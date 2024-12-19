//
//  Worker.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/3/24.
//

import Foundation

struct Worker: Codable {
    let id: Int
    let name: String
    let lastName: String
    let email: String
    let isVerified: Bool?
    let workerStatus: String?
    let livingCity: String?
    let livingState: String?
    let profilePicture: String?
    let pricePerHour: Int?
    let socialSecurity: String?
    let phoneNumber: String?
    let idCardPicture: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lastName = "last_name"
        case email
        case isVerified = "is_verified"
        case workerStatus = "worker_status"
        case livingCity = "living_city"
        case livingState = "living_state"
        case profilePicture = "profile_picture"
        case pricePerHour = "price_per_hour"
        case socialSecurity = "social_security"
        case phoneNumber = "phone_number"
        case idCardPicture = "id_card_picture"
    }
}

