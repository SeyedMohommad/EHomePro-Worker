//
//  CustomerService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/5/24.
//

import Foundation
import Combine


class CustomerService {
    // Singleton instance
    static let shared = CustomerService()
    
    // Set to store cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer to prevent instantiation
    private init() {}
    
    // Method to fetch worker by ID
    func getCustomer(by id: Int, completion: @escaping (Result<Customer, Error>) -> Void) {
        // Construct the URL
        guard let url = URL(string: "\(getRestUrl())/api/logicservice/customer/\(id)/") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Create the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let accessToken = UserDefaults.standard.string(forKey: "access_token"), !accessToken.isEmpty else {
            AuthenticationService.shared.refreshToken { success in
                if success {
                    self.getCustomer(by: id, completion: completion)
                }
            }
            return
        }
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // Perform the network request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                // Check for status codes
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 401:
                    throw CustomerServiceError.unauthorized
                    
                default:
                    throw CustomerServiceError.badResponse
                }
            }
            .decode(type: Customer.self, decoder: {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionStatus in
                if case .failure(let error) = completionStatus {
                    if let CustomerServiceError = error as? CustomerServiceError {
                        completion(.failure(CustomerServiceError))
                    } else {
                        completion(.failure(CustomerServiceError.other(error)))
                    }
                }
            }, receiveValue: { customer in
                completion(.success(customer))
            })
            .store(in: &cancellables)
    }
}


enum CustomerServiceError: Error {
    case unauthorized
    case badResponse
    case other(Error)
}
