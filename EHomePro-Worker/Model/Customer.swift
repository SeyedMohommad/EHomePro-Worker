//
//  Customer.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import Foundation

struct Customer: Codable,Equatable {
    let id: Int
    let name: String
    let lastName: String
    let phoneNumber: String
    let email: String
    let profilePicture:String?
}

