//
//  WorkerService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 7/3/24.
//

import Foundation


class WorkerService {
    // Singleton instance
    static let shared = WorkerService()
    private let baseUrl = getRestUrl()
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    // Function to update customer data
    func updateWorkerData(worker: Worker, completion: @escaping (Worker?, String?) -> Void) {
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "\(baseUrl)/api/logicservice/worker") else {
            completion(nil, "Required information is missing")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(worker)
            request.httpBody = jsonData
            
        } catch {
            completion(nil, "Failed to encode Worker data")
            return
        }
        
        performRequest(with: request, completion: completion)
    }
    
    // Existing fetch functions and performRequest function
    func fetchWorkerDatabyId(completion: @escaping (Worker?, String?) -> Void) {
        guard let workerId = UserDefaults.standard.string(forKey: "WorkerId"),
              let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "\(baseUrl)/api/logicservice/worker/\(workerId)/") else {
            completion(nil, "Required information is missing")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        performRequest(with: request, completion: completion)
    }
    
    func fetchWorkerDatabyEmail(completion: @escaping (Worker?, String?) -> Void) {
        print("fetchWorkerDatabyEmail")
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let accessToken = UserDefaults.standard.string(forKey: "access_token"),
              let url = URL(string: "\(baseUrl)/api/logicservice/worker/email/\(email)/") else {
            
            completion(nil, "Required information is missing")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        performRequest(with: request, completion: completion)
    }
    
    private func performRequest(with request: URLRequest, completion: @escaping (Worker?, String?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, "Invalid response from server")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    
                    do {
                        
                        let worker = try JSONDecoder().decode(Worker.self, from: data)
                        
                        DispatchQueue.main.async {
                            
                            UserDefaults.standard.setValue(worker.id, forKey: "WorkerId")
                            if let encodedCustomer = try? JSONEncoder().encode(worker) {
                                
                                UserDefaults.standard.set(encodedCustomer, forKey: "Worker")
                            }
                        }
                        
                        completion(worker, nil)
                    } catch {
                        
                        completion(nil, "Failed to decode Worker data")
                    }
                } else {
                    
                    completion(nil, "No data received")
                }
            case 401:
                AuthenticationService.shared.refreshToken { success in
                    if success {
                        self.fetchWorkerDatabyEmail(completion: completion)
                    } else {
                        completion(nil, "Authentication failed")
                    }
                }
            default:
                completion(nil, "Received HTTP status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
    func checkWorkerProfileInformation(id: Int, completion: @escaping ([String], String?) -> Void) {
        
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token") else {
            
            AuthenticationService.shared.refreshToken { success in
                if success {
                    self.checkWorkerProfileInformation(id: id, completion: completion)
                    return
                } else {
                    completion([], "Authentication Error")
                }
            }
            return
        }
        
        guard let url = URL(string: "\(baseUrl)/api/logicservice/check-worker-profile-information/\(id)/fields/") else {
            completion([],"URL Error")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 401 else {
                AuthenticationService.shared.refreshToken { success in
                    
                    if success {
                        
                        self.checkWorkerProfileInformation(id: id, completion: completion)
                        return
                    } else {
                        
                        completion([],"Error")
                    }
                }
                return
            }
            
            guard let data = data, httpResponse.statusCode == 200 else {
                
                completion([],"HttpRequest Error")
                return
            }
            
            do {
                
                let result = try JSONDecoder().decode([String].self, from: data)
                if result != [] {
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.setValue(true, forKey: "hasProfile")
                    }
                    
                }
                
                completion(result,nil)
            } catch {
                completion([],"Decode Error")
            }
        }
        
        task.resume()
    }
    
    func changeWorkerStatus(status: WorkerStatus, completion: @escaping (String?, String?) -> Void) {
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"), let workerId = UserDefaults.standard.string(forKey: "WorkerId") else{
            completion(nil, "Required information is missing")
            return
        }
        guard let url = URL(string: "\(baseUrl)/api/logicservice/worker/\(workerId)/status/\(status.rawValue)") else {
            completion(nil, "Required information is missing")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, "Invalid response from server")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(nil, "Received HTTP status code: \(httpResponse.statusCode)")
                return
            }
            
            if let data = data, let statusString = String(data: data, encoding: .utf8) {
                completion(statusString.trimmingCharacters(in: .whitespacesAndNewlines), nil)
            } else {
                completion(nil, "No data received")
            }
        }
        task.resume()
    }
    
}

enum WorkerStatus: String {
    case online = "ONLINE"
    case offline = "OFFLINE"
}
