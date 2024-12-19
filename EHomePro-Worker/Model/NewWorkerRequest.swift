//
//  NewWorkerRequest.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation


struct NewWorkerRequest: Codable {
    var email: String
    var password: String
    var name: String
    var lastName: String
//    var socialSecurity: String
    
    enum CodingKeys: String, CodingKey {
        case email, password, name
        case lastName = "last_name"
    }
}

struct ErrorResponse: Codable {
    var message: String
    var httpStatus: String
    var localDateTime: [Int]
}

struct InnerMessage: Codable {
    let errorMessage: String
}

