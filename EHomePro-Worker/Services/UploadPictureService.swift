//
//  UploadPictureService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/30/24.
//

import Foundation
import UIKit
import SwiftUI


class UploadPictureService {
    static let shared = UploadPictureService()
    
    func uploadProfileImage(uiImage: UIImage, workerId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        // Call the internal method with an initial attempt count of 0
        self.uploadImageAttempt(uiImage: uiImage, isIdCard: false, workerId: workerId, attemptCount: 0, completion: completion)
    }
    
    func uploadIdCardImage(uiImage: UIImage, workerId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        // Call the internal method with an initial attempt count of 0
        self.uploadImageAttempt(uiImage: uiImage, isIdCard: true, workerId: workerId, attemptCount: 0, completion: completion)
    }
    
    private func uploadImageAttempt(uiImage: UIImage,isIdCard:Bool ,workerId: Int, attemptCount: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://gateway.intelligentehome.com/api/logicservice/worker/\(isIdCard ? "uploadidcard":"uploadprofile")/\(workerId)/") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let imageData = uiImage.jpegData(compressionQuality: 0.5) // Adjust compression quality as needed
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network error or invalid response"])))
                return
            }
            
            if response.statusCode == 401, attemptCount < 1 {
                AuthenticationService.shared.refreshToken { success in
                    if success {
                        // Retry the upload after successfully refreshing the token
                        self.uploadImageAttempt(uiImage: uiImage, isIdCard: isIdCard, workerId: workerId, attemptCount: attemptCount + 1, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized - Token refresh failed"])))
                    }
                }
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                completion(.failure(NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code: \(response.statusCode)"])))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"])))
                return
            }
            
            completion(.success(responseString))
        }
        
        task.resume()
    }
    
    
    
    
}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
