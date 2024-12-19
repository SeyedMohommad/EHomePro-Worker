//
//  Room.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import Foundation

struct Room: Identifiable, Codable {
    let id: Int
    let customer_id: Int
    let worker_id: Int
    let created_at: Date
    let has_unread_messages: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, customer_id, worker_id, created_at, has_unread_messages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        customer_id = try container.decode(Int.self, forKey: .customer_id)
        worker_id = try container.decode(Int.self, forKey: .worker_id)
        has_unread_messages = try container.decode(Bool.self, forKey: .has_unread_messages)
        
        let createdAtArray = try container.decode([Int].self, forKey: .created_at)
        if createdAtArray.count == 7 {
            let dateComponents = DateComponents(
                year: createdAtArray[0],
                month: createdAtArray[1],
                day: createdAtArray[2],
                hour: createdAtArray[3],
                minute: createdAtArray[4],
                second: createdAtArray[5],
                nanosecond: createdAtArray[6]
            )
            let calendar = Calendar.current
            created_at = calendar.date(from: dateComponents) ?? Date()
        } else {
            created_at = Date()
        }
    }
}

struct RoomWithCustomer: Identifiable, Equatable {
    let id: Int
    let worker_id: Int
    let customer: Customer
    let created_at: Date
    let has_unread_messages: Bool
    static func ==(lhs: RoomWithCustomer, rhs: RoomWithCustomer) -> Bool {
        return lhs.id == rhs.id &&
        lhs.worker_id == rhs.worker_id &&
        lhs.customer == rhs.customer &&
        lhs.created_at == rhs.created_at &&
        lhs.has_unread_messages == rhs.has_unread_messages
    }
    
}




struct Message: Identifiable, Codable {
    let id: Int?
    let roomId: Int
    let senderId: Int
    let value: String
    let userType: UserType
    let messageType: String
    let sentAt: [Int]
    let isDelivered: Bool
    let replyToMessage_id: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case senderId = "sender_id"
        case value
        case userType = "user_type"
        case messageType = "message_type"
        case sentAt = "sent_at"
        case isDelivered = "is_delivered"
        case replyToMessage_id = "reply_to_message_id"
    }
}

enum UserType: String, Codable {
    case customer = "CUSTOMER"
    case worker = "WORKER"
}





//let sampleChats = [
//    Room(id: 1, customer_id: 1, worker_id: 1, created_at: "now", has_unread_messages: false),
//    Room(id: 1, customer_id: 1, worker_id: 1, created_at: "now", has_unread_messages: false),
//    Room(id: 1, customer_id: 1, worker_id: 1, created_at: "now", has_unread_messages: false)
//]



extension Date {
    func formattedDate() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set the time zone to GMT
        return isoFormatter.string(from: self)
    }
}

