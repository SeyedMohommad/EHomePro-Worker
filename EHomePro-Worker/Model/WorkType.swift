//
//  WorkType.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/13/24.
//

import Foundation

struct WorkType: Decodable {
    let id: Int
    let name: String
    let description: String
    let commission: Double
    
    private var _logo: String?
    
    var logo: String {
        return _logo ?? name.replacingOccurrences(of: "/", with: "")
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case commission
        case _logo = "logo"
    }
}

struct WorkerWorkType: Identifiable, Decodable {
    let id: Int?
    let workerId: Int
    let workTypeId: Int
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case workerId = "worker_id"
        case workTypeId = "work_type_id"
        case status
    }
    
    
}

