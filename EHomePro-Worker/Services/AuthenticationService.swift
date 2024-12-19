//
//  AuthenticationService.swift
//  EHomePro-Worker
//
//  Created by Ashkan Amin on 5/19/24.
//

import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()

    private init() {}



    func refreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = UserDefaults.standard.string(forKey: "refresh_token") else {
            completion(false)
            return
        }

        guard let requestURL = URL(string: "https://gateway.intelligentehome.com/api/logicservice/user/\(refreshToken)/") else {
            print("Invalid URL")
            completion(false)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(decodedResponse.access_token, forKey: "access_token")
                        UserDefaults.standard.set(decodedResponse.refresh_token, forKey: "refresh_token")
                    }
                    
                    
                    completion(true)
                    return
                }
                
            }
            completion(false)
        }.resume()
    }

}
