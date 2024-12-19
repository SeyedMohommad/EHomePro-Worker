//
//  MessageService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import Foundation
import Combine
import UIKit

class MessageService {
    static let shared = MessageService()
    
    private init() {}
    
    func fetchMessages(before time: String, for roomId: Int) -> AnyPublisher<[Message], Error> {
        
        let urlString = "\(getRestUrl())/api/logicservice/message/before/\(roomId)/\(time)/"
        print("time: \(time)")
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> [Message] in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Server error: \(response)")
                    throw URLError(.badServerResponse)
                }
                do {
                    let messages = try JSONDecoder().decode([Message].self, from: data)
                    return messages
                } catch {
                    print("Decoding error: \(error)")
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchMessages(after time: String, for roomId: Int) -> AnyPublisher<[Message], Error> {
        
        let urlString = "\(getRestUrl())/api/logicservice/message/after/\(roomId)/\(time)/"
        print("time: \(time)")
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> [Message] in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Server error: \(response)")
                    throw URLError(.badServerResponse)
                }
                do {
                    let messages = try JSONDecoder().decode([Message].self, from: data)
                    return messages
                } catch {
                    print("Decoding error: \(error)")
                    throw error
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchMessageById(_ id: Int) -> AnyPublisher<Message, Error> {
        let urlString = "\(getRestUrl())/api/logicservice/message/\(id)/"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Message in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Server error: \(response)")
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(Message.self, from: data)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    
    
    func makeMessageDelivered(messageIds: [Int]) -> AnyPublisher<Void, Error> {
        let urlString = "\(getRestUrl())/api/logicservice/message/deliver/"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: messageIds, options: [])
            request.httpBody = bodyData
        } catch {
            print("Encoding error: \(error)")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Void in
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    let httpResponse = response as? HTTPURLResponse
                    print("Server error: \(response) status code : \(httpResponse?.statusCode)")
                    throw URLError(.badServerResponse)
                }
                return ()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func sendMessage(message: Message) -> AnyPublisher<Message, Error> {
        print("send message: \(message.value)")
        let urlString = "\(getRestUrl())/api/logicservice/message/"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error to fetch accessToken in Messages Service")
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            var messageDict = try encoder.encodeToDictionary(message)
            messageDict.removeValue(forKey: "id")
            let bodyData = try JSONSerialization.data(withJSONObject: messageDict, options: [])
            request.httpBody = bodyData
            print("Request Body: \(String(data: bodyData, encoding: .utf8)!)")
        } catch {
            print("Encoding error: \(error)")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Message in
                print("Response Data: \(String(data: data, encoding: .utf8)!)")
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Server error: \(response)")
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(Message.self, from: data)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    private func compressImage(imageData: Data, maxSizeMB: Double) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        var compression: CGFloat = 1.0
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        var compressedData = imageData
        
        while compressedData.count > Int(maxSizeBytes) && compression > 0 {
            compression -= 0.1
            if let compressedImageData = image.jpegData(compressionQuality: compression) {
                compressedData = compressedImageData
            }
        }
        return compressedData.count > Int(maxSizeBytes) ? nil : compressedData
    }

    
    func sendMessageWithImage(message: Message, imageData: Data, imageName: String) -> AnyPublisher<Message, Error> {
        let urlString = "\(getRestUrl())/api/logicservice/message/image/"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("Error fetching accessToken in Messages Service")
            return Fail(error: URLError(.userAuthenticationRequired))
                .eraseToAnyPublisher()
        }
        
        guard let compressedImageData = compressImage(imageData: imageData, maxSizeMB: 1.0) else {
            print("Image compression failed or image too large to compress under the limit")
            return Fail(error: URLError(.dataLengthExceedsMaximum))
                .eraseToAnyPublisher()
        }
        
        var body = Data()
        
        // Add image data
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(imageName)\"\r\n".utf8))
        body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
        body.append(compressedImageData)
        body.append(Data("\r\n".utf8))
        
        // Add message data
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            let jsonData = try encoder.encode(message)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to convert JSON data to string")
                return Fail(error: URLError(.cannotParseResponse))
                    .eraseToAnyPublisher()
            }
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"messageDTO\"\r\n\r\n".utf8))
            body.append(Data("\(jsonString)\r\n".utf8))
        } catch {
            print("Encoding error: \(error)")
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        request.httpBody = body
        
        print("Request body: \(String(data: body, encoding: .utf8) ?? "nil")") // Debug print to check body contents
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Message in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("Server error: \(response)")
                    throw URLError(.badServerResponse)
                }
                return try JSONDecoder().decode(Message.self, from: data)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

extension JSONEncoder {
    func encodeToDictionary<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try self.encode(value)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}


