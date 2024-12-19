//
//  WorkerLocationService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 11/26/24.
//

import Foundation

final class WorkerLocationService {
    
    // Singleton instance
    static let shared = WorkerLocationService()
    
    // Base URL for the API
    private let baseURL = "\(getRestUrl())/api/logicservice/startedlocation"
    
    private var pollingTimer: Timer?
    private var isPolling: Bool = false
    
    // Private initializer to enforce singleton
    private init() {}
    
    // Model for the request payload
    
    
    // POST request to create a new StartedLocationRequest
    func createStartedLocation(latitude: Double, altitude: Double, dateAndTime: [Int], workerId: Int, tenderOfferId: Int, completion: @escaping (Result<StartedLocationRequest, Error>) -> Void) {
        // Construct the URL
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Create the request payload
        let requestPayload = StartedLocationRequest(id: 0, latitude: latitude, altitude: altitude, dateAndTime: dateAndTime, workerId: workerId, tenderOfferId: tenderOfferId)
        
        // Serialize the request payload to JSON
        guard let jsonData = try? JSONEncoder().encode(requestPayload) else {
            completion(.failure(NSError(domain: "Invalid payload", code: -1, userInfo: nil)))
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        print(String(data: request.httpBody!, encoding: .utf8))
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            print("Created Object: \n" + (String(data: data, encoding: .utf8) ?? "error"))
            do {
                // Parse the response to get the created StartedLocationRequest object
                let createdRequest = try JSONDecoder().decode(StartedLocationRequest.self, from: data)
                completion(.success(createdRequest))
                // Step 2: Start polling using the created request
                
                
            } catch {
                print(error.localizedDescription)
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    // PATCH request to update an existing StartedLocationRequest
    func updateStartedLocation(requestPayload: StartedLocationRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        // Construct the URL
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        // Serialize the request payload to JSON
        guard let jsonData = try? JSONEncoder().encode(requestPayload) else {
            completion(.failure(NSError(domain: "Invalid payload", code: -1, userInfo: nil)))
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            print("No access token found")
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            print("Updated Object: \n" + (String(data: data, encoding: .utf8) ?? "error"))
            completion(.success(data))
        }.resume()
    }
    
    // Start polling with PATCH requests
    func startPolling(requestPayload: StartedLocationRequest, interval: TimeInterval, completion: @escaping (Result<Data, Error>) -> Void) {
        print("Polling location...")
        guard !isPolling else { return }
        isPolling = true
        
        pollingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateStartedLocation(requestPayload: requestPayload, completion: completion)
        }
    }
    
    // Stop polling
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        isPolling = false
    }
}
