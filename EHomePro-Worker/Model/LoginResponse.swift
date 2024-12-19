//
//  LoginResponse.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation

struct LoginResponse: Codable {
    var access_token: String
    var expires_in: Int
    var refresh_expires_in: Int
    var refresh_token: String
    var token_type: String
    var session_state: String
    var scope: String
}

struct LoginError: Codable, Error {
    let message: String
    let httpStatus: String
    let localDateTime: [Int]
}


struct RSLoginError: Codable, Error {
    struct ErrorMessage: Codable {
        let error: String
    }

    let message: String
    let httpStatus: String
    let localDateTime: [Int]

    var errorMessage: String? {
        guard let data = message.data(using: .utf8),
              let errorMessage = try? JSONDecoder().decode(ErrorMessage.self, from: data) else {
            return nil
        }
        return errorMessage.error
    }
}
