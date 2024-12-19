//
//  WorkTypeService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/13/24.
//

import Foundation

class WorkTypeService {
    static let shared = WorkTypeService()
    
    private init() {}
    
    private var cachedWorkTypes: [WorkType]?
    
    func fetchWorkTypeByID(id: Int, completion: @escaping (Result<WorkType, Error>) -> Void) {
        let domain = getRestUrl()
        let urlString = "\(domain)/api/logicservice/worktype/\(id)/"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let workType = try decoder.decode(WorkType.self, from: data)
                completion(.success(workType))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Method to fetch all work types
    func fetchAllWorkTypes(completion: @escaping (Result<[WorkType], Error>) -> Void) {
        // Check if data is already cached
        if let cachedWorkTypes = cachedWorkTypes {
            completion(.success(cachedWorkTypes))
            return
        }
        
        // Fetch data from the server
        let domain = getRestUrl()
        let urlString = "\(domain)/api/logicservice/worktype/"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            let response = response as? HTTPURLResponse
            print(response?.statusCode ?? "No status code")
            
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let workTypes = try decoder.decode([WorkType].self, from: data)
                
                
                // Cache the fetched data
                self.cachedWorkTypes = workTypes
                
                completion(.success(workTypes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchWorkerWorkTypes(workerID: Int, completion: @escaping (Result<[WorkerWorkType], Error>) -> Void) {
        
        let urlString = "\(getRestUrl())/api/logicservice/workerworktype/\(workerID)/workers/"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("*/*", forHTTPHeaderField: "accept")
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty else {
            
            AuthenticationService.shared.refreshToken { success in
                if success {
                    self.fetchWorkerWorkTypes(workerID: workerID, completion: completion)
                }
            }
            return
        }
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let workerWorkTypes = try decoder.decode([WorkerWorkType].self, from: data)
                completion(.success(workerWorkTypes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchWorkerWorkTypeById(id: Int, completion: @escaping (Result<WorkerWorkType, Error>) -> Void) {
            let urlString = "\(getRestUrl())/api/logicservice/workerworktype/\(id)/"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("*/*", forHTTPHeaderField: "accept")
            if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let workerWorkType = try decoder.decode(WorkerWorkType.self, from: data)
                    completion(.success(workerWorkType))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func connectWorkTypesToWorker(workerID: Int, workTypeIDs: [Int], completion: @escaping (Result<Int, Error>) -> Void) {
        
            let urlString = "\(getRestUrl())/api/logicservice/worker/\(workerID)/connectworktype/"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("*/*", forHTTPHeaderField: "accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: workTypeIDs, options: [])
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response received"])))
                    }
                    return
                }
                // Only the status code is important
                completion(.success(httpResponse.statusCode))
            }.resume()
        }
    
    func deleteWorkerWorkTypeById(id: Int, completion: @escaping (Result<Int, Error>) -> Void) {
            let urlString = "\(getRestUrl())/api/logicservice/workerworktype/\(id)/"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("*/*", forHTTPHeaderField: "accept")
            
            if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response received"])))
                    }
                    return
                }
                
                // Return the status code
                completion(.success(httpResponse.statusCode))
            }.resume()
        }
    
    
}


