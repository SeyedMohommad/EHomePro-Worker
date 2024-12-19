//
//  AddressService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 8/17/24.
//

import Foundation

class AddressService {
    static let shared = AddressService()
    
    private init() {}
    
    func fetchCustomerAddressById(id: Int, completion: @escaping (Result<Address, Error>) -> Void) {
        
        let domain = getRestUrl()
        guard let url = URL(string: "\(domain)/api/logicservice/customer-address/\(id)/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }else{
            print("fetchToken failed")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("net error")
                completion(.failure(NetworkError.unknownError))
                return
            }
            
            
            if (200..<300).contains(httpResponse.statusCode) {
                do {
                    let address = try JSONDecoder().decode(Address.self, from: data)
                    
                    completion(.success(address))
                } catch {
                    
                    completion(.failure(error))
                }
            } else {
                if httpResponse.statusCode == 401 {
                    AuthenticationService.shared.refreshToken { success in
                        if success {
                            self.fetchCustomerAddressById(id: id, completion: completion)
                        }
                    }
                } else {
                    completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                }
            }
        }.resume()
    }
}

